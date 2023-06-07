# Домашнее задание к занятию «Обновление приложений»

### Цель задания

Выбрать и настроить стратегию обновления приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment).
2. [Статья про стратегии обновлений](https://habr.com/ru/companies/flant/articles/471620/).

-----

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

> 1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
> 2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
> 3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
> 4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
> 5. Вам нужно объяснить свой выбор стратегии обновления приложения.

Что мы имеем? Очень мало ресурсов. В самый незагруженный период запас всего 20%. Метод Blue/Green сразу отметаем,
т.к. необходимо 100% запас ресурсов. Мог бы подойти метод обновления Rolling update, если реплик >= 5,
т.к. для этого метода требуется 1 свободная реплика - а это 20% вычисл. ресурсов, но версии не совместимы и постепенно подменять не имеет смысла.
Канареечный метод не подходит так же, как и А/В тестирование, из-за требования большого количества ресурсов.

Значит здесь подходит только метод обновления Recreate, т.к. на уже выделенных ресурсах он сначала удалит старую версию приложения, 
затем развернет новую версию. 

### Задание 2. Обновить приложение

> 1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
> 2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
> 3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
> 4. Откатиться после неудачного обновления.

Листинг `deploy.yml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 80%
      maxUnavailable: 80%
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
         - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "8080"
          - name: HTTPS_PORT
            value: "8443"
```
Применяем манифест:
```bash
antigen@deb11notepad:~/netology/14$ kubectl apply -f deploy.yml
deployment.apps/my-app created
```
Чуть ждем и проверяем результат:
```bash
antigen@deb11notepad:~/netology/14$ kubectl get all -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/my-app-6ccffc5ff-mg4bc   2/2     Running   0          89s   10.1.86.221   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-h4jdg   2/2     Running   0          89s   10.1.86.199   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-xgktk   2/2     Running   0          89s   10.1.86.224   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-56g8p   2/2     Running   0          89s   10.1.86.234   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-xdxrh   2/2     Running   0          89s   10.1.86.202   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   12d   <none>

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                               SELECTOR
deployment.apps/my-app   5/5     5            5           89s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=my-app

NAME                               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/my-app-6ccffc5ff   5         5         5       89s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=my-app,pod-template-hash=6ccffc5ff
```
Меняем в `deploy.yml` версию `nginx` на `1.20`, применяем и проверяем:
```bash
antigen@deb11notepad:~/netology/14$ kubectl apply -f deploy.yml
deployment.apps/my-app configured
antigen@deb11notepad:~/netology/14$ kubectl get all -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/my-app-d6c9868f9-47mcd   2/2     Running   0          31s   10.1.86.229   deb11notepad   <none>           <none>
pod/my-app-d6c9868f9-4dtb7   2/2     Running   0          31s   10.1.86.235   deb11notepad   <none>           <none>
pod/my-app-d6c9868f9-4wmwn   2/2     Running   0          31s   10.1.86.225   deb11notepad   <none>           <none>
pod/my-app-d6c9868f9-8jkg6   2/2     Running   0          31s   10.1.86.252   deb11notepad   <none>           <none>
pod/my-app-d6c9868f9-9pqbb   2/2     Running   0          31s   10.1.86.228   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   12d   <none>

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS        IMAGES                               SELECTOR
deployment.apps/my-app   5/5     5            5           3m56s   nginx,multitool   nginx:1.20,wbitt/network-multitool   app=my-app

NAME                               DESIRED   CURRENT   READY   AGE     CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/my-app-6ccffc5ff   0         0         0       3m56s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=my-app,pod-template-hash=6ccffc5ff
replicaset.apps/my-app-d6c9868f9   5         5         5       31s     nginx,multitool   nginx:1.20,wbitt/network-multitool   app=my-app,pod-template-hash=d6c9868f9
```
Снова меняем в `deploy.yml` версию `nginx` на `1.28`, применяем и проверяем:
```bash
antigen@deb11notepad:~/netology/14$ kubectl apply -f deploy.yml
antigen@deb11notepad:~/netology/14$ kubectl get all -o wide
NAME                         READY   STATUS             RESTARTS   AGE    IP            NODE           NOMINATED NODE   READINESS GATES
pod/my-app-d6c9868f9-8jkg6   2/2     Running            0          3m1s   10.1.86.252   deb11notepad   <none>           <none>
pod/my-app-f88dc85bc-8qwqx   1/2     ImagePullBackOff   0          88s    10.1.86.250   deb11notepad   <none>           <none>
pod/my-app-f88dc85bc-pf4rz   1/2     ImagePullBackOff   0          88s    10.1.86.230   deb11notepad   <none>           <none>
pod/my-app-f88dc85bc-vf785   1/2     ImagePullBackOff   0          87s    10.1.86.247   deb11notepad   <none>           <none>
pod/my-app-f88dc85bc-jqqr2   1/2     ErrImagePull       0          88s    10.1.86.227   deb11notepad   <none>           <none>
pod/my-app-f88dc85bc-zrph8   1/2     ErrImagePull       0          88s    10.1.86.226   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   12d   <none>

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS        IMAGES                               SELECTOR
deployment.apps/my-app   1/5     5            1           6m26s   nginx,multitool   nginx:1.28,wbitt/network-multitool   app=my-app

NAME                               DESIRED   CURRENT   READY   AGE     CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/my-app-6ccffc5ff   0         0         0       6m26s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=my-app,pod-template-hash=6ccffc5ff
replicaset.apps/my-app-d6c9868f9   1         1         1       3m1s    nginx,multitool   nginx:1.20,wbitt/network-multitool   app=my-app,pod-template-hash=d6c9868f9
replicaset.apps/my-app-f88dc85bc   5         5         0       88s     nginx,multitool   nginx:1.28,wbitt/network-multitool   app=my-app,pod-template-hash=f88dc85bc
```
Смотрим, в чем проблема по поду `my-app-f88dc85bc-8qwqx`:
```bash
antigen@deb11notepad:~/netology/14$ kubectl describe pod my-app-f88dc85bc-8qwqx
Name:             my-app-f88dc85bc-8qwqx
Namespace:        default
Priority:         0
Service Account:  default
Node:             deb11notepad/192.168.3.210
Start Time:       Wed, 07 Jun 2023 18:18:45 +0300
Labels:           app=my-app
                  pod-template-hash=f88dc85bc
Annotations:      cni.projectcalico.org/containerID: e052148c771361b854be9ca5359e89469696a1823e0c77841532e393dadbaab4
                  cni.projectcalico.org/podIP: 10.1.86.250/32
                  cni.projectcalico.org/podIPs: 10.1.86.250/32
Status:           Pending
IP:               10.1.86.250
IPs:
  IP:           10.1.86.250
Controlled By:  ReplicaSet/my-app-f88dc85bc
Containers:
  nginx:
    Container ID:
    Image:          nginx:1.28
    Image ID:
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5wv9p (ro)
  multitool:
    Container ID:   containerd://ec486a2d843141500b7181d5b711aee6508c4a029e5f34f8b708ac905c325497
    Image:          wbitt/network-multitool
    Image ID:       docker.io/wbitt/network-multitool@sha256:82a5ea955024390d6b438ce22ccc75c98b481bf00e57c13e9a9cc1458eb92652
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 07 Jun 2023 18:19:15 +0300
    Ready:          True
    Restart Count:  0
    Environment:
      HTTP_PORT:   8080
      HTTPS_PORT:  8443
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5wv9p (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-5wv9p:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  2m8s                default-scheduler  Successfully assigned default/my-app-f88dc85bc-8qwqx to deb11notepad
  Normal   Pulling    110s                kubelet            Pulling image "wbitt/network-multitool"
  Normal   Pulled     99s                 kubelet            Successfully pulled image "wbitt/network-multitool" in 1.398373465s (10.959874043s including waiting)
  Normal   Created    99s                 kubelet            Created container multitool
  Normal   Started    99s                 kubelet            Started container multitool
  Normal   BackOff    24s (x4 over 86s)   kubelet            Back-off pulling image "nginx:1.28"
  Warning  Failed     24s (x4 over 86s)   kubelet            Error: ImagePullBackOff
  Normal   Pulling    10s (x4 over 2m7s)  kubelet            Pulling image "nginx:1.28"
  Warning  Failed     6s (x4 over 110s)   kubelet            Failed to pull image "nginx:1.28": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:1.28": failed to unpack image on snapshotter overlayfs: unexpected media type text/html for sha256:00479beb570a19e4799ef1c3e328dc7f14c546e2eccd80a8a554c011287f4a67: not found
  Warning  Failed     6s (x4 over 110s)   kubelet            Error: ErrImagePull
```
'Так вот оно чо, Михалыч... '(c): `  Warning  Failed     6s (x4 over 110s)   kubelet            Failed to pull image "nginx:1.28": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:1.28": failed to unpack image on snapshotter overlayfs: unexpected media type text/html for sha256:00479beb570a19e4799ef1c3e328dc7f14c546e2eccd80a8a554c011287f4a67: not found`

Смотрим, какие есть точки отката:
```bash
antigen@deb11notepad:~/netology/14$ kubectl rollout history deployment my-app
deployment.apps/my-app
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
antigen@deb11notepad:~/netology/14$ kubectl rollout history deployment my-app --revision 1
deployment.apps/my-app with revision #1
Pod Template:
  Labels:       app=my-app
        pod-template-hash=6ccffc5ff
  Containers:
   nginx:
    Image:      nginx:1.19
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
   multitool:
    Image:      wbitt/network-multitool
    Port:       <none>
    Host Port:  <none>
    Environment:
      HTTP_PORT:        8080
      HTTPS_PORT:       8443
    Mounts:     <none>
  Volumes:      <none>
```
Возвращаемся, например к первой точке:
```bash
antigen@deb11notepad:~/netology/14$ kubectl rollout undo deployment/my-app --to-revision 1
deployment.apps/my-app rolled back
```
Проверяем, что вышло:
```bash
antigen@deb11notepad:~/netology/14$ kubectl get all -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/my-app-6ccffc5ff-m6rv9   2/2     Running   0          18s   10.1.86.251   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-mnbsq   2/2     Running   0          18s   10.1.86.232   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-9gd4c   2/2     Running   0          18s   10.1.86.246   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-bdznl   2/2     Running   0          18s   10.1.86.239   deb11notepad   <none>           <none>
pod/my-app-6ccffc5ff-z6f8g   2/2     Running   0          18s   10.1.86.198   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   12d   <none>

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                               SELECTOR
deployment.apps/my-app   5/5     5            5           12m   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=my-app

NAME                               DESIRED   CURRENT   READY   AGE     CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/my-app-f88dc85bc   0         0         0       7m35s   nginx,multitool   nginx:1.28,wbitt/network-multitool   app=my-app,pod-template-hash=f88dc85bc
replicaset.apps/my-app-d6c9868f9   0         0         0       9m8s    nginx,multitool   nginx:1.20,wbitt/network-multitool   app=my-app,pod-template-hash=d6c9868f9
replicaset.apps/my-app-6ccffc5ff   5         5         5       12m     nginx,multitool   nginx:1.19,wbitt/network-multitool   app=my-app,pod-template-hash=6ccffc5ff
```
