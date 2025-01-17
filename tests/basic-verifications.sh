# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name dev-cluster

# Verify Nodes
kubectl describe nodes | grep -i taint
kubectl describe nodes | grep -i condition -A 5

# Verify connection
kubectl get nodes
kubectl get pods -A

# Verify addons
# Metrics Server
kubectl get deployment metrics-server -n kube-system
kubectl top nodes  # Si funciona, metrics-server está operativo

# AWS Load Balancer Controller
kubectl get deployment aws-load-balancer-controller -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# External DNS
kubectl get deployment external-dns -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/name=external-dns

# Cluster Autoscaler
kubectl get deployment cluster-autoscaler -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler

# Autoscaling test
# Create a deployment with 10 replicas
kubectl create deployment test-autoscaler --image=nginx
kubectl scale deployment test-autoscaler --replicas=10

# Verify nodes autoscaling
kubectl get nodes -w

# Load Balancer test
# Create a service of type LoadBalancer
kubectl create deployment test-lb --image=nginx
kubectl expose deployment test-lb --port=80 --type=LoadBalancer

# Verify Load Balancer
kubectl get svc test-lb -w

# Verify Load Balancer DNS
kubectl create ingress test-dns --rule="test.lroquec.com/*=test-service:80"

# Verify Route 53 record
aws route53 list-resource-record-sets --hosted-zone-id <TU_HOSTED_ZONE_ID> | grep test.lroquec.com

# Users and Roles test
aws eks get-token --cluster-name dev-cluster --role-arn <ADMIN_ROLE_ARN>
kubectl auth can-i "*" "*"  # Should return yes

# Developer role
aws eks get-token --cluster-name dev-cluster --role-arn <DEVELOPER_ROLE_ARN>
kubectl auth can-i create pod -n kube-system # Should return no
kubectl auth can-i create pod -n dev # Should return yes

# Viewer role
aws eks get-token --cluster-name dev-cluster --role-arn <READONLY_ROLE_ARN>
kubectl auth can-i get pods -A  # Should return yes
kubectl auth can-i create pod default # Should return no

# Logs and events
# Verify logs from critical components
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl logs -n kube-system -l app.kubernetes.io/name=external-dns
kubectl logs -n kube-system -l app.kubernetes.io/name=cluster-autoscaler

# Verify events
kubectl get events -A --sort-by='.lastTimestamp'

# Cleanup
kubectl delete deployment test-autoscaler
kubectl delete deployment test-lb
kubectl delete service test-lb
kubectl delete ingress test-dns