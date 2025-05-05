# MongoDB Setup for University Chatbot

This guide details the steps to set up MongoDB in a Kubernetes environment for the University Chatbot project. This is an MVP setup focusing on simplicity rather than persistence or high availability.

## Prerequisites

- Kubernetes cluster (such as EKS) up and running
- `kubectl` configured to communicate with your cluster
- Helm installed (if using the AWS EBS CSI driver)

## 1. Create MongoDB Secret

The MongoDB secret stores credentials that will be used by the MongoDB instance and connecting applications.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-secret
  labels:
    app: mongodb
type: Opaque
data:
  mongo-username: WmluYWw=     # Base64 encoded "Zinal"
  mongo-password: WmluYWwxMjM0  # Base64 encoded "Zinal1234"
```

Save this as `mongodb-secret.yaml` and apply:

```bash
kubectl apply -f mongodb-secret.yaml
```

## 2. Create MongoDB Service

The service provides a stable network endpoint for MongoDB within the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  labels:
    app: mongodb
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongodb
```

Save this as `mongodb-service.yaml` and apply:

```bash
kubectl apply -f mongodb-service.yaml
```

## 3. Deploy MongoDB

For an MVP setup, we use a simple Deployment with an emptyDir volume (data will be lost if the pod restarts).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  labels:
    app: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
        - name: mongodb
          image: mongo:4.4
          ports:
            - containerPort: 27017
          env:
            - name: MONGO_INITDB_ROOT_USERNAME
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: mongo-username
            - name: MONGO_INITDB_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: mongo-password
          volumeMounts:
            - name: mongodb-data
              mountPath: /data/db
      volumes:
        - name: mongodb-data
          emptyDir: {}
```

Save this as `mongodb-deployment.yaml` and apply:

```bash
kubectl apply -f mongodb-deployment.yaml
```

## 4. Verify MongoDB Deployment

Check if the MongoDB pod is running:

```bash
kubectl get pods -l app=mongodb
```

Expected output:
```
NAME                       READY   STATUS    RESTARTS   AGE
mongodb-xxxxxxxxxx-xxxxx   1/1     Running   0          XXs
```

## 5. Connect to MongoDB

You can connect to MongoDB in several ways:

### Option 1: Using a temporary client pod

```bash
kubectl run mongodb-client --rm -it --image=mongo:4.4 -- bash
```

Once inside the pod's shell:

```bash
mongo mongodb://mongodb:27017 -u Zinal -p Zinal1234 --authenticationDatabase admin
```

### Option 2: Port forwarding

If port 27017 is already in use on your local machine, use a different local port:

```bash
kubectl port-forward svc/mongodb 27018:27017
```

Then connect using a locally installed MongoDB client:

```bash
mongo mongodb://localhost:27018 -u Zinal -p Zinal1234 --authenticationDatabase admin
```

## 6. Verify MongoDB Functionality

Once connected to the MongoDB shell, you can run these commands to verify it's working properly:

```
# List databases
show dbs

# Create a test database
use testdb

# Insert a document
db.test.insertOne({ name: "test document", value: 123 })

# Query the document
db.test.find()

# Exit the MongoDB shell
exit
```

## Connection String for Applications

Use the following connection string in your microservices to connect to MongoDB:

```
mongodb://Zinal:Zinal1234@mongodb:27017/universitychatbot?authSource=admin
```

## Note for Production

For a production environment, consider:
1. Using StatefulSets with persistent volumes for data durability
2. Implementing replica sets for high availability
3. Setting up proper backup procedures
4. Configuring resource requests and limits
5. Setting up monitoring with Prometheus and Grafana

## Troubleshooting

If your MongoDB pod isn't starting:

1. Check pod status:
   ```bash
   kubectl describe pod -l app=mongodb
   ```

2. Check logs:
   ```bash
   kubectl logs -l app=mongodb
   ```

3. Common issues:
   - Incorrect Secret values
   - Resource constraints
   - Volume mounting issues
