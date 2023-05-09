# AKS + ACR Private

## Deploy Infrastructure

```sh
cd terraform

# Make sure you change the tfvars to your needs
terraform init
terraform apply
```

## Connect to JumpBox VM

When terraform completes, the final outputs should show all the information to connect to the jumpbox VM.

```sh
terraform output -raw vm_ssh_private_key > ~/.ssh/id_rsa_jumpboxvm

vm_ip=$(terraform output -raw vm_public_ip)

chmod 400 ~/.ssh/id_rsa_jumpboxvm
ssh -i ~/.ssh/id_rsa_jumpboxvm azureuser@${vm_ip}
```

## Run the following inside the VM

- Get the az cli:
```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

- Get kubectl and AKS Credentials:
```sh
SUB_ID=<subscrition_id>
RG_NAME=playground-aks-acr-private
AKS_NAME=aks-acr-private

sudo az aks install-cli

az account set -s $SUB_ID
az aks get-credentials --resource-group $RG_NAME --name $AKS_NAME --public-fqdn
```

- Install [Docker for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

- Follow [this guide to push an image to ACR](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli)

```sh
$ az acr login --name acrprivatetyz
Login Succeeded

$ az acr import -n $acrName --source mcr.microsoft.com/oss/nginx/nginx:1.21.4 --image nginx:1.21.4
```

- Create a deployment using the imported image to ACR
```sh
k create deploy nginx-acr-private --image=acrprivatetyz.azurecr.io/nginx:1.21.4
```