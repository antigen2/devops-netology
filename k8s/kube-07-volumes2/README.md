# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

> **Что нужно сделать**
> 
> Создать Deployment приложения, использующего локальный PV, созданный вручную.
> 
> 1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
> 2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
> 3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
> 4. Продемонстрировать, что файл сохранился на локальном диске ноды, а также что произойдёт с файлом после удаления пода и deployment. Пояснить, почему.
> 5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

Включаем в `mikrok8s` поддержку локального стораджа:
```bash
microk8s enable hostpath-storage
```
Манифест `pvc_pv.yml`
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myfirstpvc
  labels:
    app: main
  namespace: default
spec:
  storageClassName: ''
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
  labels:
    app: main
  namespace: default
spec:
  storageClassName: ''
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /opt/share
  persistentVolumeReclaimPolicy: Delete
```
Манифест `deployment.yml`
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
          volumeMounts:
            - name: share
              mountPath: /input

        - image: busybox
          name: busybox
          imagePullPolicy: IfNotPresent
          command: ['sh', '-c', 'while true; do echo Date: `date` >> /output/check.me; sleep 5s; done']
          volumeMounts:
            - name: share
              mountPath: /output

      volumes:
        - name: share
          persistentVolumeClaim:
            claimName: myfirstpvc
```
Запускаем `pvc_pv.yml`:
```bash
antigen@deb11notepad:~/netology/07$ kubectl apply -f pvc_pv.yml
persistentvolumeclaim/myfirstpvc created
persistentvolume/pv created
antigen@deb11notepad:~/netology/07$ kubectl get persistentvolume -o wide
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE   VOLUMEMODE
pv     1Gi        RWO            Delete           Bound    default/myfirstpvc                           15m   Filesystem
```
Запускаем `deployment.yml`:
```bash
antigen@deb11notepad:~/netology/07$ kubectl apply -f deployment.yml
deployment.apps/mydeploy created
antigen@deb11notepad:~/netology/07$ kubectl get persistentvolume -o wide
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE   VOLUMEMODE
pv     1Gi        RWO            Delete           Bound    default/myfirstpvc                           17m   Filesystem
antigen@deb11notepad:~/netology/07$ kubectl get all -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/mydeploy-776878c486-mb2zt   2/2     Running   0          12m   10.1.86.200   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   23d   <none>

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                            SELECTOR
deployment.apps/mydeploy   1/1     1            1           12m   multitool,busybox   wbitt/network-multitool,busybox   app=main

NAME                                  DESIRED   CURRENT   READY   AGE   CONTAINERS          IMAGES                            SELECTOR
replicaset.apps/mydeploy-776878c486   1         1         1       12m   multitool,busybox   wbitt/network-multitool,busybox   app=main,pod-template-hash=776878c486
```
Проверяем из `multitool`:
```bash
antigen@deb11notepad:~/netology/07$ kubectl exec -it pods/mydeploy-776878c486-mb2zt -c multitool -- tail /input/check.me
Date: Sat Apr 15 16:03:55 UTC 2023
Date: Sat Apr 15 16:04:00 UTC 2023
Date: Sat Apr 15 16:04:05 UTC 2023
Date: Sat Apr 15 16:04:10 UTC 2023
Date: Sat Apr 15 16:04:15 UTC 2023
Date: Sat Apr 15 16:04:20 UTC 2023
Date: Sat Apr 15 16:04:25 UTC 2023
Date: Sat Apr 15 16:04:30 UTC 2023
Date: Sat Apr 15 16:04:35 UTC 2023
Date: Sat Apr 15 16:04:40 UTC 2023
```
Проверяем на локальной системе:
```bash
antigen@deb11notepad:~/netology/07$ tail /opt/share/check.me
Date: Sat Apr 15 16:04:15 UTC 2023
Date: Sat Apr 15 16:04:20 UTC 2023
Date: Sat Apr 15 16:04:25 UTC 2023
Date: Sat Apr 15 16:04:30 UTC 2023
Date: Sat Apr 15 16:04:35 UTC 2023
Date: Sat Apr 15 16:04:40 UTC 2023
Date: Sat Apr 15 16:04:45 UTC 2023
Date: Sat Apr 15 16:04:50 UTC 2023
Date: Sat Apr 15 16:04:55 UTC 2023
Date: Sat Apr 15 16:05:00 UTC 2023
```
После удаления подов файл останется, т.к. сохраняется в файловой системе ноды.
```bash
antigen@deb11notepad:~/netology/07$ kubectl delete deployments.apps mydeploy
deployment.apps "mydeploy" deleted
antigen@deb11notepad:~/netology/07$ kubectl delete pods
pods                 pods.metrics.k8s.io
antigen@deb11notepad:~/netology/07$ kubectl delete pods/mydeploy-776878c486-mb2zt
pod "mydeploy-776878c486-mb2zt" deleted
antigen@deb11notepad:~/netology/07$ kubectl delete pvc myfirstpvc
persistentvolumeclaim "myfirstpvc" deleted
antigen@deb11notepad:~/netology/07$ kubectl delete pv pv
persistentvolume "pv" deleted
antigen@deb11notepad:~/netology/07$ tail /opt/share/check.me
Date: Sat Apr 15 16:12:30 UTC 2023
Date: Sat Apr 15 16:12:35 UTC 2023
Date: Sat Apr 15 16:12:40 UTC 2023
Date: Sat Apr 15 16:12:45 UTC 2023
Date: Sat Apr 15 16:12:50 UTC 2023
Date: Sat Apr 15 16:12:55 UTC 2023
Date: Sat Apr 15 16:13:00 UTC 2023
Date: Sat Apr 15 16:13:05 UTC 2023
Date: Sat Apr 15 16:13:10 UTC 2023
Date: Sat Apr 15 16:13:15 UTC 2023
```
------

### Задание 2

> **Что нужно сделать**
> 
> Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.
> 
> 1. Включить и настроить NFS-сервер на MicroK8S.
> 2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
> 3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
> 4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

Манифест `sc-nfs.yaml`:
```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: 192.168.3.210
  share: /srv/nfs
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4
```
Манифест `pvc-nfs.yaml`:
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: nfs-csi
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
```
Включаем и настраиваем NFS-сервер. Смотрим что получилось.
```bash
antigen@deb11notepad:~/netology/07$ microk8s kubectl apply -f - < sc-nfs.yaml
storageclass.storage.k8s.io/nfs-csi created
antigen@deb11notepad:~/netology/07$ microk8s kubectl apply -f - < pvc-nfs.yaml
persistentvolumeclaim/my-pvc created
antigen@deb11notepad:~/netology/07$
antigen@deb11notepad:~/netology/07$
antigen@deb11notepad:~/netology/07$ microk8s kubectl describe pvc my-pvc
Name:          my-pvc
Namespace:     default
StorageClass:  nfs-csi
Status:        Bound
Volume:        pvc-b0f6daea-897b-4862-86b7-15c54f0278c0
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: nfs.csi.k8s.io
               volume.kubernetes.io/storage-provisioner: nfs.csi.k8s.io
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      1Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                 Age                From                                                              Message
  ----    ------                 ----               ----                                                              -------
  Normal  Provisioning           63s                nfs.csi.k8s.io_deb11notepad_916e39b0-5aaf-45cf-a3df-fa8c02247323  External provisioner is provisioning volume for claim "default/my-pvc"
  Normal  ExternalProvisioning   63s (x3 over 63s)  persistentvolume-controller                                       waiting for a volume to be created, either by external provisioner "nfs.csi.k8s.io" or manually created by system administrator
  Normal  ProvisioningSucceeded  63s                nfs.csi.k8s.io_deb11notepad_916e39b0-5aaf-45cf-a3df-fa8c02247323  Successfully provisioned volume pvc-b0f6daea-897b-4862-86b7-15c54f0278c0
```
Манифест `pv-nfs.yml`:
```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Delete
  storageClassName: nfs-csi
  mountOptions:
    - hard
    - nfsvers=4
  nfs:
    path: /srv/nfs
    server: 192.168.3.210
```
Манифест `deploy2.yml`:
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
          volumeMounts:
            - name: nfs-share
              mountPath: /my_nfs_share

      volumes:
        - name: nfs-share
          persistentVolumeClaim:
            claimName: my-pvc
```
Применяем:
```bash
antigen@deb11notepad:~/netology/07$ kubectl apply -f pv-nfs.yml
persistentvolume/nfs-pv created
antigen@deb11notepad:~/netology/07$ kubectl apply -f deploy2.yml
deployment.apps/mydeploy created
```
Смотрим:
```bash
antigen@deb11notepad:~/netology/07$ kubectl get all
NAME                            READY   STATUS    RESTARTS   AGE
pod/mydeploy-7765f876dd-c462j   1/1     Running   0          44s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   24d

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mydeploy   1/1     1            1           44s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/mydeploy-7765f876dd   1         1         1       44s
antigen@deb11notepad:~/netology/07$ kubectl get pvc -o wide
NAME     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
my-pvc   Bound    pvc-b0f6daea-897b-4862-86b7-15c54f0278c0   1Gi        RWO            nfs-csi        17m   Filesystem
```
Проверяем:
```bash
antigen@deb11notepad:~/netology/07$ kubectl exec -it pods/mydeploy-7765f876dd-c462j -c multitool -- sh -c "echo \"Hello World\" > /my_nfs_share/first.txt"
antigen@deb11notepad:~/netology/07$ cat /srv/nfs/pvc-b0f6daea-897b-4862-86b7-15c54f0278c0/first.txt
Hello World
```

------
