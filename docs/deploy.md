# Déploiement

## 1. Kyverno

```bash
kustomize build --enable-helm apps/kyverno | kubectl apply --server-side --force-conflicts -f -
kubectl -n kyverno rollout status deploy/kyverno-admission-controller
kubectl -n kyverno rollout status deploy/kyverno-background-controller
```

`--enable-helm` est obligatoire : le chart est déclaré dans `kustomization.yaml`.
Ce kustomization installe aussi la politique de mutation (`mutatingPolicies.yaml`) et le ClusterRole `background-pods-rbac.yaml` (patch des Pods par le background controller).

## 2. Online Boutique

```bash
kubectl apply -k apps/online-boutique
kubectl -n online-boutique get pods
```

Le kustomization :

- déploie le manifest upstream (11 microservices) ;
- supprime `frontend-external` (Service LoadBalancer) ;
- ajoute l'Ingress Traefik.

## 3. Accès

```bash
curl -H 'Host: boutique.lab.local' http://192.168.1.169/
```

Navigateur : `http://boutique.lab.local`

## Politique de mutation

`apps/kyverno/mutatingPolicies.yaml` ajoute aux Pods de `online-boutique` :

| Label | Valeur |
|---|---|
| `app.kubernetes.io/managed-by` | `Kyverno` |
| `namespace-name` | namespace du Pod |
| `node-name` | nœud réel du Pod (après scheduling) |

| Champ | Rôle |
|---|---|
| `matchConstraints` | déclencheur : `pods/status` en UPDATE |
| `targetMatchConstraints` | cibles : les Pods du namespace |

```bash
kubectl -n online-boutique get pods --show-labels
```

> La politique utilise `mutateExisting` : elle s'exécute **après scheduling**, quand `spec.nodeName` est rempli. Les labels apparaissent dès que le kubelet remonte le statut du Pod.
>
> `background-pods-rbac.yaml` autorise le background controller à patcher les Pods.
