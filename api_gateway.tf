resource "aws_api_gateway_rest_api" "getdata" {
  name        = "ServerlessGetdata"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.getdata.id
  parent_id   = aws_api_gateway_rest_api.getdata.root_resource_id
  path_part   = "getdata"
}

resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.getdata.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id = aws_api_gateway_rest_api.getdata.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.getdata.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.getdata.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = "200"
 
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.getdata.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [
    aws_api_gateway_integration.MyDemoIntegration
    ]

  # Transforms the backend JSON
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "getdata" {
   depends_on = [
     aws_api_gateway_integration.MyDemoIntegration,
   ]

   rest_api_id = aws_api_gateway_rest_api.getdata.id
   stage_name  = "test"
}
/*
output "base_url" {
  value = aws_api_gateway_deployment.getdata.invoke_url
}*/