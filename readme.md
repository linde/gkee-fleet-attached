

## GKE Enterprise Attached and Fleet Defaults Playground Environment

The following helps demonstrate how GKE Enterprise Attached Clusters can work with EKS. It assumes you have a new, empty project created. This can be set in [`variables.tf`](terraform/variables.tf), but defaults for my benefit to `stevenlinde-eks-2024-11-01`. 

To get things going, set that value and review other varaibles, then run the terraform apply to get your attached cluster:

```bash

vim variables.tf # to review defaults

terraform init
terraform plan
terraform apply



# explore via GCP

TFSTATE_PROJECT=$(echo var.fleet_project | terraform console | sed 's/"//g')
TFSTATE_CLUSTER=$(echo google_container_attached_cluster.primary.name | terraform console | sed 's/"//g')

gcloud container fleet memberships get-credentials --project=${TFSTATE_PROJECT} ${TFSTATE_CLUSTER}


```

