# 1) Provision AKS in Azure via az cli

az aks create --resource-group test-rg  --name newAksCluster  --node-count 2  --enable-addons monitoring  --kubernetes-version 1.17.3  --generate-ssh-keys   --windows-admin-password P@ssw0rd1234 --windows-admin-username azureuser  --vm-set-type VirtualMachineScaleSets  --load-balancer-sku standard  --network-plugin azure
az aks get-credentials --resource-group test-rg --name newAksCluster

# 2) Create nginx-ingress controller

kubectl create namespace nginx-ingress
helm upgrade --install nginx-ingress stable/nginx-ingress --namespace nginx-ingress

# 3) Create jenkins app via helm

kubectl create namespace jenkins
helm install jenkins stable/jenkins -n live-demo  -f ./jenkins-values-demo.yaml --namespace jenkins
$pwd = kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Pwd))

# 4) Create cert-manager app via helm

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
kubectl create namespace cert-manager
helm install my-cert jetstack/cert-manager --namespace cert-manager

# 5) apply ingress rules

#make sure cert manager is up and running before executing the below command
kubectl apply -f .\cluster-issuer.yaml
kubectl apply -f .\jenkins-ingress.yaml

# 6) check the external ip of your ingress
kubectl get svc -n nginx-ingress

# 7) other useful commands

kubectl get pods -n cert-manager
kubectl get cert -n jenkins
kubectl get ingress -n jenkins
kubectl get certificate -n jenkins