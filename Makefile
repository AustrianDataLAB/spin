.PHONY: build
build:
	spin build -u --sqlite="@migration.sql"

.PHONY: kind
kind:
	-kind create cluster --name spin
	-kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.crds.yaml
	-kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.yaml 
	-helm repo add kwasm http://kwasm.sh/kwasm-operator/
	-helm repo update
	-helm upgrade --install kwasm-operator kwasm/kwasm-operator --namespace kwasm  --create-namespace  --set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v0.14.1
	-kubectl annotate node --all kwasm.sh/kwasm-node=true

.PHONY: spin-operator
spin-operator:
	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.crds.yaml
	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.runtime-class.yaml
	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.shim-executor.yaml
	-helm upgrade --install spin-operator --namespace spin-operator --create-namespace  --version 0.2.0 --wait oci://ghcr.io/spinkube/charts/spin-operator
	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.crds.yaml


.PHONY: application
application:
	-git clone https://github.com/spinkube/spin-operator.git
	-cd spin-operator/apps/variable-explorer
	-spin build
	-spin registry push ttl.sh/variable-explorer:1h
	-kubectl apply -f ../../config/samples/variable-explorer.yaml
	-echo "you need to now run "kubectl port-forward services/variable-explorer 8080:80 , curl http://localhost:8080"
	-kubectl logs -l core.spinoperator.dev/app-name=variable-explorer
