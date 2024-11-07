This project assumes you have a new, empty project created. Assuming this is the case, then review varaibles and run the terraform apply to get your attached cluster:

```bash

cat variables.tf # to review defaults

terraform init
terraform plan
terraform apply

# explore directly going to
TFSTATE_REGION=$(echo var.aws_region | terraform console | sed s/\"//g)
TFSTATE_CLUSTER=$(echo aws_eks_cluster.eks.name | terraform console | sed s/\"//g)
aws eks update-kubeconfig --region ${TFSTATE_REGION} --name ${TFSTATE_CLUSTER}
kubectl get ns


# explore via GCP

TFSTATE_PROJECT=$(echo var.fleet_project | terraform console | sed 's/"//g')
TFSTATE_CLUSTER=$(echo google_container_attached_cluster.primary.name | terraform console | sed 's/"//g')

gcloud container fleet memberships get-credentials --project=${TFSTATE_PROJECT} ${TFSTATE_CLUSTER}


```

