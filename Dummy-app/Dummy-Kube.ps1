# 1) Provision AKS in Azure via az cli

az aks create --resource-group test-rg  --name testzAksCluster  --node-count 2  --enable-addons monitoring  --kubernetes-version 1.17.3  --generate-ssh-keys   --windows-admin-password P@ssw0rd1234 --windows-admin-username azureuser  --vm-set-type VirtualMachineScaleSets  --load-balancer-sku standard  --network-plugin azure
az aks get-credentials --resource-group test-rg --name testzAksCluster

# 2) Create nginx-ingress controller

kubectl create namespace nginx-ingress
helm upgrade --install nginx-ingress stable/nginx-ingress --namespace nginx-ingress

# 3) Create dummy hello-world app

kubectl create namespace dummy-app
kubectl apply -f .\deployment.yaml
kubectl apply -f .\service.yaml

# 4) Create cert-manager app via helm

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
kubectl create namespace cert-manager
helm install my-cert jetstack/cert-manager --namespace cert-manager

# 5) apply ingress rules
kubectl apply -f .\cluster-issuer.yaml
kubectl apply -f .\dummy-ingress.yaml

# 6) check the external ip of your ingress
kubectl get svc -n nginx-ingress

# 7) other useful commands

kubectl get pods -n cert-manager
kubectl get cert -n dummy-app
kubectl get ingress -n dummy-app