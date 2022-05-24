# 3.2. Работа в терминале, лекция 2 #
1.
```bash
$ type cd
cd is a shell builtin
```
<code>cd</code> - встроенная команда
2. 
```bash
grep -c <some_string> <some_file>
```
3. 
```bash
$ pstree -p | head -1
systemd(1)-+-DiscoverNotifie(2137)-+-{DiscoverNotifie}(2157)
```
4. 
```bash
$ tty
/dev/pts/5
$ ls /tmp/123 > /dev/pts/4 2>&1
```
```bash
$ tty
/dev/pts/4
$ ls: cannot access '/tmp/123': No such file or directory
```
5. 
```bash
$ echo "the test of the test" > test_1 && cat < test_1 > test_2 && cat test_2
the test of the test
```
6. 
```bash
$ ls > /dev/tty2         
$ sudo cat /dev/vcs2 > tty2.txt
$ cat tty2.txt
```
Вывел в файл, чтобы отформатировать вывод 
```bash
$ tty
/dev/tty2
$ lsof -p $$ | grep \/dev
bash    108976 antigen    0u   CHR    4,2      0t0      22 /dev/tty2
bash    108976 antigen    1u   CHR    4,2      0t0      22 /dev/tty2
bash    108976 antigen    2u   CHR    4,2      0t0      22 /dev/tty2
bash    108976 antigen  255u   CHR    4,2      0t0      22 /dev/tty2
$
$ 1  2  Desktop  Documents  Downloads  java_error_in_pycharm_1907.log  java_error_in_pycharm_2057.log  java_error_in_pycharm_3169.log  Music  netology  Pictures  Public  PycharmProjects  Templates  test_1  test_2  tmp  tty2.txt  Videos
```
7. <code>bash 5>&1</code> - приведет к созданию нового дескриптора
```bash
$ lsof -p $$ | grep dev
bash    126048 antigen    0u   CHR  136,5      0t0       8 /dev/pts/5
bash    126048 antigen    1u   CHR  136,5      0t0       8 /dev/pts/5
bash    126048 antigen    2u   CHR  136,5      0t0       8 /dev/pts/5
bash    126048 antigen    5u   CHR  136,5      0t0       8 /dev/pts/5
bash    126048 antigen  255u   CHR  136,5      0t0       8 /dev/pts/5
```
<code>echo netology > /proc/$$/fd/5</code> - отобразит <code>netology</code> в консоли, т.к. ранее осуществили перенаправление потока в <code>stdout</code>

8.
```bash
$ ls /tmp/123 /123/234 /345/123 ~ 2>&1 1>&5 | grep -E "234|tmp"
/home/antigen:
ls: cannot access '/tmp/123': No such file or directory
ls: cannot access '/123/234': No such file or directory
1      2        Documents  java_error_in_pycharm_1907.log  java_error_in_pycharm_3169.log  netology  Public           Templates  test_2  tty2.txt
1.txt  Desktop  Downloads  java_error_in_pycharm_2057.log  Music
```
9. 
```bash
$ cat /proc/$$/environ
SHELL=/bin/bashSESSION_MANAGER=local/antigen-HP-250-G6-Notebook-PC:@/tmp/.ICE-unix/2090,unix/antigen-HP-250-G6-Notebook-PC:/tmp/.ICE-unix/2090WINDOWID=54525959QT_ACCESSIBILITY=1COLORTERM=truecolorXDG_CONFIG_DIRS=/etc/xdg/xdg-plasma:/etc/xdg:/usr/share/kubuntu-default-settings/kf5-settingsXDG_SESSION_PATH=/org/freedesktop/DisplayManager/Session1LANGUAGE=LC_ADDRESS=ru_RU.UTF-8LC_NAME=ru_RU.UTF-8SSH_AUTH_SOCK=/tmp/ssh-M70afYXfq5Rp/agent.1408SHELL_SESSION_ID=fb4c2b8372dc462c925a657ec62ecf0aDESKTOP_SESSION=plasmaLC_MONETARY=ru_RU.UTF-8SSH_AGENT_PID=2033GTK_RC_FILES=/etc/gtk/gtkrc:/home/antigen/.gtkrc:/home/antigen/.config/gtkrcGPG_TTY=ttyXDG_SEAT=seat0PWD=/home/antigenXDG_SESSION_DESKTOP=KDELOGNAME=antigenXDG_SESSION_TYPE=x11GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent:0:1XAUTHORITY=/tmp/xauth-1000-_0GTK2_RC_FILES=/etc/gtk-2.0/gtkrc:/home/antigen/.gtkrc-2.0:/home/antigen/.config/gtkrc-2.0HOME=/home/antigenLC_PAPER=ru_RU.UTF-8LANG=ru_RU.UTF-8LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:XDG_CURRENT_DESKTOP=KDEKONSOLE_DBUS_SERVICE=:1.33KONSOLE_DBUS_SESSION=/Sessions/4PROFILEHOME=XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0KONSOLE_VERSION=191203KDE_SESSION_UID=1000LESSCLOSE=/usr/bin/lesspipe %s %sXDG_SESSION_CLASS=userTERM=xterm-256colorLC_IDENTIFICATION=ru_RU.UTF-8LESSOPEN=| /usr/bin/lesspipe %sLIBVIRT_DEFAULT_URI=qemu:///systemUSER=antigenCOLORFGBG=0;15KDE_SESSION_VERSION=5PAM_KWALLET5_LOGIN=/run/user/1000/kwallet5.socketDISPLAY=:0SHLVL=1LC_TELEPHONE=ru_RU.UTF-8LC_MEASUREMENT=ru_RU.UTF-8XDG_VTNR=1XDG_SESSION_ID=3XDG_RUNTIME_DIR=/run/user/1000LC_TIME=ru_RU.UTF-8QT_AUTO_SCREEN_SCALE_FACTOR=0XCURSOR_THEME=breeze_cursorsXDG_DATA_DIRS=/usr/share/plasma:/usr/local/share:/usr/share:/var/lib/snapd/desktopKDE_FULL_SESSION=truePATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/binDBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/busLC_NUMERIC=ru_RU.UTF-8_=/usr/bin/bashantigen@antigen-HP-250-G6-Notebook-PC:~$ 
```
```bash
$ env
SHELL=/bin/bash
SESSION_MANAGER=local/antigen-HP-250-G6-Notebook-PC:@/tmp/.ICE-unix/2090,unix/antigen-HP-250-G6-Notebook-PC:/tmp/.ICE-unix/2090
WINDOWID=54525959
QT_ACCESSIBILITY=1
COLORTERM=truecolor
XDG_CONFIG_DIRS=/etc/xdg/xdg-plasma:/etc/xdg:/usr/share/kubuntu-default-settings/kf5-settings
XDG_SESSION_PATH=/org/freedesktop/DisplayManager/Session1
LANGUAGE=
LC_ADDRESS=ru_RU.UTF-8
LC_NAME=ru_RU.UTF-8
SSH_AUTH_SOCK=/tmp/ssh-M70afYXfq5Rp/agent.1408
SHELL_SESSION_ID=fb4c2b8372dc462c925a657ec62ecf0a
DESKTOP_SESSION=plasma
LC_MONETARY=ru_RU.UTF-8
SSH_AGENT_PID=2033
GTK_RC_FILES=/etc/gtk/gtkrc:/home/antigen/.gtkrc:/home/antigen/.config/gtkrc
GPG_TTY=tty
XDG_SEAT=seat0
PWD=/home/antigen
LOGNAME=antigen
XDG_SESSION_DESKTOP=KDE
XDG_SESSION_TYPE=x11
GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent:0:1
XAUTHORITY=/tmp/xauth-1000-_0
GTK2_RC_FILES=/etc/gtk-2.0/gtkrc:/home/antigen/.gtkrc-2.0:/home/antigen/.config/gtkrc-2.0
HOME=/home/antigen
LANG=ru_RU.UTF-8
LC_PAPER=ru_RU.UTF-8
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
XDG_CURRENT_DESKTOP=KDE
KONSOLE_DBUS_SERVICE=:1.33
KONSOLE_DBUS_SESSION=/Sessions/4
PROFILEHOME=
XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0
KONSOLE_VERSION=191203
KDE_SESSION_UID=1000
LESSCLOSE=/usr/bin/lesspipe %s %s
XDG_SESSION_CLASS=user
LC_IDENTIFICATION=ru_RU.UTF-8
TERM=xterm-256color
LESSOPEN=| /usr/bin/lesspipe %s
LIBVIRT_DEFAULT_URI=qemu:///system
USER=antigen
COLORFGBG=0;15
KDE_SESSION_VERSION=5
PAM_KWALLET5_LOGIN=/run/user/1000/kwallet5.socket
DISPLAY=:0
SHLVL=2
LC_TELEPHONE=ru_RU.UTF-8
LC_MEASUREMENT=ru_RU.UTF-8
XDG_VTNR=1
XDG_SESSION_ID=3
XDG_RUNTIME_DIR=/run/user/1000
LC_TIME=ru_RU.UTF-8
QT_AUTO_SCREEN_SCALE_FACTOR=0
XCURSOR_THEME=breeze_cursors
XDG_DATA_DIRS=/usr/share/plasma:/usr/local/share:/usr/share:/var/lib/snapd/desktop
KDE_FULL_SESSION=true
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
LC_NUMERIC=ru_RU.UTF-8
_=/usr/bin/env
```
10. 
<code>/proc/<PID>/cmdline</code> - содержит аргументы командной строки.
<code>/proc/<PID>/exe</code> - содержит символическую ссылку к исполняемой команде.

11. 
```bash
$ grep sse /proc/cpuinfo 
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d
```
<code>sse4_2</code>

12. По умолчанию для выполнения команд по <code>ssh</code> псевдо-терминал не выделяется. Необходимо его задавать принудительно ключем <code>-t</code>
```bash
$ ssh localhost -t 'tty'
antigen@localhost's password: 
/dev/pts/9
Connection to localhost closed.
```
13. 
```bash
$ echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null
$ tty
/dev/pts/7
$ ps -a
    PID TTY          TIME CMD
   8321 pts/1    00:00:00 ssh
   8363 pts/5    00:00:00 top
   8417 pts/6    00:00:00 ssh
   8750 pts/7    00:00:00 ps
$ reptyr 8363
```
```bash
top - 16:34:44 up 21 min,  7 users,  load average: 0,47, 0,68, 0,67
Tasks: 276 total,   2 running, 273 sleeping,   0 stopped,   1 zombie
%Cpu(s):  5,2 us,  5,2 sy,  0,0 ni, 89,6 id,  0,0 wa,  0,0 hi,  0,0 si,  0,0 st
MiB Mem :   7868,6 total,   1695,3 free,   2792,5 used,   3380,9 buff/cache
MiB Swap:  17200,0 total,  17200,0 free,      0,0 used.   3808,4 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                                                                                                             
   1206 root      20   0  785464  32948  24972 S   9,8   0,4   2:09.23 asts                                                                                                                                                                
    915 root      20   0  525828  92364  50872 S   3,7   1,1   0:42.33 Xorg                                                                                                                                                                
   1539 antigen   20   0 3096392 131504  90248 R   3,7   1,6   0:51.74 kwin_x11                                                                                                                                                            
   8363 antigen   20   0   12008   4056   3196 R   3,7   0,1   0:01.06 top                                                                                                                                                                 
   2065 antigen   20   0  509000 102440  82592 S   2,4   1,3   0:09.53 yakuake                                                                                                                                                             
   2377 antigen   20   0   36,7g 215680 108488 S   2,4   2,7   1:27.56 rambox                                                                                                                                                              
   2551 antigen   20   0  712432 144204  88956 S   2,4   1,8   0:47.70 rambox                                                                                                                                                              
   2584 antigen   20   0   36,4g 173020 102384 S   1,2   2,1   0:44.74 rambox                                                                                                                                                              
   3378 antigen   20   0   16,3g  34376  21536 S   1,2   0,4   0:00.26 yandex_browser                                                                                                                                                      
   3776 antigen   20   0   36,4g 219864 112296 S   1,2   2,7   0:20.72 rambox                                                                                                                                                              
   3794 antigen   20   0   36,5g 257260 119756 S   1,2   3,2   0:30.17 rambox                                                                                                                                                              
   4029 antigen   20   0   24,4g 137036  94484 S   1,2   1,7   0:03.67 yandex_browser                                                                                                                                                      
   4735 antigen   20   0   36,4g 222344 122952 S   1,2   2,8   0:28.86 rambox                                                                                                                                                              
   8843 antigen   20   0    2600   1860   1760 S   1,2   0,0   0:00.01 reptyr                                                                                                                                                              
      1 root      20   0  167960  11876   8388 S   0,0   0,1   0:01.66 systemd                                                                                                                                                             
      2 root      20   0       0      0      0 S   0,0   0,0   0:00.00 kthreadd                                                                                                                                                            
      3 root       0 -20       0      0      0 I   0,0   0,0   0:00.00 rcu_gp                                                                                                                                                              
      4 root       0 -20       0      0      0 I   0,0   0,0   0:00.00 rcu_par_gp                                                                                                                                                          
      6 root       0 -20       0      0      0 I   0,0   0,0   0:00.00 kworker/0:0H-events_highpri                                                                                                                                         
      9 root       0 -20       0      0      0 I   0,0   0,0   0:00.00 mm_percpu_wq                                                                                                                                                        
     10 root      20   0       0      0      0 S   0,0   0,0   0:00.00 rcu_tasks_rude_                                                                                                                                                     
     11 root      20   0       0      0      0 S   0,0   0,0   0:00.00 rcu_tasks_trace                                                                                                                                                     
     12 root      20   0       0      0      0 S   0,0   0,0   0:00.15 ksoftirqd/0                                                                                                                                                         
     13 root      20   0       0      0      0 I   0,0   0,0   0:01.94 rcu_sched                                                                                                                                                           
     14 root      rt   0       0      0      0 S   0,0   0,0   0:00.01 migration/0
```
Не удалось перенести <code>ping ya.ru</code>

14. <code>tee</code> читает <code>stdin</code> и записывает в <code>stdout</code> и в файл(ы).
Получив поток данных <code>sudo tee</code> запишет его в файл от имени суперпользователя в отличии от <code>sudo echo ></code>, который выполнит <code>echo</code>от суперпользователя, но вывод <code>></code> передаст от самого пользователя.