resource "aws_codestarconnections_connection" "this" {
  name          = "codestar-connection"
  provider_type = "GitHub"
}
