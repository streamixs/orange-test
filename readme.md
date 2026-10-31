# Lab RKE2 — Online Boutique + Kyverno

Cluster Kubernetes **mono-nœud** RKE2 sur `192.168.1.169` :

- **Online Boutique** exposé par Traefik sur `boutique.lab.local`
- **Kyverno** pour la mutation des Pods

## Architecture

```text
boutique.lab.local
        │
        ▼
ServiceLB → Traefik (Ingress) → frontend:80
                                   │
                       ns online-boutique (11 microservices)

ns kyverno — chart 3.9.2 / Kyverno 1.19.2
```

## Démarrage rapide

```bash
make install                                # OS + RKE2 + kubeconfig
kustomize build --enable-helm apps/kyverno | kubectl apply --server-side --force-conflicts -f -
kubectl apply -k apps/online-boutique
```

Accès : `http://boutique.lab.local` → `192.168.1.169`

## Docs

| Doc | Contenu |
|---|---|
| [Installation](docs/install.md) | Prérequis, cibles Make, vérification |
| [Déploiement](docs/deploy.md) | Kyverno, Online Boutique, Ingress |
| [Dépannage](docs/troubleshooting.md) | Diagnostic et erreurs connues |

## Cadrage de l'exercice

_(à compléter)_

## Livrables attendus

_(à compléter)_
