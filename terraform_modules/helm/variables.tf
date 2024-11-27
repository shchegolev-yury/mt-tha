variable "kubeconfig_path" {
  description = "Path to kubeconfig."
  type        = string
  default     = "~/.kube/config"
}

variable "release_name" {
  description = "Name of Helm release to be installed."
  type        = string
}

variable "chart_path" {
  description = "Path to the chart (local/full URL)."
  type        = string
  default     = "./.helm"
}

variable "namespace" {
  description = "Namespace name to install chart."
  type        = string
  default     = "default"
}

variable "new_values" {
  description = "New values in case of not using values.yaml file."
  type        = map(string)
  default     = {}
}

variable "create_namespace" {
  description = "Whether or not to create a namespace."
  type        = bool
  default     = true
}

variable "helm_lint" {
  description = "Whether or not to lint helm chart on plan stage."
  type        = bool
  default     = true
}