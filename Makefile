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

.PHONY: wasmtime
wasmtime:
	-git clone https://github.com/sunfishcode/hello-wasi-http.git
	-cd hello-wasi-http
	-cargo install wasmtime-cli wasm-tools cargo-component
	-cargo component build
	-wasm-tools component wit ~/gitrepos/fermyon/spin/hello-wasi-http/target/wasm32-wasi/debug/hello_wasi_http.wasm
	-wasmtime serve -Scommon ~/gitrepos/fermyon/spin/hello-wasi-http/target/wasm32-wasi/debug/hello_wasi_http.wasm


.PHONY: llm
llm:
	-git clone git@github.com:LlamaEdge/LlamaEdge.git
	-cd LlamaEdge &&chmod +x run-llm.sh && ./run-llm.sh

.PHONY: wash-mac 
wash-mac:
	brew install wasmcloud/wasmcloud/wash

.PHONY: componentmodeldemo
componentmodeldemo:
	-git clone https://github.com/fermyon/http-auth-middleware.git
	-cd http-auth-middleware && cargo install --git https://github.com/bytecodealliance/cargo-component --tag v0.4.0 cargo-component --locked && cargo component  build --manifest-path github-oauth/Cargo.toml --release
	- echo " you must set the github OAuth app in your GitHub Developer Settings "
	- echo "spin up --build -f example -e CLIENT_ID=<YOUR_GITHUB_APP_CLIENT_ID> -e CLIENT_SECRET=<YOUR_GITHUB_APP_CLIENT_SECRET>"