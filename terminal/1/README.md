# 3.1. Работа в терминале, лекция 1 #
1. ok
2. ok
3. ok
4. ok
5. CPU: 2, RAM: 1Gb, HDD: 64Gb
6. ok
7. ok
8. 
```bash
vagrant@vagrant:~$ man bash | nl | grep HISTSIZE
   748                less than zero inhibit truncation.  The shell sets the default value to the  value  of  HISTSIZE  after
   759         HISTSIZE
  2033                HISTSIZE shell variable.  If an attempt is made to set history-size to a non-numeric value, the maximum
  2596         the  list  of commands previously typed.  The value of the HISTSIZE variable is used as the number of commands
  2597         to save in a history list.  The text of the last HISTSIZE commands (default 500) is saved.  The  shell  stores
  2606         FORMAT variable.  When a shell with history enabled exits, the last $HISTSIZE lines are copied from  the  his‐
```
Строка 759 \
**ignoreboth** - эта директива говорит терминалу не сохранять в истории команды начинающиеся с пробела и дублирующие предыдущие
9. <code>{ }</code> - используются для обозначения списка, тела функции или переменной
```bash
vagrant@vagrant:~$ man bash | nl | grep \{\
   128         ! case  coproc  do done elif else esac fi for function if in select then until while { } time [[ ]]
   176         { list; }
   178                group command.  The return status is the exit status of list.  Note that unlike the metacharacters ( and ), { and } are reserved  words
   278                usually a list of commands between { and }, but may be any command listed under Compound Commands above, with  one  exception:  If  the
   825         pression.  Any incorrectly formed brace expansion is left unchanged.  A { or , may be quoted with a backslash to prevent its being  considered
   826         part  of  a  brace expression.  To avoid conflicts with parameter expansion, the string ${ is not considered eligible for brace expansion, and
```
10. 
```bash
vagrant@vagrant:~$ touch {1..100000}
```
Если количество файлов передаваемые как параметр больше чем буферное пространство, то возникает ошибка
```bash
vagrant@vagrant:~$ touch {1..300000}
-bash: /usr/bin/touch: Argument list too long
```
11. Конструкция <code>[[ ]]</code> возвращает 0 если выражение внутри конструкции дает true, иначе 1 \
<code>[[ -d /tmp ]]</code> - пытается проверить, есть ли директория /tmp
12. 
```bash
vagrant@vagrant:$ mkdir /tmp/new_path_directory
vagrant@vagrant:$ ln -s /bin/bash /tmp/new_path_directory/bash
vagrant@vagrant:~$ PATH=/tmp/new_path_directory/:$PATH
vagrant@vagrant:~$ type -a bash
bash is /tmp/new_path_directory/bash
bash is /usr/bin/bash
bash is /bin/bash
```
13. <code>at</code> - это утилита позволяющая планировать однократное выполнение команды. \
Команда <code>batch</code> ставит задания в очередь.
14. ok
