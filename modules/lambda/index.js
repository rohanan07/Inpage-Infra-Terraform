const http = require('http');

// Helper to make HTTP requests (keep code clean)
function makeRequest(url, method, headers, body) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || 80,
      path: urlObj.pathname + urlObj.search,
      method: method,
      headers: headers
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: data ? JSON.parse(data) : {}
          });
        } catch (e) {
          resolve({ statusCode: res.statusCode, headers: res.headers, data: data });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

exports.handler = async (event) => {
  console.log("🚀 Handler Started");

  // 1. CONFIGURATION CHECKS
  const albDns = process.env.ALB_DNS; 
  const userDataUrl = process.env.USER_DATA_SERVICE_URL; // New Env Var!

  if (!albDns || !userDataUrl) {
    console.error("Missing Env Vars");
    return { statusCode: 500, body: JSON.stringify({ message: "Configuration Error" }) };
  }

  // 2. EXTRACT IDENTITY
  let userId = 'anonymous';
  if (event.requestContext?.authorizer?.claims?.sub) {
    userId = event.requestContext.authorizer.claims.sub;
    console.log(`👤 User Identity: ${userId}`);
  }

  // 3. PARSE INCOMING REQUEST
  let requestBody;
  try {
    requestBody = JSON.parse(event.body);
  } catch (e) {
    return { statusCode: 400, body: JSON.stringify({ message: "Invalid JSON body" }) };
  }

  const { text, bookId, pageNumber } = requestBody;

  // ---------------------------------------------------------
  // STEP 2: CALL TEXT PROCESSING SERVICE
  // ---------------------------------------------------------
  console.log("📡 Calling Text Processing Service...");
  
  // Assuming Text Processing is at /process on your ALB
  const textServiceUrl = `http://${albDns}/process`; 

  try {
    const textResponse = await makeRequest(
      textServiceUrl, 
      'POST', 
      { 
        'Content-Type': 'application/json',
        'x-user-id': userId 
      }, 
      { text: text, bookId, pageNumber } // Pass original payload
    );

    if (textResponse.statusCode !== 200) {
      console.error("❌ Text Processing Failed:", textResponse.data);
      return { statusCode: textResponse.statusCode, body: JSON.stringify(textResponse.data) };
    }

    const processedWords = textResponse.data.words; // The extracted words
    console.log(`✅ Text Processed. Found ${processedWords.length} words.`);

    // ---------------------------------------------------------
    // STEP 4: CALL USER DATA SERVICE (To Save Words)
    // ---------------------------------------------------------
    if (processedWords.length > 0 && userId !== 'anonymous') {
      console.log("💾 Saving words to User Data Service...");

      // Construct the payload for User Data Service
      const savePayload = {
        bookId: bookId || "unknown-book",
        pageNumber: pageNumber || 1,
        words: processedWords
      };

      // Call the second service
      // Ensure userDataUrl includes the path if needed, e.g. "http://internal-alb/words"
      // Or we append /words here if the env var is just the host
      const saveUrl = userDataUrl.endsWith('/words') ? userDataUrl : `${userDataUrl}/words`;

      const saveResponse = await makeRequest(
        saveUrl, 
        'POST', 
        { 
          'Content-Type': 'application/json',
          'x-user-id': userId 
        }, 
        savePayload
      );

      if (saveResponse.statusCode === 201 || saveResponse.statusCode === 200) {
        console.log("✅ Words Saved Successfully");
      } else {
        console.warn("⚠️ Warning: Failed to save words:", saveResponse.data);
        // We do NOT fail the user request just because saving failed. We proceed.
      }
    }

    // ---------------------------------------------------------
    // STEP 5: RETURN RESPONSE
    // ---------------------------------------------------------
    return {
      statusCode: 200,
      headers: { 
        "Access-Control-Allow-Origin": "*", // Important for CORS
        "Content-Type": "application/json"
      },
      body: JSON.stringify(textResponse.data)
    };

  } catch (error) {
    console.error("🔥 System Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Internal Orchestration Error", error: error.message })
    };
  }
};
