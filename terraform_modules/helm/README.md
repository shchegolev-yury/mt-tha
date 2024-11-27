## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.9.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.16.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.16.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_path"></a> [chart\_path](#input\_chart\_path) | Path to the chart (local/full URL). | `string` | `"./.helm"` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether or not to create a namespace. | `bool` | `true` | no |
| <a name="input_helm_lint"></a> [helm\_lint](#input\_helm\_lint) | Whether or not to lint helm chart on plan stage. | `bool` | `true` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig. | `string` | `"~/.kube/config"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name to install chart. | `string` | `"default"` | no |
| <a name="input_new_values"></a> [new\_values](#input\_new\_values) | New values in case of not using values.yaml file. | `map(string)` | `{}` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Name of Helm release to be installed. | `string` | n/a | yes |

## Outputs

No outputs.
