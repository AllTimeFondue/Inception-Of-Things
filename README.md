# Inception-Of-Things (IoT)

42 school project — a minimal introduction to **Kubernetes**, using **Vagrant**, **K3s**, **K3d** and **Argo CD** to build a small GitOps pipeline.

## Environment

- **Host OS:** Ubuntu 26.04.1 Desktop (amd64)
- **Virtualization:** Vagrant + Libvirt
- **Orchestration:** K3s, K3d
- **GitOps:** Argo CD

## Part 1 — K3s and Vagrant

Two VMs set up with Vagrant:

| VM        | Hostname  | IP             | Role              |
|-----------|-----------|----------------|-------------------|
| Server    | `tlebonS`  | 192.168.56.110 | K3s controller    |
| ServerWorker | `tlebonSW` | 192.168.56.111 | K3s agent (worker) |

- 1 CPU / 512–1024 MB RAM per VM.
- Passwordless SSH access to both machines.
- `kubectl` installed and usable from the controller.

```bash
cd p1
vagrant up
vagrant ssh tlebonS
```

## Part 2 — K3s and three simple applications

A single VM (`tlebonS`, 192.168.56.110) running K3s in server mode, hosting **3 web apps** behind an **Ingress**, routed by the Host header:

| Host header     | App served |
|-----------------|------------|
| `app1.com`      | app1       |
| `app2.com`      | app2 (3 replicas) |
| *(anything else)* | app3 (default) |

```bash
cd p2
vagrant up
curl -H "Host: app1.com" 192.168.56.110
curl -H "Host: app2.com" 192.168.56.110
curl 192.168.56.110
```

## Part 3 — K3d and Argo CD

No more Vagrant: K3d runs directly on the host VM.

- Two namespaces:
  - `argocd` — Argo CD itself.
  - `dev` — the deployed application.
- Argo CD watches a public GitHub repository and automatically syncs the app running in `dev`.
- The app has two tagged versions (`v1` / `v2`), switched by editing the manifest and pushing to Git.

```bash
cd p3
./scripts/install.sh   # installs Docker, K3d, Argo CD CLI, kubectl.
./scripts/setup.sh     # creates K3D cluster and setup ArgoCD.
```

Check the deployed version:

```bash
curl http://localhost:8081/
```

Get the ui:

```bash
make ui
```
Type https://localhost:8080 on a browser.