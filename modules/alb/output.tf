output "text_processing_target_group_arn" {
  value = aws_lb_target_group.text-processing-tg.arn
}

output "dictionary_target_group_arn" {
  value = aws_lb_target_group.dictionary-tg.arn
}

output "alb_dns_name" {
  value = aws_lb.main_alb.dns_name
}