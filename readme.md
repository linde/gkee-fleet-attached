

## GKE Enterprise Attached and Fleet Defaults Playground Environment

The following helps demonstrate how GKE Enterprise Attached Clusters can work with EKS. It assumes you have a new, empty project created. This can be set in [`variables.tf`](terraform/variables.tf), but defaults for my benefit to `stevenlinde-eks-2024-11-01`. 

To get things going, set that value and review other varaibles, then run the terraform apply to get your attached cluster:

```bash

vim variables.tf # to review defaults

terraform init
terraform plan
terraform apply

```

## Exploring

You can explore what was created via the GCP Cloud Console as follows:

* [Clusters](https://pantheon.corp.google.com/kubernetes/list/overview?project=stevenlinde-eks-2024-11-01) 
* [Workloads](https://pantheon.corp.google.com/kubernetes/workload/overview?project=stevenlinde-eks-2024-11-01) 
    * From here you could shedule a deployment directly via the UI
    * Or via gitops, then check status of packages via [ConfigSync](https://pantheon.corp.google.com/kubernetes/config_management/packages?project=stevenlinde-eks-2024-11-01) status

Additionally, you can use SSO and interact directly via k8s, even without line of sight to the admin cluster:

```bash
# explore via GCP

TFSTATE_PROJECT=$(echo var.fleet_project | terraform console | sed 's/"//g')
TFSTATE_CLUSTER=$(echo google_container_attached_cluster.primary.name | terraform console | sed 's/"//g')

gcloud container fleet memberships get-credentials --project=${TFSTATE_PROJECT} ${TFSTATE_CLUSTER}


```

