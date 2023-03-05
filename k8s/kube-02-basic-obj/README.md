# Домашнее задание к занятию "Базовые объекты K8S"

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера. 

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S)
2. Установленный локальный kubectl
3. Редактор YAML-файлов с подключенным git-репозиторием

------

### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. Описание [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) и примеры манифестов
2. Описание [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

------
Создал `pod` в кубере без проброшеных портов и посмотрел открытые порты в контейнере:
```bash
antigen@deb11:~/kube/02$ kubectl apply -f pod-hello-world.yml
pod/hello-world created
antigen@deb11:~/kube/02$ kubectl logs hello-world
Generating self-signed cert
Generating a 2048 bit RSA private key
...................................................+++
....+++
writing new private key to '/certs/privateKey.key'
-----
Starting nginx
antigen@deb11:~/kube/02$ kubectl exec -i -t hello-world -- netstat -nlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      9/nginx: master pro
tcp        0      0 0.0.0.0:8443            0.0.0.0:*               LISTEN      9/nginx: master pro
Active UNIX domain sockets (only servers)
Proto RefCnt Flags       Type       State         I-Node PID/Program name    Path
```
Удалил ненужный `pod`:
```bash
antigen@deb11:~/kube/02$ kubectl delete pods hello-world
pod "hello-world" deleted
kubectl delete pods hello
```
------
### Задание 1. Создать Pod с именем "hello-world"

> 1. Создать манифест (yaml-конфигурацию) Pod
> 2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2
> 3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере)

Далее создал манифест `pod-hello-world.yml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
  namespace: default
  labels:
    app: hello
spec:
  containers:
    - name: hello-world
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
      ports:
        - name: web-http
          containerPort: 8080
          protocol: TCP
        - name: web-https
          containerPort: 8443
          protocol: TCP

```
Пробросил их: `8080` и `8443`
```bash
antigen@deb11:~/kube/02$ kubectl port-forward hello-world 8080:8080 8443:8443
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Forwarding from 127.0.0.1:8443 -> 8443
Forwarding from [::1]:8443 -> 8443
Handling connection for 8080
Handling connection for 8443
```
Проверил `curl`-ом:
```bash
antigen@deb11:~$ curl http://localhost:8080


Hostname: hello-world

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://localhost:8080/

Request Headers:
        accept=*/*
        host=localhost:8080
        user-agent=curl/7.74.0

Request Body:
        -no body in request-
```
```bash
antigen@deb11:~$ curl -k https://localhost:8443


Hostname: hello-world

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=2
        request_scheme=https
        request_uri=https://localhost:8443/

Request Headers:
        accept=*/*
        host=localhost:8443
        user-agent=curl/7.74.0

Request Body:
```
------

### Задание 2. Создать Service и подключить его к Pod

> 1. Создать Pod с именем "netology-web"
> 2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2
> 3. Создать Service с именем "netology-svc" и подключить к "netology-web"
> 4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере)

Манифест pod-netology-web.yml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  namespace: default
  labels:
    app: netology
spec:
  containers:
    - name: netology-web
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
```
Манифест svs-netology-svc.yml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
  namespace: default
spec:
  ports:
    - name: web-http
      port: 8080
    - name: web-https
      port: 8443
  selector:
    app: netology
```
Создаю `pod` и `service`. Проссматриваю информацию по подам, сервисам и точкам входа:
```bash
antigen@deb11:~/kube/02$ kubectl apply -f pod-netology-web.yml
pod/netology-web created
antigen@deb11:~/kube/02$ kubectl apply -f svc-netology-svc.yml
service/netology-svc created
antigen@deb11:~/kube/02$ kubectl get pods,svc,ep
NAME               READY   STATUS    RESTARTS   AGE
pod/hello-world    1/1     Running   0          42m
pod/netology-web   1/1     Running   0          102s

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/kubernetes     ClusterIP   10.152.183.1     <none>        443/TCP             3h42m
service/netology-svc   ClusterIP   10.152.183.167   <none>        8080/TCP,8443/TCP   7s

NAME                     ENDPOINTS                           AGE
endpoints/kubernetes     192.168.3.192:16443                 3h42m
endpoints/netology-svc   10.1.77.151:8080,10.1.77.151:8443   4s
antigen@deb11:~/kube/02$ kubectl port-forward
daemonsets/              hello-world              netology-web             replicasets/             services/
deployments/             jobs/                    pods/                    replicationcontrollers/  statefulsets/
```
Пробрасываю порты:
```bash
antigen@deb11:~/kube/02$ kubectl port-forward services/netology-svc 8080:8080 8443:8443
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Forwarding from 127.0.0.1:8443 -> 8443
Forwarding from [::1]:8443 -> 8443
Handling connection for 8080
Handling connection for 8443
```
Проверяю `curl`-ом:
```bash
antigen@deb11:~$ curl http://localhost:8080


Hostname: netology-web

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://localhost:8080/

Request Headers:
        accept=*/*
        host=localhost:8080
        user-agent=curl/7.74.0

Request Body:
        -no body in request-

antigen@deb11:~$ curl -k https://localhost:8443


Hostname: netology-web

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=2
        request_scheme=https
        request_uri=https://localhost:8443/

Request Headers:
        accept=*/*
        host=localhost:8443
        user-agent=curl/7.74.0

Request Body:
```
------
