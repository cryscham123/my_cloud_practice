terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "example"

    workspaces {
      name = "example"
    }
  }
}