# Операционные системы, лекция 2 #
1.
```bash
antigen@kenny:~$ cat /etc/systemd/system/node_exporter.service
[Unit]
Description=node_exporter

[Service]
Type=simple
ExecStart=/opt/node_exporter/node_exporter $PARAM
EnvironmentFile=-/opt/node_exporter/node_exporter/node_exporter.conf
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```bash
antigen@kenny:~$ cat /opt/node_exporter/node_exporter.conf
PARAM="--collector.cpu.info \
--collector.cpu.guest"
```
```bash
antigen@kenny:~$ systemctl status node_exporter.service
● node_exporter.service - node_exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-04-01 14:21:07 UTC; 5min ago
   Main PID: 82397 (node_exporter)
      Tasks: 4 (limit: 2197)
     Memory: 5.3M
     CGroup: /system.slice/node_exporter.service
             └─82397 /opt/node_exporter/node_exporter --collector.cpu.info --collector.cpu.guest

Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=thermal_zone
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=time
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=timex
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=udp_queues
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=uname
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=vmstat
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=xfs
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:115 level=info collector=zfs
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.667Z caller=node_exporter.go:199 level=info msg="Listening on" address=:9100
Apr 01 14:21:07 kenny node_exporter[82397]: ts=2022-04-01T14:21:07.668Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=false
```
2.
CPU: 
<code>process_cpu_seconds_total</code> - Total user and system CPU time spent in seconds.
RAM:
<code>node_memory_MemTotal_bytes</code> - Memory information field MemTotal_bytes.
<code>node_memory_MemAvailable_bytes</code> - Memory information field MemAvailable_bytes.
<code>node_memory_MemFree_bytes</code> - Memory information field MemFree_bytes.
HDD:
<code>node_memory_SwapTotal_bytes</code> - Memory information field SwapTotal_bytes.
<code>node_memory_SwapFree_bytes</code> - Memory information field SwapFree_bytes.
<code>node_disk_io_time_seconds_total</code> - Total seconds spent doing I/Os.
NETWORK:
<code>node_network_info</code> - Non-numeric data from /sys/class/net/<iface>, value is always 1
<code>node_network_up</code> - Value is 1 if operstate is 'up', 0 otherwise.
<code>node_network_receive_bytes_total</code> - Network device statistic receive_bytes.
<code>node_network_transmit_bytes_total</code> - Network device statistic transmit_bytes.

3.
OK

4. ОС осознает в чем она запущена.
```bash
antigen@kenny:~$ dmesg | grep virt
[    0.016811] Booting paravirtualized kernel on Hyper-V
[    6.045280] systemd[1]: Detected virtualization microsoft.
```
5.
<code>fs.nr_open</code> - максимальное количество дескрипторов файлов, которые может выделить процесс. Значение по умолчанию равно 1024*1024 (1048576).
```bash
antigen@kenny:~$ sysctl -n fs.nr_open
1048576
```
Жесткое и мякгое ограничения соответственно:
```bash
antigen@kenny:~$ ulimit -Hn
1048576
antigen@kenny:~$ ulimit -Sn
1024
```
Мягкое ограничение не позволит достич 1048576.

6.
```bash
antigen@kenny:~$ sudo -i
root@kenny:~# unshare -f --pid --mount-proc ping ya.ru 1>/dev/null &
[1] 12836
root@kenny:~# ps aux | grep pin[g]
root       12836  0.0  0.0   5480   580 pts/0    S    12:36   0:00 unshare -f --pid --mount-proc ping ya.ru
root       12837  0.0  0.1   7204  2784 pts/0    S    12:36   0:00 ping ya.ru
root@kenny:~# ps
    PID TTY          TIME CMD
  12814 pts/0    00:00:00 sudo
  12815 pts/0    00:00:00 bash
  12836 pts/0    00:00:00 unshare
  12837 pts/0    00:00:00 ping
  12910 pts/0    00:00:00 ps
root@kenny:~# nsenter --target 12837 --pid --mount
root@kenny:/# ps
    PID TTY          TIME CMD
      1 pts/0    00:00:00 ping
      2 pts/0    00:00:00 bashy
     13 pts/0    00:00:00 ps
```
7.
Это так называемая ["Fork-бомба"](https://ru.wikipedia.org/wiki/Fork-бомба "Ссылка на Wiki").  \
Сработал механизм <code>cgroups</code> - это способ ограничить ресурсы внутри конкретной cgroup - контрольной группы процессов.
```bash
[10327.634267] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
```
Параметры по умолчанию:
```bash
antigen@kenny:~$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 7324
max locked memory       (kbytes, -l) 65536
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 7324
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```
Изменить их можно в файле <code>/etc/security/limits.conf</code>
