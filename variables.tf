variable "region" {
  type    = string
  default = "eu-central-1"
}

# just for testing
variable "ssh_allowed_ips" {
  type    = list(string)
  default = ["31.182.217.61/32"]
}

variable "db" {
  type = map(string)
  default = {
    "username" = "admin",
    "password" = "adminpassword"
  }
}

variable "domain" {
  type    = string
  default = "lab.redlock.online"
}


variable "domain_prefix" {
  type    = string
  default = "oc"
}


variable "ssh_key_name" {
  type    = string
  default = "lb"
}

variable "secureweb_ips" {
  type    = list(string)
  default = []
}

variable "repo_example_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


variable "intra_inbound_acl_rules" {
  type = list(map(string))
  default = [
    {
      "cidr_block" : "10.0.21.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 100,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.22.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 101,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.23.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 102,
      "to_port" : 0
    }
  ]
}

variable "intra_outbound_acl_rules" {
  type = list(map(string))
  default = [
    {
      "cidr_block" : "10.0.21.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 100,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.22.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 101,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.23.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 102,
      "to_port" : 0
    }
  ]
}


variable "private_outbound_acl_rules" {
  # it's allowed to connect everywhere because EC2 need to connect to SecureWeb and external repository
  type = list(map(string))
  default = [
    {
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 100,
      "to_port" : 0
    }
  ]
}

variable "private_inbound_acl_rules" {
  # deny connection from intra network
  type = list(map(string))
  default = [
    {
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 99,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.51.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "deny",
      "rule_number" : 100,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.52.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "deny",
      "rule_number" : 101,
      "to_port" : 0
    },
    {
      "cidr_block" : "10.0.53.0/24",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "deny",
      "rule_number" : 102,
      "to_port" : 0
    }
  ]
}