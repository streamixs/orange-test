# Installation RKE2

## Prérequis

| Élément | Valeur |
|---|---|
| OS | Debian / Ubuntu |
| Machine | 2 vCPU, 4 Go RAM, 20 Go disque |
| IP | `192.168.1.169` |
| DNS | `boutique.lab.local` → `192.168.1.169` |
| Accès | `sudo` |

## Configuration

`.config/rke2-config.yaml` (non versionné) :

| Clé | Valeur |
|---|---|
| `node-name` | `rke2-node01` |
| `node-ip` | `192.168.1.169` |
| `ingress-controller` | `traefik` |
| `enable-servicelb` | `true` |
| `tls-san` | IP + `rke2-node01.lab.local` |

> Sans ce fichier, `make config` échoue. Un clone du dépôt ne le contient pas : `.config` est ignoré.

## Cibles Make

| Cible | Rôle |
|---|---|
| `make base` | swap, modules, sysctl, paquets |
| `make config` | copie la config dans `/etc/rancher/rke2` |
| `make rke2` | installe RKE2 `v1.35.9+rke2r1` |
| `make start` | active le service et attend l'API |
| `make kubeconfig` | kubectl + `~/.kube/config` |
| `make install` | enchaîne tout |
| `make verify` | nœuds, pods, services |
| `make reset FORCE=1` | détruit le cluster |

## Vérifier

```bash
make verify
kubectl get nodes -o wide
```

Attendu : `rke2-node01   Ready`.
