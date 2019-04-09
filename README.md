This repo is for Juvo's pod autoscaling challenge
To start, make sure you have aws cli, terraform, kubectl, aws iam authenticator and helm installed
1. initialize terraform
> terraform init
2. start terraform
> terraform apply
3. get kubeconfig output from terraform and change your kubeconfig file from your kubectl install directory 
> terraform output kubeconfig > kubeconfig
4. At this point, verify your kubectl is connected to your eks arn by checking
> kubectl get all
5. get cofigmap from terraform and apply it to kubectl
> terraform output config-map-aws-auth > aws-auth.yaml
> kubectl apply -f aws-auth.yaml
6. Now you will need to deploy a metrics server using helm
> helm install stable/metrics-server --name metrics-server --version 2.0.4 --namespace metrics
7. now for sample apps we will use php-apache pod for demo
> kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80
> kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
> kubectl get hpa
8. To hit the apache server, we will create a load-generator using busybox image
> kubectl run -i --tty load-generator --image=busybox /bin/sh
> while true; do wget -q -O - http://php-apache; done
9. Now monitor hpa usage of your php-apache server
> kubctl get hpa -w
