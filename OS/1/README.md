# 3.3. Операционные системы, лекция 1 #
1. 
```bash
$ strace /bin/bash -c 'cd /tmp' 2>&1 | grep cd
execve("/bin/bash", ["/bin/bash", "-c", "cd /tmp"], 0x7ffd92082180 /* 34 vars */) = 0
```
2. 
```bash
$ strace file /bin/bash 2>&1 | grep openat
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/liblzma.so.5", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libbz2.so.1.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3
openat(AT_FDCWD, "/bin/bash", O_RDONLY|O_NONBLOCK) = 3
```
Скорее всего бд находится в <code>/etc/magic</code>, <code>/usr/share/misc/magic.mgc</code>

3. Поможет только остановка/перезапуск процесса держащего файл.

4. Зомби процесс - это процесс, который завершил свою работу, 
но по каким-то причинам родительский процесс не принял его код завершения.
Таким образом зомби не потребляет ресурсов системы. Занимает место лишь запись в таблице процессов.

5. 
```bash
$ strace opensnoop-bpfcc 2>&1 | grep openat | head
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libutil.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libm.so.6", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libexpat.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3
```
6. 
```bash
$ strace uname -a    
execve("/usr/bin/uname", ["uname", "-a"], 0x7fff3aefd878 /* 62 vars */) = 0
brk(NULL)                               = 0x55c0d2688000
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffe0145a2d0) = -1 EINVAL (Invalid argument)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=121392, ...}) = 0
mmap(NULL, 121392, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f201ff1c000
close(3)                                = 0
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360A\2\0\0\0\0\0"..., 832) = 832
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
pread64(3, "\4\0\0\0\20\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0", 32, 848) = 32
pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0\237\333t\347\262\27\320l\223\27*\202C\370T\177"..., 68, 880) = 68
fstat(3, {st_mode=S_IFREG|0755, st_size=2029560, ...}) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f201ff1a000
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
pread64(3, "\4\0\0\0\20\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0", 32, 848) = 32
pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0\237\333t\347\262\27\320l\223\27*\202C\370T\177"..., 68, 880) = 68
mmap(NULL, 2037344, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f201fd28000
mmap(0x7f201fd4a000, 1540096, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22000) = 0x7f201fd4a000
mmap(0x7f201fec2000, 319488, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x19a000) = 0x7f201fec2000
mmap(0x7f201ff10000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e7000) = 0x7f201ff10000
mmap(0x7f201ff16000, 13920, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f201ff16000
close(3)                                = 0
arch_prctl(ARCH_SET_FS, 0x7f201ff1b580) = 0
mprotect(0x7f201ff10000, 16384, PROT_READ) = 0
mprotect(0x55c0d1519000, 4096, PROT_READ) = 0
mprotect(0x7f201ff67000, 4096, PROT_READ) = 0
munmap(0x7f201ff1c000, 121392)          = 0
brk(NULL)                               = 0x55c0d2688000
brk(0x55c0d26a9000)                     = 0x55c0d26a9000
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=5703856, ...}) = 0
mmap(NULL, 5703856, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f201f7b7000
close(3)                                = 0
uname({sysname="Linux", nodename="antigen-PC", ...}) = 0
fstat(1, {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0x3), ...}) = 0
uname({sysname="Linux", nodename="antigen-PC", ...}) = 0
uname({sysname="Linux", nodename="antigen-PC", ...}) = 0
write(1, "Linux antigen-PC 5.13.0-37-gener"..., 118Linux antigen-PC 5.13.0-37-generic #42~20.04.1-Ubuntu SMP Tue Mar 15 15:44:28 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
) = 118
close(1)                                = 0
close(2)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```
```bash
$ man 2 uname | grep proc
       Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.
$ cat /proc/sys/kernel/{osrelease,version}
5.13.0-37-generic
#42~20.04.1-Ubuntu SMP Tue Mar 15 15:44:28 UTC 2022
```
7. <code>;</code> является лишь разделителем команд. 
<code>&&</code> - как бы объединяет команды и последующая команда выполняется только в том случае, когда предыдущая вернула exitcode =0
<code>set -e</code> - может привести к закрытию оболочки при возникновении кода выхода команды отличной от 0.

8. Данное сочитание ключей увеличивает детализацию ошибок и тушит скрипт на любом шаге при их возникновении. \
<code>-e</code> прерывает выполнение исполнения при ошибке любой команды кроме последней \
<code>-x</code> вывод трейса простых команд \
<code>-u</code> незаданные параметры и переменные считаются как ошибки, с выводом в stderr текста ошибки и выполнит завершение неинтерактивного вызова \
<code>-o pipefail</code> возвращает код возврата последовательности команд, ненулевой при последней команды или 0 для успешного выполнения команд.

9. 
```bash
$ ps -A -o stat --no-headers > 1.ps && for i in {D,I,R,S,T,W,X,Z,N,L}; do echo $i - $(grep -c $i 1.ps); done
D - 1
I - 56
R - 3
S - 214
T - 0
W - 0
X - 0
Z - 0
N - 4
L - 1
```
