output "API_Base_Url" {
  value = "${aws_api_gateway_stage.dev_stage.invoke_url}/${aws_api_gateway_resource.api_resource.path_part}"
}