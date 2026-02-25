# Kubernetes Deployment Guide for Mimmis

This guide explains how to deploy the Mimmis application to a Kubernetes cluster.

## Prerequisites

1. **Kubernetes Cluster** (v1.24+)
   - Local: Minikube, Kind, or Docker Desktop
   - Cloud: GKE, EKS, AKS, or DigitalOcean Kubernetes

2. **kubectl** CLI tool installed and configured

3. **NGINX Ingress Controller** with ModSecurity enabled
   ```bash
   # Install NGINX Ingress Controller with WAF support
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
   
   # Enable ModSecurity
   kubectl edit configmap ingress-nginx-controller -n ingress-nginx
   # Add:
   #   enable-modsecurity: "true"
   #   enable-owasp-modsecurity-crs: "true"
   ```

4. **Container Image** for the backend API
   ```bash
   # Build the Docker image (using Harbor)
   cd be
   docker build -t your-registry/project/mimmis-api:latest .
   
   # Push to your container registry
   docker push your-registry/project/mimmis-api:latest
   
   # Update the image in kubernetes.yaml (line ~187)
   # image: your-registry/project/mimmis-api:latest
   ```

5. **(Optional) cert-manager** for automatic SSL certificates
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml
   ```

## Architecture Overview

### Components Deployed:

1. **PostgreSQL Database**
   - 1 replica (stateful)
   - Persistent volume (10Gi) for data storage
   - Internal ClusterIP service

2. **Backend API**
   - 3 replicas (horizontal scaling)
   - Auto-scaling (HPA): 3-10 replicas based on CPU/memory
   - Pod anti-affinity for high availability
   - Health checks (liveness/readiness probes)

3. **Ingress with WAF**
   - NGINX Ingress Controller
   - ModSecurity WAF with OWASP Core Rule Set
   - Rate limiting: 10 RPS, 100 requests/minute per IP
   - Security headers (HSTS, CSP, X-Frame-Options, etc.)
   - SSL/TLS termination

4. **Additional Resources**
   - ConfigMap for application configuration
   - Secret for sensitive data (passwords)
   - NetworkPolicies for pod-to-pod security
   - PodDisruptionBudget for availability during updates

## Deployment Steps

### 1. Update Configuration

Edit `kubernetes.yaml` and update the following:

- **Line 36-37**: Change database passwords in the Secret
  ```yaml
  DB_PASSWORD: "your-secure-password"
  POSTGRES_PASSWORD: "your-secure-password"
  ```

- **Line 187**: Update the API container image
  ```yaml
  image: your-registry/mimmis-api:latest
  ```

- **Line 326 & 330**: Replace domain names
  ```yaml
  - api.yourdomain.com  # Replace with your actual domain
  ```

- **Line 56** (Optional): Uncomment and set your storage class
  ```yaml
  storageClassName: standard  # gp2, gp3, standard, etc.
  ```

### 2. Deploy to Kubernetes

```bash
# Apply all resources
kubectl apply -f kubernetes.yaml

# Verify deployment
kubectl get all -n mimmis

# Check pod status
kubectl get pods -n mimmis -w

# Check ingress
kubectl get ingress -n mimmis
```

### 3. Verify Services

```bash
# Check PostgreSQL
kubectl exec -it -n mimmis deployment/postgres -- psql -U postgres -d mimmis -c "SELECT version();"

# Check API pods
kubectl logs -n mimmis -l app=mimmis-api --tail=100

# Test health endpoint
kubectl port-forward -n mimmis svc/mimmis-api-service 8080:80
curl http://localhost:8080/health
```

### 4. Configure DNS

Point your domain to the ingress controller's external IP:

```bash
# Get the external IP
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Create DNS A record:
# api.yourdomain.com -> <EXTERNAL-IP>
```

### 5. SSL/TLS Certificates

**Option A: Using cert-manager (Recommended)**

The ingress is already configured for cert-manager. Just create a ClusterIssuer:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

**Option B: Manual certificates**

```bash
# Create TLS secret with your certificates
kubectl create secret tls mimmis-tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n mimmis
```

## WAF Configuration

The ingress includes ModSecurity WAF with:

- **OWASP Core Rule Set**: Protection against common attacks
- **SQL Injection Detection**: Blocks SQLi attempts
- **XSS Protection**: Blocks cross-site scripting
- **Rate Limiting**: 
  - 10 requests/second
  - 100 requests/minute per IP
- **Request Body Limit**: 10MB
- **Security Headers**: HSTS, CSP, X-Frame-Options, etc.

### Monitoring WAF Events

```bash
# View ModSecurity logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller -f | grep ModSecurity
```

### Customize WAF Rules

Edit the `modsecurity-snippet` section in the ingress annotations (lines 287-297).

## Scaling

### Manual Scaling

```bash
# Scale API replicas
kubectl scale deployment mimmis-api -n mimmis --replicas=5
```

### Auto-Scaling (HPA)

The HorizontalPodAutoscaler is configured to:
- Maintain minimum 3 replicas
- Scale up to 10 replicas
- Scale based on CPU (70%) and memory (80%)

```bash
# Check HPA status
kubectl get hpa -n mimmis

# Describe HPA
kubectl describe hpa mimmis-api-hpa -n mimmis
```

## Monitoring and Troubleshooting

### View Logs

```bash
# API logs
kubectl logs -n mimmis -l app=mimmis-api -f

# PostgreSQL logs
kubectl logs -n mimmis -l app=postgres -f

# Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller -f
```

### Debug Pods

```bash
# Describe pod
kubectl describe pod -n mimmis <pod-name>

# Shell into API pod
kubectl exec -it -n mimmis <api-pod-name> -- /bin/sh

# Shell into PostgreSQL
kubectl exec -it -n mimmis <postgres-pod-name> -- psql -U postgres -d mimmis
```

### Check Resources

```bash
# Resource usage
kubectl top pods -n mimmis
kubectl top nodes

# Events
kubectl get events -n mimmis --sort-by='.lastTimestamp'
```

## Updates and Rollbacks

### Rolling Update

```bash
# Update the image
kubectl set image deployment/mimmis-api api=your-registry/mimmis-api:v2.0.0 -n mimmis

# Monitor rollout
kubectl rollout status deployment/mimmis-api -n mimmis
```

### Rollback

```bash
# View rollout history
kubectl rollout history deployment/mimmis-api -n mimmis

# Rollback to previous version
kubectl rollout undo deployment/mimmis-api -n mimmis

# Rollback to specific revision
kubectl rollout undo deployment/mimmis-api --to-revision=2 -n mimmis
```

## Backup and Restore

### Backup PostgreSQL

```bash
# Create backup
kubectl exec -n mimmis deployment/postgres -- pg_dump -U postgres mimmis > backup.sql

# Or use a CronJob for automated backups
```

### Restore PostgreSQL

```bash
# Restore from backup
kubectl exec -i -n mimmis deployment/postgres -- psql -U postgres mimmis < backup.sql
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f kubernetes.yaml

# Delete namespace (removes everything)
kubectl delete namespace mimmis

# Delete persistent volume claim (WARNING: deletes data)
kubectl delete pvc postgres-pvc -n mimmis
```

## Security Best Practices

1. **Secrets Management**: Use external secret managers (Vault, AWS Secrets Manager, Azure Key Vault)
2. **RBAC**: Implement role-based access control
3. **Network Policies**: Already configured for pod-to-pod isolation
4. **Image Scanning**: Scan container images for vulnerabilities
5. **Pod Security Standards**: Apply pod security policies/standards
6. **Regular Updates**: Keep Kubernetes and container images updated
7. **Monitoring**: Implement logging and monitoring (Prometheus, Grafana, ELK)

## Production Considerations

- [ ] Configure persistent storage class for your cloud provider
- [ ] Set appropriate resource limits based on load testing
- [ ] Configure backup strategy for PostgreSQL
- [ ] Set up monitoring and alerting
- [ ] Configure log aggregation
- [ ] Implement CI/CD pipeline for automated deployments
- [ ] Use secrets management solution
- [ ] Configure database replication for HA (consider PostgreSQL operator)
- [ ] Test disaster recovery procedures
- [ ] Review and tune WAF rules based on application behavior
