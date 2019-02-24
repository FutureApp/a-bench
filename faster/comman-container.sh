
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
-i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip)

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -C2qTnN -D 8080 -i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip)
minikube service list