resource "random_string" "suffix" {
  count   = 4
  length  = 8
  special = false
  upper   = false

}

