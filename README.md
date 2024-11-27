# Solution
1. The application code has been updated to include two new endpoints for liveness and readiness probes.
2. A Dockerfile has been created for the application.
3. A Helm chart has been developed and stored in the .helm folder. A default values.yaml file has also been created. This chart can be used for different environments (DTAP)
4. Terraform files (main.tf, versions.tf, and variables.tf) have been created in the ${repo_root} to install the application.
5. A simple shell script (deploy.sh) has been created to emulate the CI/CD pipeline.
6. A Simple terraform module to manage Helm release.
NOTE: for this exercise I commited "sensitive" data to the secret template. In the real world I would never do anything 
like this and use some secrets engine like External Secrets Operator. 

## How it works
### Prerequisites:
1. You need to be authenticated against the Kubernetes cluster and select the appropriate context, as the Helm module 
uses the ~/.kube/config file by default (though this can be parameterized). In a real-world scenario, 
I would typically handle this in the pipeline configuration by providing variables or utilizing secrets management tools.
2. You need to be authenticated against the container registry (CR) of your choice in order to push a publicly available image.
3. Terraform version ~> 1.9.8 must be installed.
4. Docker must be installed and running.
5. You need to have a Minikube cluster with the Ingress and Metrics addons enabled. While it will also work on other 
clusters, the NGINX Ingress Controller must be used.
### How to run 
run deploy.sh script, with the IMAGE_NAME, IMAGE_TAG, RELEASE_NAME, BASE_URL, ENVIRONMENT parameters 
(for the example I'll use `cardiffc/*` repo on dockerhub) and minikube.com as a base URL. 
```zsh
./deploy.sh cardiffc/mytomorrows ver1 mytomorrows-api minikube.com staging
```
What will happen:
1. Build and push a Docker image for the application.
2. Run `terraform init`.
3. Create a `terraform.tfvars` file. This file does not contain any sensitive data and is only needed to run `terraform destroy` 
in the future.
4. Run `terraform apply`, using the Helm module and substituting the variables with their actual values.
5. The Helm chart will be rendered with values depending on the environment and propagated configurations. 
6. The Helm chart will be installed to the namespace called after project name, and the application will be exposed through the ingress controller.

### How to test
1. If you're running on a Minikube cluster you need to:
    1.1 Add your FQDN (e.g., `minikube.com` in my case) to the `/etc/hosts` file on your laptop.
    1.2 Run port-forward to access applications exposed by the Ingress controller on the Minikube cluster.
    ```zsh
   kubectl port-forward -n kube-system service/ingress-nginx-controller 8080:80 -n ingress-nginx
   ```
2. ```zsh
    curl http://minikube.com:8080/config
    ```
It will return the config entry from the API. (Note: Since this is just an exercise, I'm using HTTP, but in a real-world scenario, I would use HTTPS, and certificate issuance can be automated by integrating the Ingress controller with Cert Manager.)

### How to destroy
```zsh
terraform destroy --auto-approve
```

### Explain the networking strategy you would adopt to deploy production ready applications on AWS.
In the case of running the app in production on an AWS EKS cluster, I would use the ALB Ingress Controller. On the AWS side, I would consider using AWS Shield Advanced (since Shield Standard is already implemented), AWS WAF, and AWS CloudFront (optional, depending on the use case).
The traffic flow would look like this:
`User → CloudFront → AWS WAF → ALB → PODs`
On the Helm chart side, we can tune Horizontal Pod Autoscalers (HPAs) to scale up and down depending on typical traffic 
patterns for our application. We can also parameterize the number of workers for Gunicorn. To fine-tune all of this, 
I need to become more familiar with the specific requirements and realities of the application.

### Describe how you would implement a solution to grant access to various AWS services to the deployed application.
1. I'll create an IAM role to be consumed by the application via OIDC. Example:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRoleWithWebIdentity"],
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/<PROVIDER>"
      }
    }
  ]
}
```
2. I'll create IAM policy, allowing the access and attach it to the role
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [<ACTIONS_LIST>],
      "Resource": [<RESOURCE_ARN>]
    }
  ]
}
```
3. I'll need to modify Helm Chart to be able to do it on each deployment. The modifications are:<br> 
3.1 Service account template with role annotation.<br>
3.2 Service account usage in the deployment.
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Chart.Name }}
  annotations:
    eks.amazonaws.com/role-arn: {{ .Values.application.roleARN }}
```
### Describe how would you automate deploying the solution across multiple environments using CI/CD.
In general:
1. I'll completely remove the shell script, as static analysis, image build, and push will be executed in the pipeline steps.
2. Getting rid of Terraform in favor of implementing a GitOps approach (with ArgoCD/FluxCD) for deploying Helm charts could
also be beneficial, as it provides much more control over application states. For example, if something goes wrong with 
the deployment configuration, Terraform won’t be able to fix that. Additionally, with ArgoCD, it’s possible to implement 
release practices like blue/green deployments. As for the pipeline, it can be implemented using GitHub Actions, GitLab CI,
or any other system.
3. On commit, run static tests via the runner, build and deploy the app to the dev environment, consuming everything from the pipeline environment, and tag the image with the SHA of the commit, etc.
4. On PR, do the same, but for the staging environment, using PR id as image tag.
5. On main (PR merge), deploy to prod (this can be a manual step to avoid accidentally ruining prod and to release only during release windows).
The exact implementation of CI/CD processes depends on the development workflow established in the company.
### Explain how scalability, availability, security, and fault tolerance are addressed in the solution.
1. In the Helm chart, HPA is implemented with different default parameters based on the environment. These can be tuned 
if needed. Not only the CPU metric is implemented, but other metrics (such as memory consumption or any custom metric) 
can be easily added. This way, the application will scale up and down based on resource consumption. 
We should also ensure the EKS cluster can scale up and down (preferably via the Karpenter operator).
2. The application is highly available, as it has, at a minimum, 2 replicas and podAntiAffinity. We should spread EKS 
worker nodes across AZs so that, even if some nodes fail, the application will still be up and running. It also has a 
Pod Disruption Budget (PDB), which prevents Kubernetes from destroying all pods. This can also be tuned.
### Suggest any potential enhancements that could be made to improve the overall solution.
1. I'm not using HTTPS at all since I'm running on a Minikube cluster just for testing.
2. Secret values are hardcoded and committed to Git — never do this in real life. External secret storage should be used instead.
3. The Helm chart can be improved:<br>
  3.1 More flexibility in resources.<br>
  3.2 Network policy (if needed).<br> 
  3.3 Ability to attach service accounts (SAs).<br>
  3.4 Helm test hooks can be implemented.<br>
  3.4 Ability to use TLS certificates and different ingress classes (for example, if we want to use different ingress controllers for internal and external deployments).
4. The Helm Terraform module can be improved with more flexibility. For example, as of now, it does not allow substituting values from a custom file.
5. The application itself can be improved by listening on a port specified by a variable.
# Conclusion
Please note that this is just a simple example and it can be significantly improved in real life.<br>
I didn't install the basic Promstack from this code because, to set it up properly, the cluster needs to be correctly configured (e.g., domains, SSL, etc.). While it's not an issue to just run a simple script to install the Helm chart, it requires a lot of configuration to run it properly.