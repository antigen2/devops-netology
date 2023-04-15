# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

> **Что нужно сделать**
> 
> Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.
> 
> 1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
> 2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
> 3. Обеспечить возможность чтения файла контейнером multitool.
> 4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
> 5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

Манифест `deployment.yml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: main
  name: mydeploy
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:

        - image: wbitt/network-multitool
          name: multitool
          imagePullPolicy: IfNotPresent
          command: ['sh', '-c', 'while true; do cat /input/check.me; sleep 5s; done']
          volumeMounts:
            - name: share
              mountPath: /input

        - image: busybox
          name: busybox
          imagePullPolicy: IfNotPresent
          command: ['sh', '-c', 'while true; do echo Date: `date` > /output/check.me; sleep 5s; done']
          volumeMounts:
            - name: share
              mountPath: /output

      volumes:
        - name: share
          emptyDir: {}
```
Создаем и смотрим результат:
```bash
antigen@deb11notepad:~/netology/06$ kubectl apply -f deployment.yml
deployment.apps/mydeploy created
antigen@deb11notepad:~/netology/06$ kubectl get all -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/mydeploy-597d858d54-sclqn   2/2     Running   0          12s   10.1.86.218   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   23d   <none>

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                            SELECTOR
deployment.apps/mydeploy   1/1     1            1           12s   multitool,busybox   wbitt/network-multitool,busybox   app=main

NAME                                  DESIRED   CURRENT   READY   AGE   CONTAINERS          IMAGES                            SELECTOR
replicaset.apps/mydeploy-597d858d54   1         1         1       12s   multitool,busybox   wbitt/network-multitool,busybox   app=main,pod-template-hash=597d858d54
```
Проверяем, что последнее записал `busybox` и что в логах `multitool`:
```bash
antigen@deb11notepad:~/netology/06$ kubectl exec pods/mydeploy-597d858d54-sclqn -c busybox -- cat /output/check.me
Date: Sat Apr 15 11:56:28 UTC 2023
antigen@deb11notepad:~/netology/06$ kubectl logs pod/mydeploy-597d858d54-sclqn -c multitool
cat: can't open '/input/check.me': No such file or directory
Date: Sat Apr 15 11:55:02 UTC 2023
Date: Sat Apr 15 11:55:07 UTC 2023
Date: Sat Apr 15 11:55:12 UTC 2023
Date: Sat Apr 15 11:55:17 UTC 2023
Date: Sat Apr 15 11:55:22 UTC 2023
Date: Sat Apr 15 11:55:28 UTC 2023
Date: Sat Apr 15 11:55:33 UTC 2023
Date: Sat Apr 15 11:55:38 UTC 2023
Date: Sat Apr 15 11:55:43 UTC 2023
Date: Sat Apr 15 11:55:48 UTC 2023
Date: Sat Apr 15 11:55:53 UTC 2023
Date: Sat Apr 15 11:55:58 UTC 2023
Date: Sat Apr 15 11:56:03 UTC 2023
Date: Sat Apr 15 11:56:08 UTC 2023
Date: Sat Apr 15 11:56:13 UTC 2023
Date: Sat Apr 15 11:56:18 UTC 2023
Date: Sat Apr 15 11:56:23 UTC 2023
Date: Sat Apr 15 11:56:28 UTC 2023
```

------

### Задание 2

> **Что нужно сделать**
> 
> Создать DaemonSet приложения, которое может прочитать логи ноды.
> 
> 1. Создать DaemonSet приложения, состоящего из multitool.
> 2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
> 3. Продемонстрировать возможность чтения файла изнутри пода.
> 4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

Манифест `DaemondSet`:
```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: main
  name: mydeploy
  namespace: default
spec:
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
        - image: wbitt/network-multitool
          name: multitool
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name:  varlog
              mountPath: /varlog
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
```
Запускаем, проверяем:
```bash
antigen@deb11notepad:~/netology/06$ kubectl apply -f deploy2.yml
daemonset.apps/mydeploy created
antigen@deb11notepad:~/netology/06$ kubectl get pods -o wide
NAME             READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
mydeploy-hwhwj   1/1     Running   0          16s   10.1.86.217   deb11notepad   <none>           <none>
antigen@deb11notepad:~/netology/06$ kubectl exec -it pods/mydeploy-hwhwj -- tail /varlog/syslog
Apr 15 15:57:03 deb11notepad microk8s.daemon-containerd[543]: time="2023-04-15T15:57:03.767263016+03:00" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:mydeploy-hwhwj,Uid:3c390055-6c3c-49e3-98e3-c431fa4df077,Namespace:default,Attempt:0,} returns sandbox id \"16166d495d08aab67412991b85dbe816d692d25f8b2ab5082dbbd563e65ef8b7\""
Apr 15 15:57:03 deb11notepad microk8s.daemon-containerd[543]: time="2023-04-15T15:57:03.772818765+03:00" level=info msg="CreateContainer within sandbox \"16166d495d08aab67412991b85dbe816d692d25f8b2ab5082dbbd563e65ef8b7\" for container &ContainerMetadata{Name:multitool,Attempt:0,}"
Apr 15 15:57:03 deb11notepad microk8s.daemon-containerd[543]: time="2023-04-15T15:57:03.813127116+03:00" level=info msg="CreateContainer within sandbox \"16166d495d08aab67412991b85dbe816d692d25f8b2ab5082dbbd563e65ef8b7\" for &ContainerMetadata{Name:multitool,Attempt:0,} returns container id \"ec3415e4fa3c24a60a5e4ffcf4f2cd3169f0c4b9036fc3f49b45c218488f12cb\""
Apr 15 15:57:03 deb11notepad microk8s.daemon-containerd[543]: time="2023-04-15T15:57:03.814785111+03:00" level=info msg="StartContainer for \"ec3415e4fa3c24a60a5e4ffcf4f2cd3169f0c4b9036fc3f49b45c218488f12cb\""
Apr 15 15:57:03 deb11notepad systemd[1]: run-containerd-runc-k8s.io-ec3415e4fa3c24a60a5e4ffcf4f2cd3169f0c4b9036fc3f49b45c218488f12cb-runc.KowvyR.mount: Succeeded.
Apr 15 15:57:03 deb11notepad systemd[900618]: run-containerd-runc-k8s.io-ec3415e4fa3c24a60a5e4ffcf4f2cd3169f0c4b9036fc3f49b45c218488f12cb-runc.KowvyR.mount: Succeeded.
Apr 15 15:57:03 deb11notepad microk8s.daemon-containerd[543]: time="2023-04-15T15:57:03.921675650+03:00" level=info msg="StartContainer for \"ec3415e4fa3c24a60a5e4ffcf4f2cd3169f0c4b9036fc3f49b45c218488f12cb\" returns successfully"
Apr 15 15:57:04 deb11notepad microk8s.daemon-kubelite[686372]: I0415 15:57:04.547800  686372 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="default/mydeploy-hwhwj" podStartSLOduration=2.547694856 pod.CreationTimestamp="2023-04-15 15:57:02 +0300 MSK" firstStartedPulling="0001-01-01 00:00:00 +0000 UTC" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2023-04-15 15:57:04.546503831 +0300 MSK m=+77634.481708556" watchObservedRunningTime="2023-04-15 15:57:04.547694856 +0300 MSK m=+77634.482899581"
Apr 15 15:57:30 deb11notepad systemd[1]: run-containerd-runc-k8s.io-70ce07db1e207cddca657152e16a1d8674aea79a5a7a209156ff1e050ff6d3a3-runc.5JW8Jk.mount: Succeeded.
Apr 15 15:57:30 deb11notepad systemd[900618]: run-containerd-runc-k8s.io-70ce07db1e207cddca657152e16a1d8674aea79a5a7a209156ff1e050ff6d3a3-runc.5JW8Jk.mount: Succeeded.
```
------
