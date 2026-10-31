# Dépannage

## Diagnostic

```bash
make verify
kubectl -n online-boutique get pods,svc,ingress
kubectl -n kyverno get pods
```

## Erreurs connues

| Symptôme | Cause | Correction |
|---|---|---|
| Erreur Helm / chart introuvable | `--enable-helm` absent | `kustomize build --enable-helm ...` |
| Labels absents sur les Pods | policy non déclenchée ou RBAC manquant | `kubectl auth can-i patch pods -n online-boutique --as=system:serviceaccount:kyverno:kyverno-background-controller` |
| Ingress 404 | host ou ingressClass incorrect | vérifier `boutique.lab.local` et `ingressClassName: traefik` |

## Reset

```bash
make reset FORCE=1
```
