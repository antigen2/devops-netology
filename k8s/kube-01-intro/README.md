# Домашнее задание к занятию "Kubernetes. Причины появления. Команда kubectl"

### Цель задания

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

------

### Чеклист готовности к домашнему заданию

1. Личный компьютер с ОС Linux или MacOS 

или

2. ВМ c ОС Linux в облаке либо ВМ на локальной машине для установки MicroK8S  

------

### Инструкция к заданию

1. Установка MicroK8S:
    - sudo apt update
    - sudo apt install snapd
    - sudo snap install microk8s --classic
    - добавить локального пользователя в группу `sudo usermod -a -G microk8s $USER`
    - изменить права на папку с конфигурацией `sudo chown -f -R $USER ~/.kube`

2. Полезные команды:
    - проверить статус `microk8s status --wait-ready`
    - подключиться к microK8s и получить информацию можно через команду `microk8s command`, например, `microk8s kubectl get nodes`
    - включить addon можно через команду `microk8s enable` 
    - список addon'ов `microk8s status`
    - вывод конфигурации `microk8s config`
    - проброс порта для подключения локально `microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443`

3. Настройка внешнего подключения:
    - Отредактировать файл /var/snap/microk8s/current/certs/csr.conf.template
    ```shell
    # [ alt_names ]
    # Add
    # IP.4 = 123.45.67.89
    ```
    - Обновить сертификаты `sudo microk8s refresh-certs --cert front-proxy-client.crt`

4. Установка kubectl:
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    - chmod +x ./kubectl
    - sudo mv ./kubectl /usr/local/bin/kubectl 
    - настройка автодополнения в текущую сессию `bash source <(kubectl completion bash)`
    - добавление автодополнения в командную оболочку bash `echo "source <(kubectl completion bash)" >> ~/.bashrc`

------

### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**

------

### Задание 1. Установка MicroK8S

> 1. Установить MicroK8S на локальную машину или на удаленную виртуальную машину
> 2. Установить dashboard
> 3. Сгенерировать сертификат для подключения к внешнему ip-адресу

```bash
antigen@laptop:~$ microk8s enable dashboard
...
antigen@laptop:~$ microk8s status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # (core) The Kubernetes dashboard
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
    rbac                 # (core) Role-Based Access Control for authorisation
  disabled:
    cert-manager         # (core) Cloud native certificate management
    community            # (core) The community addons repository
    dns                  # (core) CoreDNS
    gpu                  # (core) Automatic enablement of Nvidia CUDA
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    minio                # (core) MinIO object storage
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    registry             # (core) Private image registry exposed on localhost:32000
    storage              # (core) Alias to hostpath-storage add-on, deprecated
antigen@laptop:~$ microk8s kubectl describe secret -n kube-system microk8s-dashboard-token
Name:         microk8s-dashboard-token
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 86607d5e-d58e-4201-8655-26ab49f1c932

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1123 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IkNBdW9pLW9xNEFIUC12cU1GQVRaM1BTTUhfQ0ViWThOYnM5Nk1GWk5VR3MifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJtaWNyb2s4cy1kYXNoYm9hcmQtdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijg2NjA3ZDVlLWQ1OGUtNDIwMS04NjU1LTI2YWI0OWYxYzkzMiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkZWZhdWx0In0.ZsjODFz1GtZRw1o0AwYqX15P6ty9ykUb_SzlUd7kqhcsh5dMJEAoCRA8p9cJ6v7RL-zRQqeWiXOMuzv46CW2GeGXMVivaEjysHSxicN3-yIsRyd5xbIwbMzf8Np_GBJh4aIvmBPLhvXeqt2VSMLUbIbpr6GQDYz0ed0iVTLf9MvrsQy-YN-4byREVUoXfRCpxGMn_g2pYZXYWVaFcaffFwt0yw3jrqxiPFAtc5j60ohsmcXf2BLsFmFclKub0d6eR228NMNQ_FqYwT2QKs1YRIAmPQPrl9YSUs3pKiwAhEebjMKU78S1LmUusrwFdctlXYykPUi54QmsLwJ3FFQXsA
```

------

### Задание 2. Установка и настройка локального kubectl
> 1. Установить на локальную машину kubectl
> 2. Настроить локально подключение к кластеру
> 3. Подключиться к дашборду с помощью port-forward

```bash
antigen@laptop:~$ microk8s config > ~/.kube/config
antigen@laptop:~$
antigen@laptop:~$ kubectl get nodes
NAME     STATUS   ROLES    AGE    VERSION
laptop   Ready    <none>   146m   v1.26.0
antigen@laptop:~$
antigen@laptop:~$ kubectl port-forward -n kube-system service/kubernetes-dashboard 8443:443
Forwarding from 127.0.0.1:8443 -> 8443
Forwarding from [::1]:8443 -> 8443
```

![](img/11-01.02.png)

Токен для подключения к дашборду в '~/.kube/config'
![](img/11-01.01.png)

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get nodes`, а также скриншот дашборда

------

### Критерии оценки
Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки.