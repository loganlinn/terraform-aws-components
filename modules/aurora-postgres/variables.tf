variable "region" {
  type        = string
  description = "AWS Region"
}

variable "dns_gbl_delegated_environment_name" {
  type        = string
  description = "The name of the environment where global `dns_delegated` is provisioned"
  default     = "gbl"
}

variable "cluster_name" {
  type        = string
  description = "Short name for this cluster"
}

variable "database_name" {
  type        = string
  description = "Name for an automatically created database on cluster creation. An empty name will generate a db name."
  default     = ""
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Specifies whether the Cluster should have deletion protection enabled. The database can't be deleted when this value is set to `true`"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = <<-EOT
    Normally AWS makes a snapshot of the database before deleting it. Set this to `true` in order to skip this.
    NOTE: The final snapshot has a name derived from the cluster name. If you delete a cluster, get a final snapshot,
    then create a cluster of the same name, its final snapshot will fail with a name collision unless you delete
    the previous final snapshot first.
    EOT
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the DB cluster is encrypted"
}

variable "engine" {
  type        = string
  description = "Name of the database engine to be used for the DB cluster"
  default     = "postgresql"
}

variable "engine_version" {
  type        = string
  description = "Engine version of the Aurora global database"
  default     = "13.4"
}

variable "engine_mode" {
  type        = string
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`"
}

variable "cluster_family" {
  type        = string
  description = "Family of the DB parameter group. Valid values for Aurora PostgreSQL: `aurora-postgresql9.6`, `aurora-postgresql10`, `aurora-postgresql11`, `aurora-postgresql12`"
  default     = "aurora-postgresql13"
}

# AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "database_port" {
  type        = number
  description = "Database port"
  default     = 5432
}

# Don't use `admin`
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "admin_user" {
  type        = string
  description = "Postgres admin user name"
  default     = ""

  validation {
    condition = (
      length(var.admin_user) == 0 ||
      (var.admin_user != "admin" &&
        length(var.admin_user) >= 1 &&
      length(var.admin_user) <= 16)
    )
    error_message = "Per the RDS API, admin cannot be used as it is a reserved word used by the engine. Master username must be between 1 and 16 characters. If an empty string is provided then a random string will be used."
  }
}

# Must be longer than 8 chars
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "admin_password" {
  type        = string
  description = "Postgres password for the admin user"
  default     = ""
  sensitive   = true

  validation {
    condition = (
      length(var.admin_password) == 0 ||
      (length(var.admin_password) >= 8 &&
      length(var.admin_password) <= 128)
    )
    error_message = "Per the RDS API, master password must be between 8 and 128 characters. If an empty string is provided then a random password will be used."
  }
}

# https://aws.amazon.com/rds/aurora/pricing
variable "instance_type" {
  type        = string
  description = "EC2 instance type for Postgres cluster"
}

variable "cluster_size" {
  type        = number
  description = "Postgres cluster size"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = false
}

variable "cluster_dns_name_part" {
  type        = string
  description = "Part of DNS name added to module and cluster name for DNS for cluster endpoint"
  default     = "writer"
}

variable "reader_dns_name_part" {
  type        = string
  description = "Part of DNS name added to module and cluster name for DNS for cluster reader"
  default     = "reader"
}

variable "additional_databases" {
  type        = set(string)
  default     = []
  description = "Additional databases to be created with the cluster"
}

variable "ssm_path_prefix" {
  type        = string
  default     = "aurora-postgres"
  description = "Top level SSM path prefix (without leading or trailing slash)"
}

variable "publicly_accessible" {
  type        = bool
  description = "Set true to make this database accessible from the public internet"
  default     = false
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs allowed to access the database (in addition to security groups and subnets)"
  default     = []
}

variable "maintenance_window" {
  type        = string
  default     = "wed:03:00-wed:04:00"
  description = "Weekly time range during which system maintenance can occur, in UTC"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery"
  default     = []
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Performance Insights"
}

variable "enhanced_monitoring_role_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring"
  default     = true
}

variable "enhanced_monitoring_attributes" {
  type        = list(string)
  description = "Attributes used to format the Enhanced Monitoring IAM role. If this role hits IAM role length restrictions (max 64 characters), consider shortening these strings."
  default     = ["enhanced-monitoring"]
}

variable "rds_monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60"
  default     = 60
}

variable "autoscaling_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable cluster autoscaling"
}

variable "autoscaling_policy_type" {
  type        = string
  default     = "TargetTrackingScaling"
  description = "Autoscaling policy type. `TargetTrackingScaling` and `StepScaling` are supported"
}

variable "autoscaling_target_metrics" {
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
  description = "The metrics type to use. If this value isn't provided the default is CPU utilization"
}

variable "autoscaling_target_value" {
  type        = number
  default     = 75
  description = "The target value to scale with respect to target metrics"
}

variable "autoscaling_scale_in_cooldown" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start. Default is 300s"
}

variable "autoscaling_scale_out_cooldown" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start. Default is 300s"
}

variable "autoscaling_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of instances to be maintained by the autoscaler"
}

variable "autoscaling_max_capacity" {
  type        = number
  default     = 5
  description = "Maximum number of instances to be maintained by the autoscaler"
}

variable "snapshot_identifier" {
  type        = string
  default     = null
  description = "Specifies whether or not to create this cluster from a snapshot"
}

variable "eks_security_group_enabled" {
  type        = bool
  description = "Use the eks default security group"
  default     = false
}

variable "eks_component_names" {
  type        = set(string)
  description = "The names of the eks components"
  default     = ["eks/cluster"]
}

variable "allow_ingress_from_vpc_accounts" {
  type = list(object({
    vpc         = optional(string, "vpc")
    environment = optional(string)
    stage       = optional(string)
    tenant      = optional(string)
  }))
  default     = []
  description = <<-EOF
    List of account contexts to pull VPC ingress CIDR and add to cluster security group.
    e.g.
    {
      environment = "ue2",
      stage       = "auto",
      tenant      = "core"
    }

    Defaults to the "vpc" component in the given account
  EOF
}

variable "ssm_password_source" {
  type        = string
  default     = ""
  description = <<-EOT
    If `var.ssm_passwords_enabled` is `true`, DB user passwords will be retrieved from SSM using
    `var.ssm_password_source` and the database username. If this value is not set,
    a default path will be created using the SSM path prefix and ID of the associated Aurora Cluster.
    EOT
}

variable "vpc_component_name" {
  type        = string
  default     = "vpc"
  description = "The name of the VPC component"
}

variable "scaling_configuration" {
  type = list(object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  }))
  default     = []
  description = "List of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`. This is required for Serverless v1"
}

variable "serverlessv2_scaling_configuration" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "Nested attribute with scaling properties for ServerlessV2. Only valid when `engine_mode` is set to `provisioned.` This is required for Serverless v2"
}
