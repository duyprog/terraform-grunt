output "arn" {
    description = "ARN of the bucket"
    value = aws_s3_bucket.web.arn
}

output "name" {
	description = "Name of the bucket"
	value = aws_s3_bucket.web.id		
}

output "domain" {
	description = "Domain name of the website"
	value = aws_s3_bucket.web.website_domain
}

output "endpoint" {
	description = "Endpoint of the website"
	value = aws_s3_bucket.web.website_endpoint
}