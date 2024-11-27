module "helm_chart" {
  source       = "./terraform_modules/helm"
  release_name = var.project_name
  namespace    = var.project_name
  new_values = {
    "env" : var.env
    "application.image" : var.image_name
    "application.imageTag" : var.image_tag
    "application.baseURL" : var.base_url
    "application.logLevel" : var.log_level
  }

}
