data "aws_networkmanager_core_network_policy_document" "policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64520"]

    #Defining the regions where the core network will be deployed

    edge_locations {
      location = "us-east-1"
      asn      = 64512
    }

    edge_locations {
      location = "eu-west-1"
      asn      = 64513
    }

    edge_locations {
      location = "ap-southeast-1"
      asn      = 64514
    }
  }

  # Defining segments for the core network
  segments {
    name                          = "prod"
    description                   = "Production workloads"
    require_attachment_acceptance = true
  }

  segments {
    name                          = "dev"
    description                   = "Developments workloads"
    require_attachment_acceptance = false # auto approval
  }

  segments {
    name                          = "shared"
    description                   = "Shared services"
    require_attachment_acceptance = true
  }

  # ALlow shared services to be reached from all segments
  segment_actions {
    action     = "share"
    mode       = "attachment-route"
    segment    = "shared"
    share_with = ["prod", "dev"]
  }

  # Atomatically assign VPCs to a segments based on tags
  attachment_policies {
    rule_number     = 1
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "segment"
      value    = "prod"
    }

    action {
      association_method = "constant"
      segment            = "prod"
    }
  }

  attachment_policies {
    rule_number     = 2
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "segment"
      value    = "dev"
    }

    action {
      association_method = "constant"
      segment            = "dev"
    }
  }
}