# Laboratoire RKE2 mono-noeud
# Une cible = une etape. Rien d'implicite, rien de magique.
#
# Usage : make help
SHELL := /bin/bash
RKE2_VERSION     ?= v1.35.9+rke2r1
KYVERNO_VERSION  ?= 3.9.2
CONFIG_SRC       ?= .config/rke2-config.yaml
RKE2_CONF        := /etc/rancher/rke2
RKE2_BIN         := /var/lib/rancher/rke2/bin
KUBECONFIG       ?= $(HOME)/.kube/config

export KUBECONFIG
.PHONY: help base config rke2 start kubeconfig install apps kyverno policies verify reset

help:
	@echo "Cibles disponibles :"
	@echo "  make base        Prepare l'OS (swap, modules, sysctl, paquets)"
	@echo "  make config      Ecrit $(RKE2_CONF)/config.yaml"
	@echo "  make rke2        Installe RKE2 $(RKE2_VERSION)"
	@echo "  make start       Active et demarre le service"
	@echo "  make kubeconfig  kubectl dans le PATH + kubeconfig utilisateur"
	@echo "  make install     Enchaine base, config, rke2, start, kubeconfig"
	@echo "  make verify      Etat du cluster"
	@echo "  make reset       Detruit le cluster (FORCE=1)"

base:
	@echo "== prerequis systeme =="
	sudo swapoff -a
	sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab
	sudo apt-get update
	sudo apt-get install -y curl iptables
	printf 'overlay\nbr_netfilter\n' | sudo tee /etc/modules-load.d/rke2.conf
	sudo modprobe overlay
	sudo modprobe br_netfilter
	printf 'net.ipv4.ip_forward=1\nnet.bridge.bridge-nf-call-iptables=1\n' | sudo tee /etc/sysctl.d/90-rke2.conf
	sudo sysctl --system

config:
	sudo install -D -m 0600 $(CONFIG_SRC) $(RKE2_CONF)/config.yaml

rke2:
	@echo "== RKE2 $(RKE2_VERSION) =="
	curl -sfL https://get.rke2.io -o /tmp/rke2-install.sh
	sudo env INSTALL_RKE2_VERSION=$(RKE2_VERSION) INSTALL_RKE2_TYPE=server sh /tmp/rke2-install.sh

start:
	sudo systemctl enable --now rke2-server
	@echo "attente de l'API sur 6443..."
	@for i in $$(seq 1 120); do curl -sk -o /dev/null https://127.0.0.1:6443/readyz && break; sleep 5; done

kubeconfig:
	sudo ln -sf $(RKE2_BIN)/kubectl /usr/local/bin/kubectl
	sudo ln -sf $(RKE2_BIN)/crictl /usr/local/bin/crictl
	sudo ln -sf $(RKE2_BIN)/ctr /usr/local/bin/ctr
	install -d -m 0700 $(HOME)/.kube
	sudo install -m 0600 -o $$(id -u) -g $$(id -g) $(RKE2_CONF)/rke2.yaml $(KUBECONFIG)

install: base config rke2 start kubeconfig
	kubectl wait --for=condition=Ready node --all --timeout=300s


verify:
	kubectl get nodes -o wide
	kubectl get pods -A
	kubectl get svc -A

reset:
	@test "$(FORCE)" = "1" || { echo "Destructif : make reset FORCE=1"; exit 1; }
	-sudo rke2-killall.sh
	-sudo rke2-uninstall.sh
	sudo rm -rf $(RKE2_CONF) /var/lib/rancher/rke2
