## Компьютерные сети, лекция 2 ##

1. Linux:
```bash
antigen@kenny:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:02:01:02 brd ff:ff:ff:ff:ff:ff
    inet 10.11.12.13/24 brd 10.11.12.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::215:5dff:fe02:102/64 scope link
       valid_lft forever preferred_lft forever
antigen@kenny:~$
antigen@kenny:~$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:15:5d:02:01:02 brd ff:ff:ff:ff:ff:ff
antigen@kenny:~$
antigen@kenny:~$ ifconfig -a
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.11.12.13  netmask 255.255.255.0  broadcast 10.11.12.255
        inet6 fe80::215:5dff:fe02:102  prefixlen 64  scopeid 0x20<link>
        ether 00:15:5d:02:01:02  txqueuelen 1000  (Ethernet)
        RX packets 1910586  bytes 325397534 (325.3 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2056599  bytes 199944552 (199.9 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1279  bytes 107901 (107.9 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1279  bytes 107901 (107.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Windows:
```cmd
C:\Users\Admin>ipconfig

Настройка протокола IP для Windows


Адаптер Ethernet vEthernet (virtual_net):

   DNS-суффикс подключения . . . . . :
   Локальный IPv6-адрес канала . . . : fe80::790a:c389:bfa4:c79e%24
   IPv4-адрес. . . . . . . . . . . . : 10.11.12.1
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . :

Адаптер Ethernet vEthernet (CL):

   DNS-суффикс подключения . . . . . :
   Локальный IPv6-адрес канала . . . : fe80::b037:da06:f626:57b4%11
   Автонастройка IPv4-адреса . . . . : 169.254.87.180
   Маска подсети . . . . . . . . . . : 255.255.0.0
   Основной шлюз. . . . . . . . . :

Адаптер Ethernet Ethernet 5:

   DNS-суффикс подключения . . . . . : mybox.local
   IPv4-адрес. . . . . . . . . . . . : 192.168.2.1
   Маска подсети . . . . . . . . . . : 255.255.252.0
   Основной шлюз. . . . . . . . . : 192.168.1.1

Адаптер Ethernet Ethernet 6:

   DNS-суффикс подключения . . . . . :
   Локальный IPv6-адрес канала . . . : fe80::1008:e064:bbc8:50b6%3
   Автонастройка IPv4-адреса . . . . : 169.254.80.182
   Маска подсети . . . . . . . . . . : 255.255.0.0
   Основной шлюз. . . . . . . . . :

Адаптер Ethernet Ethernet 3:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . : mybox.local

Адаптер Ethernet VMware Network Adapter VMnet1:

   DNS-суффикс подключения . . . . . :
   Локальный IPv6-адрес канала . . . : fe80::1439:cd5a:3326:d86f%12
   IPv4-адрес. . . . . . . . . . . . : 192.168.176.1
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . :

Адаптер Ethernet VMware Network Adapter VMnet8:

   DNS-суффикс подключения . . . . . :
   Локальный IPv6-адрес канала . . . : fe80::528:3b6d:d98f:4eeb%21
   IPv4-адрес. . . . . . . . . . . . : 192.168.211.1
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . :

Адаптер Ethernet vEthernet (Default Switch):

   DNS-суффикс подключения . . . . . :
   Локальный IPv6-адрес канала . . . : fe80::b46f:9083:8dd:ff87%40
   IPv4-адрес. . . . . . . . . . . . : 172.24.144.1
   Маска подсети . . . . . . . . . . : 255.255.240.0
   Основной шлюз. . . . . . . . . :
```
2. Т.к. виртуалка находится за NATом, ничего не выводится lldpd
```bash
antigen@kenny:~$ lldpctl -d
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
```
Но arp видит соседние устройства:
```bash
antigen@kenny:~$ arp -a
? (10.11.12.14) at 00:15:5d:02:01:06 [ether] on eth0
_gateway (10.11.12.1) at 00:15:5d:02:01:03 [ether] on eth0
```
3. Используется технология VLAN. Для управления в Linux есть пакет vlan. \
Установка пакета в ubuntu:
```bash
antigen@kenny:~$ sudo apt install vlan
```
Добавление поддержки протокола 802.1q в ядро:
```bash
antigen@kenny:~$ sudo modprobe 8021q
```
Создание vlan id 30 на физическом интерфейсе eth0:
```bash
antigen@kenny:~$ sudo vconfig add eth0 30
```
Присвоение адреса новому интерфейсу:
```bash
antigen@kenny:~$ sudo ip addr add 172.16.100.1/24 dev eth0.30
```
Стартуем новый интерфейс:
```bash
antigen@kenny:~$ sudo ip link set up eth0.30
```
Итог:
```bash
antigen@kenny:~$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.11.12.13/24 fe80::215:5dff:fe02:102/64
eth0.30@eth0     UP             172.16.100.1/24 fe80::215:5dff:fe02:102/64
eth0.40@eth0     DOWN
```
Конфиг netplan в ubuntu 20.04:
```bash
antigen@kenny:~$ cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    eth0:
      dhcp4: no
      addresses:
       - 10.11.12.13/24
      gateway4: 10.11.12.1
      nameservers:
        addresses: [10.11.12.1, 77.88.8.8, 8.8.4.4]
      optional: true
  vlans: 
    vlan30:
      id: 30
      link: eth0
      dhcp4: no
      addresses: [172.16.100.1/24]
  version: 2
  renderer: networkd
```
4. Агрегация портов в Linux называется bonding-ом. Типы агрегации:
```bash
antigen@kenny:~$ modinfo bonding | grep mode
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
```
Балансировки можно достичь с помощью опций: <code>balance-rr</code>, <code>balance-xor</code>, <code>balance-tlb</code>, <code>balance-alb</code>. \
Конфиг для netplan:
```bash
network: 
  renderer: networkd 
  version: 2 
  ethernets: 
    eth0:
      dhcp4: no
    eth1:
      dhcp4: no
  bonds: 
    bond0:
      dhcp4: no
      addresses: [172.16.1.10/24]
      gateway4: 172.16.1.1
      interfaces: [eth0, eth1]
      parameters:
        mode: balance-rr
          mii-monitor-interval: 1
```
5. Подсеть /29 занимает 8 адресов, но использовать для машин можно только <code>6</code>.
```bash
antigen@antigen-PC:~$ ipcalc 10.10.10.1/29
Address:   10.10.10.1           00001010.00001010.00001010.00000 001
Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
=>
Network:   10.10.10.0/29        00001010.00001010.00001010.00000 000
HostMin:   10.10.10.1           00001010.00001010.00001010.00000 001
HostMax:   10.10.10.6           00001010.00001010.00001010.00000 110
Broadcast: 10.10.10.7           00001010.00001010.00001010.00000 111
Hosts/Net: 6                     Class A, Private Internet
```
В подсеть /24 влазиет 256/8=32 посети /29 \
Примеры подсетей /29 входящих в подсеть <code>10.10.10.0/24</code>
```bash
antigen@antigen-PC:~$ ipcalc -b 10.10.10.1/29
Address:   10.10.10.1           
Netmask:   255.255.255.248 = 29 
Wildcard:  0.0.0.7              
=>
Network:   10.10.10.0/29        
HostMin:   10.10.10.1           
HostMax:   10.10.10.6           
Broadcast: 10.10.10.7           
Hosts/Net: 6                     Class A, Private Internet

antigen@antigen-PC:~$ ipcalc -b 10.10.10.8/29
Address:   10.10.10.8           
Netmask:   255.255.255.248 = 29 
Wildcard:  0.0.0.7              
=>
Network:   10.10.10.8/29        
HostMin:   10.10.10.9           
HostMax:   10.10.10.14          
Broadcast: 10.10.10.15          
Hosts/Net: 6                     Class A, Private Internet

antigen@antigen-PC:~$ ipcalc -b 10.10.10.16/29
Address:   10.10.10.16          
Netmask:   255.255.255.248 = 29 
Wildcard:  0.0.0.7              
=>
Network:   10.10.10.16/29       
HostMin:   10.10.10.17          
HostMax:   10.10.10.22          
Broadcast: 10.10.10.23          
Hosts/Net: 6                     Class A, Private Internet
```
6. Адреса можно взять из подсети <code>100.64.0.0/10</code>. Для 40-50 хостов достаточно будет взять подсеть /26:
```bash
antigen@antigen-PC:~$ ipcalc -b --split 50 100.64.0.0/10
Address:   100.64.0.0
Netmask:   255.192.0.0 = 10
Wildcard:  0.63.255.255
=>
Network:   100.64.0.0/10
HostMin:   100.64.0.1
HostMax:   100.127.255.254      
Broadcast: 100.127.255.255      
Hosts/Net: 4194302               Class A

1. Requested size: 50 hosts
Netmask:   255.255.255.192 = 26 
Network:   100.64.0.0/26        
HostMin:   100.64.0.1           
HostMax:   100.64.0.62          
Broadcast: 100.64.0.63          
Hosts/Net: 62                    Class A

Needed size:  64 addresses.
Used network: 100.64.0.0/26
Unused:
100.64.0.64/26
100.64.0.128/25
100.64.1.0/24
100.64.2.0/23
100.64.4.0/22
100.64.8.0/21
100.64.16.0/20
100.64.32.0/19
100.64.64.0/18
100.64.128.0/17
100.65.0.0/16
100.66.0.0/15
100.68.0.0/14
100.72.0.0/13
100.80.0.0/12
100.96.0.0/11
```
7. Просмотр ARP таблиц:
  - windows: <code>arp -a</code>
  - linux: <code>ip n</code>, <code>arp -n</code> \
Очистка ARP кэша:
  - windows: <code>arp -d *</code>
  - linux: <code>ip n f</code> \
Удалить из ARP таблицы 1 ip:
  - windows: <code>arp -d 10.10.0.7</code>
  - linux: <code>ip n d 10.10.0.7 dev eth0</code>, <code>arp -d 10.10.0.7</code>
8. Ok