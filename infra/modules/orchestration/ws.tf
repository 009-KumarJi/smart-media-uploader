resource "aws_apigatewayv2_api" "ws" {
  name          = "smmu-${var.env}-ws"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  
}

resource "aws_apigatewayv2_integration" "ws_connect" {
  api_id           = aws_apigatewayv2_api.ws.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.ws["ws-connect"].invoke_arn
}

resource "aws_apigatewayv2_route" "connect" {
  api_id    = aws_apigatewayv2_api.ws.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_connect.id}"
}

resource "aws_apigatewayv2_integration" "ws_disconnect" {
  api_id           = aws_apigatewayv2_api.ws.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.ws["ws-disconnect"].invoke_arn
}

resource "aws_apigatewayv2_route" "disconnect" {
  api_id    = aws_apigatewayv2_api.ws.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_disconnect.id}"
}

resource "aws_apigatewayv2_integration" "ws_subscribe" {
  api_id           = aws_apigatewayv2_api.ws.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.ws["ws-subscribe"].invoke_arn
}

resource "aws_apigatewayv2_route" "subscribe" {
  api_id    = aws_apigatewayv2_api.ws.id
  route_key = "subscribe"
  target    = "integrations/${aws_apigatewayv2_integration.ws_subscribe.id}"
}

resource "aws_apigatewayv2_stage" "ws" {
  api_id = aws_apigatewayv2_api.ws.id
  name   = var.env
  auto_deploy = true
}