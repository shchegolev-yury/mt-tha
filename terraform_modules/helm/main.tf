resource "helm_release" "this" {
  name             = var.release_name
  chart            = var.chart_path
  create_namespace = var.create_namespace
  lint             = var.helm_lint
  namespace        = var.namespace
  dynamic "set" {
    for_each = var.new_values
    content {
      name  = set.key
      value = set.value
    }
  }
}