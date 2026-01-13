resource "aws_lambda_permission" "ws_connect" {
  statement_id  = "AllowAPIGatewayInvokeConnect"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ws["ws-connect"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ws.execution_arn}/*/$connect"
}

resource "aws_lambda_permission" "ws_disconnect" {
  statement_id  = "AllowAPIGatewayInvokeDisconnect"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ws["ws-disconnect"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ws.execution_arn}/*/$disconnect"
}

resource "aws_lambda_permission" "ws_subscribe" {
  statement_id  = "AllowAPIGatewayInvokeSubscribe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ws["ws-subscribe"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ws.execution_arn}/*/subscribe"
}
