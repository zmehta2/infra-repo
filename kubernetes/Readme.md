# Student Support Microservices - EKS Deployment Guide

This document provides an overview of the Student Support microservices deployed on Amazon EKS (Elastic Kubernetes Service) along with best practices for deployment, service management, and blue-green deployment workflows.

## Architecture Overview

The Student Support platform consists of the following microservices:

- **API Gateway**: Entry point for all client requests
- **Chat Service**: Handles real-time chat functionality
- **FAQ Service**: Manages frequently asked questions
- **University Chatbot UI**: Frontend application for student interactions

These services are deployed on Amazon EKS using Argo Rollouts for blue-green deployments.

## Prerequisites

- Access to the AWS console with appropriate permissions
- `kubectl` CLI tool configured to access the EKS cluster
- Helm package manager
- AWS CLI configured with appropriate credentials

## Deployment Guide

### 1. Setting Up Backend Services

Each backend service follows a similar deployment pattern using Argo Rollouts for blue-green deployments.

#### API Gateway Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: api-gateway
  namespace: production
spec:
  replicas: 2
  strategy:
    blueGreen:
      activeService: api-gateway
      previewService: api-gateway-preview
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: 465776424604.dkr.ecr.us-east-1.amazonaws.com/student-support/api-gateway:[TAG]
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: "100m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

Apply with:
```bash
kubectl apply -f api-gateway.yaml
```

#### Similar configurations are used for Chat Service and FAQ Service

### 2. Frontend Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: university-chatbot-ui
  namespace: production
spec:
  replicas: 2
  strategy:
    blueGreen:
      activeService: university-chatbot-ui-active
      previewService: university-chatbot-ui-preview
  selector:
    matchLabels:
      app: university-chatbot-ui
  template:
    metadata:
      labels:
        app: university-chatbot-ui
    spec:
      containers:
        - name: university-chatbot-ui
          image: 465776424604.dkr.ecr.us-east-1.amazonaws.com/student-support/university-chatbot-ui:[TAG]
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
```

Apply with:
```bash
kubectl apply -f university-chatbot-ui.yaml
```

### 3. Service Deployment

For each service, create corresponding service resources.

Example for frontend:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: university-chatbot-ui-active
  namespace: production
spec:
  selector:
    app: university-chatbot-ui
  ports:
    - port: 3000
      targetPort: 3000
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: university-chatbot-ui-preview
  namespace: production
spec:
  selector:
    app: university-chatbot-ui
  ports:
    - port: 3000
      targetPort: 3000
  type: ClusterIP
```

### 4. Ingress Configuration

Create an Ingress resource to expose the frontend:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: university-chatbot-ui
  namespace: production
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: university-chatbot-ui-active
                port:
                  number: 3000
```

Save as `university-chatbot-ui-ingress.yaml` and apply:
```bash
kubectl apply -f university-chatbot-ui-ingress.yaml
```

## Installing AWS Load Balancer Controller

The AWS Load Balancer Controller is required for the Ingress resource to create an ALB:

```bash
# Add the EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install the AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=student-support-cluster \
  --set serviceAccount.create=true \
  --set region=us-east-1 \
  --set vpcId=$(aws eks describe-cluster --name student-support-cluster --query "cluster.resourcesVpcConfig.vpcId" --output text)
```

## Blue-Green Deployment Workflow

### Promoting a New Version

1. Update the image tag in the rollout manifest
2. Apply the updated manifest
3. Verify the new version in the preview environment
4. Promote the rollout when ready:

```bash
kubectl argo rollouts promote university-chatbot-ui -n production
```

### Monitoring Rollouts

Check the status of a rollout:

```bash
kubectl argo rollouts get rollout university-chatbot-ui -n production
```

## Best Practices

### Namespace Management
- Use separate namespaces for different environments (qa, production)
- Apply resource quotas to namespaces to prevent resource contention

### Observability
- Configure Prometheus for metrics collection
- Set up proper logging with Elasticsearch or CloudWatch
- Implement distributed tracing

### Security
- Implement network policies to restrict traffic between services
- Use IAM roles for service accounts where possible
- Regularly update container images to patch vulnerabilities

### Scaling
- Configure Horizontal Pod Autoscalers (HPA) for each service
- Consider setting up Cluster Autoscaler for node scaling

## Troubleshooting

### Common Issues

1. Pods stuck in pending state:
   - Check node capacity
   - Verify node selectors/affinity

2. Service connectivity issues:
   - Ensure service names are correctly referenced
   - Check namespace-specific DNS entries

3. Load balancer not provisioning:
   - Verify AWS Load Balancer Controller is running
   - Check IAM permissions

## Maintenance

### Updating Kubernetes Version

Follow AWS documentation for updating EKS clusters:
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

### Backup and Restore

Consider using tools like Velero for backup and restore of Kubernetes resources:
https://velero.io/

## Contact

For more information or assistance, contact the DevOps team.
