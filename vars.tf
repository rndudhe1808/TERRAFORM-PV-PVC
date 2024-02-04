variable "pv_name" {
  default = "example-volumename"
}

variable "pvc_name" {
  default = "example-claimname"
}

variable "deployment_name_my_app" {
  default = "my-app-deployment"
}

variable "deployment_name_wordpress" {
  default = "wordpress-deployment"
}

variable "service_name_wordpress" {
  default = "wordpress-service"
}
#Firstly Configured the NFS System and change in nfs section of main.tf
#then just do terraform init and terraform plan
#teraform command for custom variable "terraform apply -var="pv_name=task-pv" -var="pvc_name=task-pvc" -var="deployment_name_my_app=db-dep" -var="deployment_name_wordpress=wp-dep" -var="service_name_wordpress=wp-svc" -auto-approve"
