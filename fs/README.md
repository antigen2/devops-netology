# 3.5. Файловые системы #

1. ok
2. Все жесткие ссылки на один и тот же файл имеют одинаковую inode, по этому и владелец и правами у них одинаковы.
3. ok
4. 
```bash
antigen@kenny:~$ lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
fd0                         2:0    1     4K  0 disk
loop0                       7:0    0  55.4M  1 loop /snap/core18/2128
loop1                       7:1    0  55.5M  1 loop /snap/core18/2344
loop2                       7:2    0  44.7M  1 loop /snap/snapd/15314
loop3                       7:3    0  70.3M  1 loop /snap/lxd/21029
loop4                       7:4    0  43.6M  1 loop /snap/snapd/15177
loop5                       7:5    0  61.9M  1 loop /snap/core20/1405
loop6                       7:6    0  67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   127G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0   1.5G  0 part /boot
└─sda3                      8:3    0 125.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0  62.8G  0 lvm  /
sdb                         8:16   0     3G  0 disk
sdc                         8:32   0     3G  0 disk
antigen@kenny:~$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xa7281acc.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-6291455, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-6291455, default 6291455): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2):
First sector (4196352-6291455, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-6291455, default 6291455):

Created a new partition 2 of type 'Linux' and of size 1023 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

```
5. 
```bash
antigen@kenny:~$ sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 3 GiB, 3221225472 bytes, 6291456 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0xa7281acc.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 1023 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xa7281acc

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 6291455 2095104 1023M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
```bash
antigen@kenny:~$ lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
fd0                         2:0    1     4K  0 disk
loop0                       7:0    0  55.4M  1 loop /snap/core18/2128
loop1                       7:1    0  55.5M  1 loop /snap/core18/2344
loop2                       7:2    0  44.7M  1 loop /snap/snapd/15314
loop3                       7:3    0  70.3M  1 loop /snap/lxd/21029
loop4                       7:4    0  43.6M  1 loop /snap/snapd/15177
loop5                       7:5    0  61.9M  1 loop /snap/core20/1405
loop6                       7:6    0  67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   127G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0   1.5G  0 part /boot
└─sda3                      8:3    0 125.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0  62.8G  0 lvm  /
sdb                         8:16   0     3G  0 disk
├─sdb1                      8:17   0     2G  0 part
└─sdb2                      8:18   0  1023M  0 part
sdc                         8:32   0     3G  0 disk
├─sdc1                      8:33   0     2G  0 part
└─sdc2                      8:34   0  1023M  0 part
```
6. 
```bash
antigen@kenny:~$ sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Unknown keyword 1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```
7. 
```bash
antigen@kenny:~$ sudo mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: Unknown keyword 1
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```
```bash
antigen@kenny:~$ lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
fd0                         2:0    1     4K  0 disk
loop0                       7:0    0  55.4M  1 loop  /snap/core18/2128
loop1                       7:1    0  55.5M  1 loop  /snap/core18/2344
loop2                       7:2    0  44.7M  1 loop  /snap/snapd/15314
loop3                       7:3    0  70.3M  1 loop  /snap/lxd/21029
loop4                       7:4    0  43.6M  1 loop  /snap/snapd/15177
loop5                       7:5    0  61.9M  1 loop  /snap/core20/1405
loop6                       7:6    0  67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   127G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0   1.5G  0 part  /boot
└─sda3                      8:3    0 125.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0  62.8G  0 lvm   /
sdb                         8:16   0     3G  0 disk
├─sdb1                      8:17   0     2G  0 part
│ └─md0                     9:0    0     2G  0 raid1
└─sdb2                      8:18   0  1023M  0 part
  └─md1                     9:1    0     2G  0 raid0
sdc                         8:32   0     3G  0 disk
├─sdc1                      8:33   0     2G  0 part
│ └─md0                     9:0    0     2G  0 raid1
└─sdc2                      8:34   0  1023M  0 part
  └─md1                     9:1    0     2G  0 raid0
antigen@kenny:~$ echo 'DEVICE partitions containers' | sudo tee /etc/mdadm/mdadm.conf
DEVICE partitions containers
antigen@kenny:~$ mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
mdadm: must be super-user to perform this action
antigen@kenny:~$ sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
ARRAY /dev/md0 metadata=1.2 name=kenny:0 UUID=e6b7aedf:8bc7705c:3da709ad:49d076c0
ARRAY /dev/md1 metadata=1.2 name=kenny:1 UUID=d1227fe7:8af20d2c:077630c6:2722757e
```
8. 
```bash
antigen@kenny:~$ sudo pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
antigen@kenny:~$ sudo pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
```
9. 
```bash
antigen@kenny:~$ sudo vgcreate vg0 /dev/md0 /dev/md1
  Volume group "vg0" successfully created
```
10. 
```bash
antigen@kenny:~$ sudo lvcreate --size 100m --name lv-100 vg0 /dev/md1
  Logical volume "lv-100" created.
```
11. 
```bash
antigen@kenny:~$ sudo mkfs.ext4 /dev/vg0/lv-100
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```
12. 
```bash
antigen@kenny:~$ mkdir /tmp/new
antigen@kenny:~$ sudo mount /dev/vg0/lv-100 /tmp/new/
antigen@kenny:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
udev                               916M     0  916M   0% /dev
tmpfs                              192M  1.1M  191M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv   62G  5.1G   54G   9% /
tmpfs                              960M     0  960M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
tmpfs                              960M     0  960M   0% /sys/fs/cgroup
/dev/loop0                          56M   56M     0 100% /snap/core18/2128
/dev/loop4                          44M   44M     0 100% /snap/snapd/15177
/dev/loop3                          71M   71M     0 100% /snap/lxd/21029
/dev/loop5                          62M   62M     0 100% /snap/core20/1405
/dev/loop2                          45M   45M     0 100% /snap/snapd/15314
/dev/loop6                          68M   68M     0 100% /snap/lxd/22753
/dev/loop1                          56M   56M     0 100% /snap/core18/2344
/dev/sda2                          1.5G  110M  1.3G   8% /boot
tmpfs                              192M     0  192M   0% /run/user/1000
/dev/mapper/vg0-lv--100             93M   72K   86M   1% /tmp/new
```
13. 
```bash
antigen@kenny:~$ sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2022-04-05 20:45:51--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22386118 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                          100%[=====================================================================================>]  21.35M  5.07MB/s    in 4.6s

2022-04-05 20:45:56 (4.67 MB/s) - ‘/tmp/new/test.gz’ saved [22386118/22386118]
```
14. 
```bash
antigen@kenny:~$ lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
fd0                         2:0    1     4K  0 disk
loop0                       7:0    0  55.4M  1 loop  /snap/core18/2128
loop1                       7:1    0  55.5M  1 loop  /snap/core18/2344
loop2                       7:2    0  44.7M  1 loop  /snap/snapd/15314
loop3                       7:3    0  70.3M  1 loop  /snap/lxd/21029
loop4                       7:4    0  43.6M  1 loop  /snap/snapd/15177
loop5                       7:5    0  61.9M  1 loop  /snap/core20/1405
loop6                       7:6    0  67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   127G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0   1.5G  0 part  /boot
└─sda3                      8:3    0 125.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0  62.8G  0 lvm   /
sdb                         8:16   0     3G  0 disk
├─sdb1                      8:17   0     2G  0 part
│ └─md0                     9:0    0     2G  0 raid1
└─sdb2                      8:18   0  1023M  0 part
  └─md1                     9:1    0     2G  0 raid0
    └─vg0-lv--100         253:1    0   100M  0 lvm   /tmp/new
sdc                         8:32   0     3G  0 disk
├─sdc1                      8:33   0     2G  0 part
│ └─md0                     9:0    0     2G  0 raid1
└─sdc2                      8:34   0  1023M  0 part
  └─md1                     9:1    0     2G  0 raid0
    └─vg0-lv--100         253:1    0   100M  0 lvm   /tmp/new
```
15. 
```bash
antigen@kenny:~$ gzip -t /tmp/new/test.gz && echo $?
0
```
16. 
```bash
antigen@kenny:~$ sudo pvmove --name lv-100 /dev/md1 /dev/md0
  /dev/md1: Moved: 8.00%
  /dev/md1: Moved: 100.00%
```
17. 
```bash
antigen@kenny:~$ sudo mdadm --fail /dev/md0 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
antigen@kenny:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid0 sdc2[1] sdb2[0]
      2091008 blocks super 1.2 512k chunks

md0 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]

unused devices: <none>
```
18. 
```bash
antigen@kenny:~$ dmesg | grep md0
[  960.653601] md/raid1:md0: not clean -- starting background reconstruction
[  960.653602] md/raid1:md0: active with 2 out of 2 mirrors
[  960.653609] md0: detected capacity change from 0 to 2144337920
[  960.655054] md: resync of RAID array md0
[  970.792740] md: md0: resync done.
[ 4195.631948] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```
19. 
```bash
antigen@kenny:~$ gzip -t /tmp/new/test.gz && echo $?
0
```
20. ok