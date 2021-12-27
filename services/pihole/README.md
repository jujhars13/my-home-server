# Setup Pihole on k8s

Based on this [MoJo2600/pihole-kuberneteshelm chart](https://github.com/MoJo2600/pihole-kubernetes)

See [blog post](https://greg.jeanmart.me/2020/04/13/self-host-pi-hole-on-kubernetes-and-block-ad/) for instructions


## Steps

```bash

# create namespace
kubectl apply -f pihole-01-ns.yml

# create persistent volume
kubectl apply -f pihole-02-persistent-volume.yml

# create persistent volume claim in namespace
kubectl apply -f pihole-03-persistent-volume-claim.yml

# verify so far
kubectl get pvc -n pihole

# install chart
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/ 
helm repo update

# install secret
kubectl create secret generic pihole-secret \
    --from-literal='password=$(< /vagrant/secrets/pihole-secret)>' \
    --namespace pihole

# install chart
helm install pihole mojo2600/pihole \
  --namespace pihole \
  --values pihole-04-chart-values.yml

```