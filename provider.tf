terraform {
  required_providers {

    ### AWS provider ###
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ### ansible provider ###
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    # # TLS block for keypairs
    # tls = {
    #   source  = "hashicorp/tls"
    #   version = "4.0.4"
    # }

  } # end of provider block
}   # End of Terraform main block


provider "aws" {
  region     = "eu-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

# terraform {
#   cloud {

#     organization = "Meraj-Natwest"

#     workspaces {
#       name = "FinalProject"
#     }
#   }
# }