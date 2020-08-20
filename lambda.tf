terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

# Load source as zip file
provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "getdata.js"
  output_path = "getdata.zip"
}

# IAM
resource "aws_iam_role" "lambda_getdata" {
   name = "serverless_getdata_lambda"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "lambdaTre_role_policy" {
  name = "lambdaTre_role_policy"
  role = aws_iam_role.lambda_getdata.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_lambda_function" "getdata" {
  function_name = "functionGetdata"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role    = aws_iam_role.lambda_getdata.arn

  # "lambda_clock" is the filename within the zip file and "handler" is the name of the property under which the handler function was
  # exported in that file.
  handler = "getdata.handler"
  runtime = "nodejs12.x"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.getdata.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.getdata.execution_arn}/*/*"
}