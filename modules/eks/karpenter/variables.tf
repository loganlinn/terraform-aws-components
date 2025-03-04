variable "region" {
  type        = string
  description = "AWS Region"
}

variable "chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)"
  default     = null
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended"
}

variable "chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  default     = null
}

variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  description = "The CPU and memory of the deployment's limits and requests"
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not yet exist. Defaults to `false`"
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into"
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  default     = null
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  default     = true
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used"
  default     = true
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`"
  default     = null
}

variable "chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values"
  default     = {}
}

variable "rbac_enabled" {
  type        = bool
  description = "Enable/disable RBAC"
  default     = true
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "interruption_handler_enabled" {
  type        = bool
  default     = false
  description = <<EOD
  If `true`, deploy a SQS queue and Event Bridge rules to enable interruption handling by Karpenter.

  https://karpenter.sh/v0.27.5/concepts/deprovisioning/#interruption
  EOD
}

variable "interruption_queue_message_retention" {
  type        = number
  default     = 300
  description = "The message retention in seconds for the interruption handler SQS queue."
}

variable "legacy_create_karpenter_instance_profile" {
  type        = bool
  description = <<-EOT
    When `true` (the default), this component creates an IAM Instance Profile
    for nodes launched by Karpenter, to preserve the legacy behavior.
    Set to `false` to disable creation of the IAM Instance Profile, which
    avoids conflict with having `eks/cluster` create it.
    Use in conjunction with `eks/cluster` component `legacy_do_not_create_karpenter_instance_profile`,
    which see for further details.
    EOT
  default     = true
}
