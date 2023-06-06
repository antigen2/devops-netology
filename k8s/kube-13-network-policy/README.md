# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

-----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

> 1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
> 2. В качестве образа использовать network-multitool.
> 3. Разместить поды в namespace App.
> 4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
> 5. Продемонстрировать, что трафик разрешён и запрещён.

Манифесты куба.

Листинг `deploys.yml`:
```bash
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: backend
  name: backend
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - image: praqma/network-multitool:alpine-extra
          imagePullPolicy: IfNotPresent
          name: network-multitool
      terminationGracePeriodSeconds: 30

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: cache
  name: cache
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cache
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
        - image: praqma/network-multitool:alpine-extra
          imagePullPolicy: IfNotPresent
          name: network-multitool
      terminationGracePeriodSeconds: 30

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - image: praqma/network-multitool:alpine-extra
          imagePullPolicy: IfNotPresent
          name: network-multitool
      terminationGracePeriodSeconds: 30
```
Листинг `services.yml`:
```bash
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: app
spec:
  ports:
    - name: web
      port: 80
  selector:
    app: backend

---
apiVersion: v1
kind: Service
metadata:
  name: cache
  namespace: app
spec:
  ports:
    - name: web
      port: 80
  selector:
    app: cache

---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: app
spec:
  ports:
    - name: web
      port: 80
  selector:
    app: frontend
```
Листинг `network-policy.yml`:
```bash
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cache
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: cache
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: backend
      ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```
Создаем с помощью `terraform` 3 ВМ и разворачиваем `k8s`.
```bash
antigen@deb11notepad:~/netology/13/terraform$ source .env
antigen@deb11notepad:~/netology/13/terraform$ terraform init
...
antigen@deb11notepad:~/netology/13/terraform$ terraform apply --auto-approve
...

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

master_instance_ips = {
  "external_ip_address" = [
    "84.201.148.37",
  ]
  "internal_ip_address" = [
    "192.168.100.35",
  ]
  "name" = [
    "master-0",
  ]
}
worker_instance_ips = {
  "external_ip_address" = [
    "51.250.38.25",
    "51.250.43.160",
  ]
  "internal_ip_address" = [
    "192.168.100.3",
    "192.168.100.12",
  ]
  "name" = [
    "worker-0",
    "worker-1",
  ]
}
```
Редактируем `ya.yml` и раскатываем `playbook`:
```bash
antigen@deb11notepad:~/netology/13/terraform$ cd ../ansible/
antigen@deb11notepad:~/netology/13/ansible$ ansible-playbook -i inventory/ya.yml k8s.yml

PLAY [master] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************
ok: [master-01]

TASK [Init Cluaster] *****************************************************************************************************************************************************************
changed: [master-01]

TASK [mkdir .kube] *******************************************************************************************************************************************************************
changed: [master-01]

TASK [Copy admin.conf] ***************************************************************************************************************************************************************
changed: [master-01]

TASK [Get Join Command] **************************************************************************************************************************************************************
changed: [master-01]

TASK [Set Join Command] **************************************************************************************************************************************************************
ok: [master-01]

PLAY [worker] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************
ok: [worker-02]
ok: [worker-01]

TASK [Join Cluster] ******************************************************************************************************************************************************************
changed: [worker-02]
changed: [worker-01]

PLAY [master] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************
ok: [master-01]

TASK [Kubectl Autocomplete] **********************************************************************************************************************************************************
changed: [master-01]

TASK [Install Calico] ****************************************************************************************************************************************************************
changed: [master-01]

TASK [Pause 30s. Wait for cluster startup] *******************************************************************************************************************************************
Pausing for 30 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [master-01]

TASK [Copy Deploy file] **************************************************************************************************************************************************************
changed: [master-01] => (item=deploys.yml)
changed: [master-01] => (item=services.yml)
changed: [master-01] => (item=network-policy.yml)

TASK [Create Namespace app] **********************************************************************************************************************************************************
changed: [master-01]

TASK [Apply yaml] ********************************************************************************************************************************************************************
changed: [master-01]

PLAY RECAP ***************************************************************************************************************************************************************************
master-01                  : ok=13   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worker-01                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worker-02                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
Подключаемся, смотрим результат раскатки:
```bash
antigen@deb11notepad:~/netology/13/ansible$ ssh ubuntu@84.201.148.37
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-150-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Tue Jun  6 19:19:24 2023 from 88.87.84.72
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl get all -n app -o wide
NAME                           READY   STATUS    RESTARTS   AGE     IP                NODE                   NOMINATED NODE   READINESS GATES
pod/backend-5c496f8f74-rfrn6   1/1     Running   0          2m11s   192.168.169.193   ef377uj6oglgn4hkecll   <none>           <none>
pod/cache-5cd6c7468-vnkw6      1/1     Running   0          2m11s   192.168.247.1     ef3i4cb9t56mh7itnka6   <none>           <none>
pod/frontend-7ddf66cbb-xdp76   1/1     Running   0          2m11s   192.168.169.194   ef377uj6oglgn4hkecll   <none>           <none>

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/backend    ClusterIP   10.100.235.173   <none>        80/TCP    2m11s   app=backend
service/cache      ClusterIP   10.105.123.57    <none>        80/TCP    2m11s   app=cache
service/frontend   ClusterIP   10.110.54.160    <none>        80/TCP    2m11s   app=frontend

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS          IMAGES                                  SELECTOR
deployment.apps/backend    1/1     1            1           2m11s   network-multitool   praqma/network-multitool:alpine-extra   app=backend
deployment.apps/cache      1/1     1            1           2m11s   network-multitool   praqma/network-multitool:alpine-extra   app=cache
deployment.apps/frontend   1/1     1            1           2m11s   network-multitool   praqma/network-multitool:alpine-extra   app=frontend

NAME                                 DESIRED   CURRENT   READY   AGE     CONTAINERS          IMAGES                                  SELECTOR
replicaset.apps/backend-5c496f8f74   1         1         1       2m11s   network-multitool   praqma/network-multitool:alpine-extra   app=backend,pod-template-hash=5c496f8f74
replicaset.apps/cache-5cd6c7468      1         1         1       2m11s   network-multitool   praqma/network-multitool:alpine-extra   app=cache,pod-template-hash=5cd6c7468
replicaset.apps/frontend-7ddf66cbb   1         1         1       2m11s   network-multitool   praqma/network-multitool:alpine-extra   app=frontend,pod-template-hash=7ddf66cbb
```
Проверяем:
```bash
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl exec -n app frontend-7ddf66cbb-xdp76 -- curl backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:02 --:--:--     0Praqma Network MultiTool (with NGINX) - backend-5c496f8f74-rfrn6 - 192.168.169.193
100    83  100    83    0     0     33      0  0:00:02  0:00:02 --:--:--    33
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl exec -n app frontend-7ddf66cbb-xdp76 -- curl cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:16 --:--:--     0^C
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl exec -n app backend-5c496f8f74-rfrn6 -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:12 --:--:--     0^C
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl exec -n app backend-5c496f8f74-rfrn6 -- curl cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Praqma Network MultiTool (with NGINX) - cache-5cd6c7468-vnkw6 - 192.168.247.1
100    78  100    78    0     0  15294      0 --:--:-- --:--:-- --:--:-- 19500
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl exec -n app cache-5cd6c7468-vnkw6 -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0curl: (6) Could not resolve host: frontend
command terminated with exit code 6
ubuntu@ef3m7o1k6ecg7f7m2tgh:~$ kubectl exec -n app cache-5cd6c7468-vnkw6 -- curl backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0curl: (6) Could not resolve host: backend
command terminated with exit code 6
```
