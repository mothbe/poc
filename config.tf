provider "aws" {
  region = var.region

  default_tags {
    tags = {
      environment = "PoC"
    }
  }
}


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.7.3"
}
