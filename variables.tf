variable "env" {
  description = "Env to deploy."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "The 'env' variable must be one of the following values: 'dev', 'staging', 'prod'."
  }
}

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "image_name" {
  description = "Name of the container image."
  type        = string
}

variable "image_tag" {
  description = "Tag og the container image."
  type        = string
}

variable "base_url" {
  description = "Base url of the application."
  type        = string
}

variable "log_level" {
  description = "App log level."
  type = string
  default = "INFO"
}