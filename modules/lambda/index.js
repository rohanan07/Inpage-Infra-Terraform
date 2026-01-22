const http = require('http');

exports.handler = async (event) => {
  console.log("Received Event:", JSON.stringify(event, null, 2));

  const albDns = process.env.ALB_DNS;
  if (!albDns) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "ALB_DNS env var missing" })
    };
  }

  const options = {
    hostname: albDns,
    port: 80,
    path: event.path + (event.queryStringParameters
      ? '?' + new URLSearchParams(event.queryStringParameters).toString()
      : ''),
    method: event.httpMethod,
    headers: {
      ...event.headers,
      host: albDns
    }
  };

  return new Promise((resolve) => {
    const req = http.request(options, (res) => {
      let responseBody = '';

      res.on('data', chunk => responseBody += chunk);
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: responseBody
        });
      });
    });

    req.on('error', (e) => {
      console.error("ALB request failed:", e);
      resolve({
        statusCode: 502,
        body: JSON.stringify({ message: "Bad Gateway", error: e.message })
      });
    });

    if (event.body) {
      req.write(event.body);
    }

    req.end();
  });
};
