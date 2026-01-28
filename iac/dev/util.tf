resource "random_string" "suffix" {
  count   = 3
  length  = 8
  special = false
  upper   = false

}

