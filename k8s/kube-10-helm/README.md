# Домашнее задание к занятию «Helm»

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение, например, MicroK8S.
2. Установленный локальный kubectl.
3. Установленный локальный Helm.
4. Редактор YAML-файлов с подключенным репозиторием GitHub.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

------

### Задание 1. Подготовить Helm-чарт для приложения

> 1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
> 2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
> 3. В переменных чарта измените образ приложения для изменения версии.

Создать шаблон можно так:
```bash
antigen@deb11notepad:~/netology/10/multitool$ helm create multitool
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
Creating multitool
```
Отредактировал получившийся шаблон и привел к виду:
```bash
antigen@deb11notepad:~/netology/10$ tree -a
.
└── multitool
    ├── Chart.yaml
    ├── .helmignore
    ├── templates
    │   ├── deployments
    │   │   ├── multitool.yaml
    │   │   └── nginx.yaml
    │   └── services
    │       ├── multitool.yaml
    │       └── nginx.yaml
    └── values.yaml
```
Листинг `multitool/Chart.yaml`:
```yaml
apiVersion: v2
name: multitool
description: multitool plus nginx

type: application

version: 1.0.0
appVersion: "1.0.0"
```
Листинг `multitool/values.yaml`:
```yaml
---
apps:
  replicaCount: 1
  multitool:
    name: multitool
    image:
      repository: wbitt/network-multitool
      pullPolicy: IfNotPresent
      tag: latest
      env:
        HTTP_PORT:  8080
        HTTPS_PORT: 8443
  nginx:
    name: nginx
    image:
      repository: nginx
      pullPolicy: IfNotPresent
      tag: 1.24
    containerPort: 80

service:
  name: my-svc
  type: ClusterIP
  port: 80
```
Листинг ` multitool/templates/deployments/multitool.yaml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Values.apps.multitool.name }}
  labels:
    app: {{ .Values.apps.multitool.name }}
spec:
  replicas: {{ .Values.apps.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.apps.multitool.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.apps.multitool.name }}
    spec:
      containers:
        - name: {{ .Values.apps.multitool.name }}
          image: {{ .Values.apps.multitool.image.repository }}:{{ .Values.apps.multitool.image.tag }}
          imagePullPolicy: {{ .Values.apps.multitool.image.pullPolicy }}
          env:
            - name: HTTP_PORT
              value: {{ .Values.apps.multitool.image.env.HTTP_PORT | quote }}
            - name: HTTPS_PORT
              value: {{ .Values.apps.multitool.image.env.HTTPS_PORT | quote  }}
```
Листинг `multitool/templates/deployments/nginx.yaml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Values.apps.nginx.name }}
  labels:
    app: {{ .Values.apps.nginx.name }}
spec:
  replicas: {{ .Values.apps.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.apps.nginx.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.apps.nginx.name }}
    spec:
      containers:
        - name: {{ .Values.apps.nginx.name }}
          image: {{ .Values.apps.nginx.image.repository }}:{{ .Values.apps.nginx.image.tag }}
          imagePullPolicy: {{ .Values.apps.nginx.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.apps.nginx.containerPort }}
```
Листинг `multitool/templates/services/multitool.yaml`:
```yaml
{{- $vers := .Chart.AppVersion | toString }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.apps.multitool.name }}-{{ .Values.service.name }}-{{ regexReplaceAll "\\W+" $vers "-" }}
  labels:
    app: {{ .Release.Name }}-{{ .Values.service.name }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.apps.multitool.image.env.HTTP_PORT }}
      protocol: TCP
      name: {{ .Values.apps.multitool.name }}
  selector:
    app: {{ .Values.apps.multitool.name }}
```
Листинг `multitool/templates/services/nginx.yaml`:
```yaml
{{- $vers := .Chart.AppVersion | toString }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.apps.nginx.name }}-{{ .Values.service.name }}-{{ regexReplaceAll "\\W+" $vers "-" }}
  labels:
    app: {{ .Release.Name }}-{{ .Values.service.name }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.apps.nginx.containerPort }}
      protocol: TCP
      name: {{ .Values.apps.nginx.name }}
  selector:
    app: {{ .Values.apps.nginx.name }}
```
Проверяем:
```bash
antigen@deb11notepad:~/netology/10$ helm lint multitool
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
==> Linting multitool
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```
Деплоим:
```bash
antigen@deb11notepad:~/netology/10$ helm install multitool-0.1 multitool
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
NAME: multitool-0.1
LAST DEPLOYED: Sun May 28 17:38:48 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
Смотрим что получилось:
```bash
antigen@deb11notepad:~/netology/10$ kubectl get all -o wide
NAME                                          READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
pod/multitool-0.1-multitool-95d9c755b-xmsxj   1/1     Running   0          3m33s   10.1.86.251   deb11notepad   <none>           <none>
pod/multitool-0.1-nginx-69669b9495-mmd7d      1/1     Running   0          3m33s   10.1.86.232   deb11notepad   <none>           <none>

NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes               ClusterIP   10.152.183.1     <none>        443/TCP   2d18h   <none>
service/nginx-my-svc-1-0-0       ClusterIP   10.152.183.68    <none>        80/TCP    3m33s   app=nginx
service/multitool-my-svc-1-0-0   ClusterIP   10.152.183.161   <none>        80/TCP    3m33s   app=multitool

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                           SELECTOR
deployment.apps/multitool-0.1-multitool   1/1     1            1           3m33s   multitool    wbitt/network-multitool:latest   app=multitool
deployment.apps/multitool-0.1-nginx       1/1     1            1           3m33s   nginx        nginx:1.24                       app=nginx

NAME                                                DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                           SELECTOR
replicaset.apps/multitool-0.1-multitool-95d9c755b   1         1         1       3m33s   multitool    wbitt/network-multitool:latest   app=multitool,pod-template-hash=95d9c755b
replicaset.apps/multitool-0.1-nginx-69669b9495      1         1         1       3m33s   nginx        nginx:1.24                       app=nginx,pod-template-hash=69669b9495
```
Обновили `appVersion` до версии `1.0.1`:
```bash
antigen@deb11notepad:~/netology/10$ helm upgrade multitool-0.1 multitool
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
Release "multitool-0.1" has been upgraded. Happy Helming!
NAME: multitool-0.1
LAST DEPLOYED: Sun May 28 17:52:33 2023
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
antigen@deb11notepad:~/netology/10$ kubectl get all -o wide
NAME                                          READY   STATUS    RESTARTS   AGE    IP            NODE           NOMINATED NODE   READINESS GATES
pod/multitool-0.1-multitool-95d9c755b-96z97   1/1     Running   0          6m1s   10.1.86.246   deb11notepad   <none>           <none>
pod/multitool-0.1-nginx-69669b9495-844kj      1/1     Running   0          6m1s   10.1.86.239   deb11notepad   <none>           <none>

NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes               ClusterIP   10.152.183.1     <none>        443/TCP   2d18h   <none>
service/multitool-my-svc-1-0-1   ClusterIP   10.152.183.173   <none>        80/TCP    12s     app=multitool
service/nginx-my-svc-1-0-1       ClusterIP   10.152.183.32    <none>        80/TCP    12s     app=nginx

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                           SELECTOR
deployment.apps/multitool-0.1-multitool   1/1     1            1           6m1s   multitool    wbitt/network-multitool:latest   app=multitool
deployment.apps/multitool-0.1-nginx       1/1     1            1           6m1s   nginx        nginx:1.24                       app=nginx

NAME                                                DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES                           SELECTOR
replicaset.apps/multitool-0.1-multitool-95d9c755b   1         1         1       6m1s   multitool    wbitt/network-multitool:latest   app=multitool,pod-template-hash=95d9c755b
replicaset.apps/multitool-0.1-nginx-69669b9495      1         1         1       6m1s   nginx        nginx:1.24                       app=nginx,pod-template-hash=69669b9495
```
Удаляем за собой:
```bash
antigen@deb11notepad:~/netology/10$ helm uninstall multitool-0.1
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
release "multitool-0.1" uninstalled
```
------
### Задание 2. Запустить две версии в разных неймспейсах

> 1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
> 2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
> 3. Продемонстрируйте результат.

Решил сделать на примере `nginx` и назвал нэймспейсы более логично: `web01` и `web02`.
Создаем шаблон и приводим к виду:
```bash
antigen@deb11notepad:~/netology/10$ tree nginx/ -a
nginx/
├── Chart.yaml
├── .helmignore
├── templates
│   ├── deployments
│   │   └── nginx.yaml
│   └── services
│       └── nginx.yaml
└── values.yaml
```
Листинг `nginx/Chart.yaml`:
```yaml
---
apiVersion: v2
name: multitool
description: multitool plus nginx

type: application

version: 1.0.0
appVersion: "1.0.1"
namespace: default
```
Листинг `nginx/values.yaml`:
```yaml
---
apps:
  nginx:
    name: nginx
    image:
      repository: nginx
      pullPolicy: IfNotPresent
      tag: 1.24
    containerPort: 80

service:
  name: my-nginx-svc
  type: ClusterIP
  port: 80
```
Листинг `nginx/templates/deployments/nginx.yaml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Values.apps.nginx.name }}
  labels:
    app: {{ .Values.apps.nginx.name }}
spec:
  replicas: {{ .Values.apps.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.apps.nginx.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.apps.nginx.name }}
    spec:
      containers:
        - name: {{ .Values.apps.nginx.name }}
          image: {{ .Values.apps.nginx.image.repository }}:{{ .Values.apps.nginx.image.tag }}
          imagePullPolicy: {{ .Values.apps.nginx.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.apps.nginx.containerPort }}
```
Листинг `nginx/templates/services/nginx.yaml`:
```yaml
{{- $vers := .Chart.AppVersion | toString }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.apps.nginx.name }}-{{ .Values.service.name }}-{{ regexReplaceAll "\\W+" $vers "-" }}
  labels:
    app: {{ .Release.Name }}-{{ .Values.service.name }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.apps.nginx.containerPort }}
      protocol: TCP
      name: {{ .Values.apps.nginx.name }}
  selector:
    app: {{ .Values.apps.nginx.name }}
```
Деплоим дважды в разные немспейсы:
```bash
antigen@deb11notepad:~/netology/10$ helm install --create-namespace -n web01 nginx-v1 nginx
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
NAME: nginx-v1
LAST DEPLOYED: Sun May 28 21:40:28 2023
NAMESPACE: web01
STATUS: deployed
REVISION: 1
TEST SUITE: None
antigen@deb11notepad:~/netology/10$ helm install --create-namespace -n web02 nginx-v2 nginx
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
NAME: nginx-v2
LAST DEPLOYED: Sun May 28 21:40:37 2023
NAMESPACE: web02
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
Теперь редактируем `nginx/Chart.yaml`. Изменяем версию `appVersion:` на `"1.0.2"`
Деплоим еще одну копию в неймспэйс `web01`:
```bash
antigen@deb11notepad:~/netology/10$ helm install --create-namespace -n web01 nginx-v3 nginx
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
NAME: nginx-v3
LAST DEPLOYED: Sun May 28 21:41:16 2023
NAMESPACE: web01
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
Смотрим, что получилось:
```bash
antigen@deb11notepad:~/netology/10$ for i in {1..2}; do helm list -n web0$i; done
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
nginx-v1        web01           1               2023-05-28 21:40:28.719030335 +0300 MSK deployed        multitool-1.0.0 1.0.1
nginx-v3        web01           1               2023-05-28 21:41:16.119213952 +0300 MSK deployed        multitool-1.0.0 1.0.2
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/antigen/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/antigen/.kube/config
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
nginx-v2        web02           1               2023-05-28 21:40:37.42798873 +0300 MSK  deployed        multitool-1.0.0 1.0.1
antigen@deb11notepad:~/netology/10$
antigen@deb11notepad:~/netology/10$
antigen@deb11notepad:~/netology/10$ kubectl get all -o wide -n web01
NAME                                  READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
pod/nginx-v1-nginx-69669b9495-m62pl   1/1     Running   0          10m     10.1.86.214   deb11notepad   <none>           <none>
pod/nginx-v3-nginx-69669b9495-dgkfj   1/1     Running   0          9m30s   10.1.86.231   deb11notepad   <none>           <none>

NAME                               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/nginx-my-nginx-svc-1-0-1   ClusterIP   10.152.183.251   <none>        80/TCP    10m     app=nginx
service/nginx-my-nginx-svc-1-0-2   ClusterIP   10.152.183.35    <none>        80/TCP    9m30s   app=nginx

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-v1-nginx   1/1     1            1           10m     nginx        nginx:1.24   app=nginx
deployment.apps/nginx-v3-nginx   1/1     1            1           9m30s   nginx        nginx:1.24   app=nginx

NAME                                        DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-v1-nginx-69669b9495   1         1         1       10m     nginx        nginx:1.24   app=nginx,pod-template-hash=69669b9495
replicaset.apps/nginx-v3-nginx-69669b9495   1         1         1       9m30s   nginx        nginx:1.24   app=nginx,pod-template-hash=69669b9495
antigen@deb11notepad:~/netology/10$ kubectl get all -o wide -n web02
NAME                                  READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/nginx-v2-nginx-69669b9495-qpv9z   1/1     Running   0          10m   10.1.86.200   deb11notepad   <none>           <none>

NAME                               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/nginx-my-nginx-svc-1-0-1   ClusterIP   10.152.183.112   <none>        80/TCP    10m   app=nginx

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-v2-nginx   1/1     1            1           10m   nginx        nginx:1.24   app=nginx

NAME                                        DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-v2-nginx-69669b9495   1         1         1       10m   nginx        nginx:1.24   app=nginx,pod-template-hash=69669b9495
```
