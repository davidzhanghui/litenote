# Linux 运维监控命令详解

## 目录

- [1. 系统概览](#1-系统概览)
- [2. CPU 监控](#2-cpu-监控)
- [3. 内存监控](#3-内存监控)
- [4. 磁盘监控](#4-磁盘监控)
- [5. 网络监控](#5-网络监控)
- [6. 进程监控](#6-进程监控)
- [7. I/O 监控](#7-io-监控)
- [8. 系统负载监控](#8-系统负载监控)
- [9. 日志监控](#9-日志监控)
- [10. 综合监控工具](#10-综合监控工具)
- [11. 性能测试工具](#11-性能测试工具)
- [12. 监控最佳实践](#12-监控最佳实践)

## 1. 系统概览

### 1.1 uptime

显示系统运行时间和平均负载。

**语法：**

```bash
uptime [选项]
```

**常用选项：**

- `-p, --pretty`：以易读格式显示运行时间
- `-s, --since`：显示系统启动时间

**示例：**

```bash
$ uptime
 10:45:20 up 15 days, 2:38, 5 users, load average: 0.15, 0.10, 0.09
```

**输出解释：**

- `10:45:20`：当前系统时间
- `up 15 days, 2:38`：系统已运行时间
- `5 users`：当前登录用户数
- `load average: 0.15, 0.10, 0.09`：最近1分钟、5分钟和15分钟的平均负载

### 1.2 w

显示当前登录用户及其活动。

**语法：**

```bash
w [选项] [用户名]
```

**常用选项：**

- `-h`：不显示标题
- `-s`：简短格式，不显示登录时间、JCPU和PCPU时间

**示例：**

```bash
$ w
 10:46:32 up 15 days,  2:39,  5 users,  load average: 0.15, 0.11, 0.09
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
user1    pts/0    192.168.1.5      10:30    3.00s  0.09s  0.04s w
user2    pts/1    192.168.1.10     09:15    1:20   0.05s  0.05s -bash
```

**输出解释：**

- `USER`：用户名
- `TTY`：终端名称
- `FROM`：远程主机名或IP地址
- `LOGIN@`：登录时间
- `IDLE`：空闲时间
- `JCPU`：与该tty关联的所有进程使用的时间
- `PCPU`：当前进程使用的时间
- `WHAT`：当前正在运行的命令

### 1.3 uname

显示系统信息。

**语法：**

```bash
uname [选项]
```

**常用选项：**

- `-a, --all`：显示所有信息
- `-s, --kernel-name`：显示内核名称
- `-r, --kernel-release`：显示内核版本
- `-v, --kernel-version`：显示内核发行版本
- `-m, --machine`：显示机器硬件名称
- `-p, --processor`：显示处理器类型
- `-o, --operating-system`：显示操作系统名称

**示例：**

```bash
$ uname -a
Linux server1 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

## 2. CPU 监控

### 2.1 top

实时显示系统进程和资源使用情况。

**语法：**

```bash
top [选项]
```

**常用选项：**

- `-d SEC`：指定刷新间隔（秒）
- `-p PID`：监控指定进程
- `-u USER`：显示指定用户的进程
- `-b`：批处理模式，适合输出到文件
- `-n NUM`：指定刷新次数后退出

**交互命令：**

- `h`：显示帮助
- `q`：退出
- `k`：杀死进程
- `r`：重新设置进程优先级
- `c`：显示完整命令行
- `M`：按内存使用率排序
- `P`：按CPU使用率排序
- `T`：按运行时间排序
- `1`：显示所有CPU核心的使用情况

**示例：**

```bash
$ top -d 2 -p 1234
```

**输出解释：**

```
top - 10:50:45 up 15 days,  2:43,  5 users,  load average: 0.10, 0.09, 0.09
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.0 us,  1.0 sy,  0.0 ni, 96.9 id,  0.0 wa,  0.0 hi,  0.1 si,  0.0 st
MiB Mem :  16096.2 total,   8105.6 free,   2631.4 used,   5359.2 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used.  12885.5 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 1234 user1     20   0  743.8m  16.5m   8.8m S   0.0   0.1   0:00.91 process_name
```

- 第一行：系统时间、运行时间、用户数和平均负载
- 第二行：进程总数及各状态进程数
- 第三行：CPU使用率（us=用户空间、sy=系统空间、ni=优先级调整、id=空闲、wa=等待I/O、hi=硬件中断、si=软件中断、st=虚拟机偷取）
- 第四行：物理内存使用情况
- 第五行：交换空间使用情况
- 进程列表：
  - `PID`：进程ID
  - `USER`：进程所有者
  - `PR`：优先级
  - `NI`：nice值
  - `VIRT`：虚拟内存使用
  - `RES`：物理内存使用
  - `SHR`：共享内存
  - `S`：进程状态（R=运行、S=睡眠、D=不可中断睡眠、Z=僵尸、T=停止）
  - `%CPU`：CPU使用率
  - `%MEM`：内存使用率
  - `TIME+`：进程使用的CPU时间
  - `COMMAND`：命令名/行

### 2.2 mpstat

显示处理器相关统计信息。

**语法：**

```bash
mpstat [选项] [间隔] [次数]
```

**常用选项：**

- `-P {CPU|ALL}`：指定处理器编号，ALL表示所有处理器
- `-u`：报告CPU使用率
- `-I {SUM|CPU|SCPU|ALL}`：报告中断统计信息

**示例：**

```bash
$ mpstat -P ALL 2 3
```

**输出解释：**

```
Linux 5.4.0-42-generic (server1)    07/20/2023      _x86_64_        (4 CPU)

10:55:43     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:55:45     all    2.01    0.00    0.75    0.00    0.00    0.13    0.00    0.00    0.00   97.11
10:55:45       0    2.53    0.00    1.01    0.00    0.00    0.51    0.00    0.00    0.00   95.96
10:55:45       1    1.52    0.00    0.51    0.00    0.00    0.00    0.00    0.00    0.00   97.98
10:55:45       2    2.02    0.00    0.51    0.00    0.00    0.00    0.00    0.00    0.00   97.47
10:55:45       3    2.02    0.00    1.01    0.00    0.00    0.00    0.00    0.00    0.00   96.97
```

- `%usr`：用户空间占用CPU百分比
- `%nice`：改变过优先级的进程占用CPU百分比
- `%sys`：内核空间占用CPU百分比
- `%iowait`：等待I/O完成的CPU时间百分比
- `%irq`：硬中断占用CPU的百分比
- `%soft`：软中断占用CPU的百分比
- `%steal`：虚拟机被迫等待虚拟CPU的时间百分比
- `%guest`：运行虚拟处理器的CPU百分比
- `%gnice`：运行优先级调整过的虚拟处理器的CPU百分比
- `%idle`：CPU空闲时间百分比

### 2.3 vmstat

报告虚拟内存统计信息。

**语法：**

```bash
vmstat [选项] [延迟 [次数]]
```

**常用选项：**

- `-a`：显示活跃和非活跃内存
- `-f`：显示从系统启动以来执行的fork数量
- `-m`：显示slab信息
- `-s`：显示内存相关统计信息
- `-d`：显示磁盘统计信息
- `-p 分区`：显示指定分区统计信息

**示例：**

```bash
$ vmstat 2 5
```

**输出解释：**

```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0 8105600 1048576 4310528    0    0     5     6   88  132  2  1 97  0  0
 0  0      0 8105600 1048576 4310528    0    0     0     0  133  244  1  0 99  0  0
 0  0      0 8105600 1048576 4310528    0    0     0     0  136  242  1  0 99  0  0
```

- `procs`：进程
  - `r`：运行队列中的进程数
  - `b`：等待I/O的进程数
- `memory`：内存
  - `swpd`：使用的虚拟内存大小
  - `free`：空闲内存大小
  - `buff`：用作缓冲的内存大小
  - `cache`：用作缓存的内存大小
- `swap`：交换空间
  - `si`：每秒从交换区写入内存的大小
  - `so`：每秒写入交换区的内存大小
- `io`：块设备I/O
  - `bi`：每秒读取的块数
  - `bo`：每秒写入的块数
- `system`：系统
  - `in`：每秒中断数，包括时钟中断
  - `cs`：每秒上下文切换数
- `cpu`：CPU时间百分比
  - `us`：用户进程执行时间
  - `sy`：系统进程执行时间
  - `id`：空闲时间
  - `wa`：等待I/O时间
  - `st`：虚拟机偷取时间

### 2.4 pidstat

监控进程的CPU、内存、I/O等使用情况。

**语法：**

```bash
pidstat [选项] [间隔] [次数]
```

**常用选项：**

- `-u`：报告CPU使用情况
- `-r`：报告内存使用情况
- `-d`：报告I/O使用情况
- `-p PID`：指定进程ID
- `-t`：显示线程信息
- `-w`：显示上下文切换信息

**示例：**

```bash
$ pidstat -u -p 1234 2 5
```

**输出解释：**

```
Linux 5.4.0-42-generic (server1)    07/20/2023      _x86_64_        (4 CPU)

11:00:12      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11:00:14     1000      1234    0.50    0.00    0.00    0.00    0.50     1  process_name
11:00:16     1000      1234    0.00    0.00    0.00    0.00    0.00     1  process_name
```

- `UID`：用户ID
- `PID`：进程ID
- `%usr`：进程在用户空间占用CPU的百分比
- `%system`：进程在内核空间占用CPU的百分比
- `%guest`：进程在虚拟机占用CPU的百分比
- `%wait`：进程等待CPU的时间百分比
- `%CPU`：进程占用CPU的百分比
- `CPU`：进程运行的CPU编号
- `Command`：命令名

## 3. 内存监控

### 3.1 free

显示系统内存使用情况。

**语法：**

```bash
free [选项]
```

**常用选项：**

- `-b, --bytes`：以字节为单位显示
- `-k, --kilo`：以KB为单位显示
- `-m, --mega`：以MB为单位显示
- `-g, --giga`：以GB为单位显示
- `-h, --human`：以人类可读格式显示
- `-s, --seconds SEC`：每隔SEC秒显示一次
- `-c, --count COUNT`：显示COUNT次后退出
- `-t, --total`：显示RAM+swap的总和
- `-w, --wide`：宽输出模式

**示例：**

```bash
$ free -h
```

**输出解释：**

```
              total        used        free      shared  buff/cache   available
Mem:           15Gi       2.5Gi       7.9Gi       306Mi       5.1Gi        12Gi
Swap:         4.0Gi          0B       4.0Gi
```

- `total`：总内存大小
- `used`：已使用内存大小
- `free`：空闲内存大小
- `shared`：共享内存大小
- `buff/cache`：缓冲区和缓存大小
- `available`：可用内存大小（应用程序可用的内存大小，包括部分缓存可回收的内存）

### 3.2 pmap

显示进程的内存映射。

**语法：**

```bash
pmap [选项] PID
```

**常用选项：**

- `-x`：显示扩展格式
- `-d`：显示设备格式
- `-q`：不显示标题和页脚

**示例：**

```bash
$ pmap -x 1234
```

**输出解释：**

```
1234:   process_name
Address           Kbytes     RSS   Dirty Mode  Mapping
0000000000400000     304     304       0 r-x-- process_name
0000000000650000      40      40      40 rw--- process_name
00007f4a6c000000    1024     296     296 rw--- [ anon ]
00007f4a6c100000   65536       0       0 -----   [ anon ]
... (更多内存映射条目) ...
----------------  -------  -------  -------
total kB          743808    16896     8832
```

- `Address`：内存地址
- `Kbytes`：虚拟内存大小（KB）
- `RSS`：物理内存大小（KB）
- `Dirty`：脏页大小（KB）
- `Mode`：内存权限（r=读、w=写、x=执行、s=共享、p=私有）
- `Mapping`：映射的文件或库名

### 3.3 smem

显示进程内存使用情况的高级工具。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install smem

# CentOS/RHEL
sudo yum install smem
```

**语法：**
```bash
smem [选项]
```

**常用选项：**
- `-p`：显示进程信息
- `-u`：按用户分组显示
- `-m`：显示映射信息
- `-t`：显示总计
- `-k`：以KB为单位显示
- `-s FIELD`：按指定字段排序

**示例：**
```bash
$ smem -t -k
```

**输出解释：**
```
  PID User     Command                         Swap      USS      PSS      RSS 
 1234 user1    /usr/bin/process_name              0     1024     1536     2048
 5678 user2    /usr/sbin/another_process          0      512      768     1024
-------------------------------------------------------------------------------
    2 2                                           0     1536     2304     3072
```

- `USS`：Unique Set Size，进程独占的物理内存
- `PSS`：Proportional Set Size，USS + 共享内存的一部分
- `RSS`：Resident Set Size，进程占用的物理内存
- `Swap`：进程使用的交换空间

## 4. 磁盘监控

### 4.1 df

显示文件系统磁盘空间使用情况。

**语法：**
```bash
df [选项] [文件系统]
```

**常用选项：**
- `-h, --human-readable`：以人类可读格式显示
- `-T, --print-type`：显示文件系统类型
- `-i, --inodes`：显示inode信息
- `-a, --all`：显示所有文件系统
- `-t TYPE`：只显示指定类型的文件系统
- `-x TYPE`：排除指定类型的文件系统

**示例：**
```bash
$ df -hT
```

**输出解释：**
```
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/sda1      ext4       20G  8.5G   11G  45% /
/dev/sda2      ext4      100G   45G   50G  48% /home
tmpfs          tmpfs     8.0G     0  8.0G   0% /dev/shm
/dev/sdb1      xfs       500G  200G  300G  40% /data
```

- `Filesystem`：文件系统设备名
- `Type`：文件系统类型
- `Size`：总大小
- `Used`：已使用空间
- `Avail`：可用空间
- `Use%`：使用百分比
- `Mounted on`：挂载点

### 4.2 du

显示目录或文件的磁盘使用情况。

**语法：**
```bash
du [选项] [目录/文件]
```

**常用选项：**
- `-h, --human-readable`：以人类可读格式显示
- `-s, --summarize`：只显示总计
- `-a, --all`：显示所有文件和目录
- `-d, --max-depth=N`：最大目录深度
- `-c, --total`：显示总计
- `-x, --one-file-system`：不跨越文件系统边界
- `--exclude=PATTERN`：排除匹配模式的文件

**示例：**
```bash
# 显示当前目录各子目录大小
$ du -h --max-depth=1

# 显示最大的10个目录
$ du -h | sort -hr | head -10

# 显示指定目录总大小
$ du -sh /var/log
```

**输出解释：**
```
4.0K    ./dir1
8.0K    ./dir2
12K     ./dir3
24K     .
```

### 4.3 lsblk

以树状格式显示块设备信息。

**语法：**
```bash
lsblk [选项] [设备]
```

**常用选项：**
- `-a`：显示所有设备
- `-f`：显示文件系统信息
- `-m`：显示权限信息
- `-t`：显示拓扑信息
- `-o COLUMNS`：指定显示的列

**示例：**
```bash
$ lsblk -f
```

**输出解释：**
```
NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
sda                                                      
├─sda1 ext4         550e8400-e29b-41d4-a716-446655440000 /
├─sda2 ext4         550e8400-e29b-41d4-a716-446655440001 /home
└─sda3 swap         550e8400-e29b-41d4-a716-446655440002 [SWAP]
sdb                                                      
└─sdb1 xfs          550e8400-e29b-41d4-a716-446655440003 /data
```

### 4.4 iostat

显示CPU和I/O统计信息。

**语法：**
```bash
iostat [选项] [间隔] [次数]
```

**常用选项：**
- `-c`：只显示CPU统计信息
- `-d`：只显示设备统计信息
- `-x`：显示扩展统计信息
- `-k`：以KB为单位显示
- `-m`：以MB为单位显示
- `-t`：显示时间戳

**示例：**
```bash
$ iostat -x 2 5
```

**输出解释：**
```
Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     0.50    1.00    2.00    16.00    20.00    24.00     0.01    3.33    2.00    4.00   1.67   0.50
sdb               0.00     0.00    0.50    1.50     8.00    12.00    20.00     0.00    2.00    1.00    2.50   1.00   0.20
```

- `rrqm/s`：每秒合并的读请求数
- `wrqm/s`：每秒合并的写请求数
- `r/s`：每秒读请求数
- `w/s`：每秒写请求数
- `rkB/s`：每秒读取的KB数
- `wkB/s`：每秒写入的KB数
- `avgrq-sz`：平均请求大小（扇区）
- `avgqu-sz`：平均队列长度
- `await`：平均等待时间（毫秒）
- `r_await`：读请求平均等待时间
- `w_await`：写请求平均等待时间
- `svctm`：平均服务时间（毫秒）
- `%util`：设备利用率百分比

### 4.5 iotop

实时显示进程I/O使用情况。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install iotop

# CentOS/RHEL
sudo yum install iotop
```

**语法：**
```bash
iotop [选项]
```

**常用选项：**
- `-o, --only`：只显示有I/O活动的进程
- `-b, --batch`：批处理模式
- `-n NUM`：指定刷新次数
- `-d SEC`：指定刷新间隔
- `-p PID`：监控指定进程
- `-u USER`：监控指定用户的进程
- `-P, --processes`：显示进程而不是线程
- `-a, --accumulated`：显示累积I/O

**示例：**
```bash
$ sudo iotop -o
```

**输出解释：**
```
Total DISK READ :       0.00 B/s | Total DISK WRITE :      12.00 K/s
Current DISK READ:      0.00 B/s | Current DISK WRITE:    12.00 K/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
 1234  be/4  user1        0.00 B/s   12.00 K/s  0.00 %  0.50 % process_name
 5678  be/4  user2        0.00 B/s    0.00 B/s  0.00 %  0.00 % another_process
```

- `TID`：线程ID
- `PRIO`：I/O优先级
- `USER`：用户名
- `DISK READ`：磁盘读取速度
- `DISK WRITE`：磁盘写入速度
- `SWAPIN`：交换区读取百分比
- `IO>`：I/O等待百分比
- `COMMAND`：命令名

## 5. 网络监控

### 5.1 netstat

显示网络连接、路由表、接口统计等信息。

**语法：**
```bash
netstat [选项]
```

**常用选项：**
- `-a, --all`：显示所有连接和监听端口
- `-t, --tcp`：显示TCP连接
- `-u, --udp`：显示UDP连接
- `-l, --listening`：只显示监听端口
- `-n, --numeric`：以数字形式显示地址和端口
- `-p, --programs`：显示进程ID和名称
- `-r, --route`：显示路由表
- `-i, --interfaces`：显示网络接口
- `-s, --statistics`：显示网络统计信息

**示例：**
```bash
# 显示所有TCP连接
$ netstat -ant

# 显示监听端口及对应进程
$ netstat -tlnp

# 显示网络统计信息
$ netstat -s
```

**输出解释：**
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1234/sshd
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      5678/mysqld
tcp        0     52 192.168.1.100:22       192.168.1.200:54321     ESTABLISHED 9012/sshd
```

- `Proto`：协议类型
- `Recv-Q`：接收队列中的字节数
- `Send-Q`：发送队列中的字节数
- `Local Address`：本地地址和端口
- `Foreign Address`：远程地址和端口
- `State`：连接状态
- `PID/Program name`：进程ID和程序名

### 5.2 ss

现代版本的netstat，性能更好。

**语法：**
```bash
ss [选项] [过滤器]
```

**常用选项：**
- `-a, --all`：显示所有套接字
- `-t, --tcp`：显示TCP套接字
- `-u, --udp`：显示UDP套接字
- `-l, --listening`：显示监听套接字
- `-n, --numeric`：不解析服务名
- `-p, --processes`：显示进程信息
- `-s, --summary`：显示套接字统计信息
- `-4, --ipv4`：只显示IPv4
- `-6, --ipv6`：只显示IPv6

**示例：**
```bash
# 显示所有TCP连接
$ ss -ant

# 显示监听端口
$ ss -tlnp

# 显示特定端口的连接
$ ss -ant sport = :80

# 显示统计信息
$ ss -s
```

**输出解释：**
```
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
LISTEN     0      128    *:22                            *:*                    users:(("sshd",pid=1234,fd=3))
ESTAB      0      52     192.168.1.100:22               192.168.1.200:54321    users:(("sshd",pid=9012,fd=3))
```

### 5.3 iftop

实时显示网络接口带宽使用情况。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install iftop

# CentOS/RHEL
sudo yum install iftop
```

**语法：**
```bash
iftop [选项]
```

**常用选项：**
- `-i interface`：指定网络接口
- `-n`：不进行DNS解析
- `-N`：不进行端口解析
- `-P`：显示端口
- `-b`：不显示条形图
- `-B`：以字节为单位显示
- `-f filter`：使用过滤器

**示例：**
```bash
$ sudo iftop -i eth0 -n
```

**输出解释：**
```
                    12.5Kb  25.0Kb  37.5Kb  50.0Kb   62.5Kb
┌────────────────────┴───────┴───────┴───────┴────────┴
192.168.1.100                => 192.168.1.200        1.25Kb  2.50Kb  1.88Kb
                             <=                      2.50Kb  5.00Kb  3.75Kb
192.168.1.100                => 8.8.8.8              0.50Kb  1.00Kb  0.75Kb
                             <=                      1.00Kb  2.00Kb  1.50Kb
────────────────────────────────────────────────────────────────────────
TX:             cum:     15.0KB   peak rate:    12.5Kb
RX:                      30.0KB                 25.0Kb
TOTAL:                   45.0KB                 37.5Kb

Peak  Total
```

- `=>`：发送流量
- `<=`：接收流量
- 右侧三列：2秒、10秒、40秒的平均速率
- `TX`：发送统计
- `RX`：接收统计
- `TOTAL`：总计统计

### 5.4 nethogs

按进程显示网络带宽使用情况。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install nethogs

# CentOS/RHEL
sudo yum install nethogs
```

**语法：**
```bash
nethogs [选项] [设备]
```

**常用选项：**
- `-d`：刷新间隔（秒）
- `-v`：详细模式
- `-c`：更新次数
- `-t`：跟踪模式
- `-p`：混杂模式

**示例：**
```bash
$ sudo nethogs eth0
```

**输出解释：**
```
NetHogs version 0.8.5

    PID USER     PROGRAM                      DEV        SENT      RECEIVED       
   1234 user1    /usr/bin/firefox            eth0       12.345     23.456 KB/sec
   5678 user2    /usr/bin/ssh                eth0        1.234      2.345 KB/sec
   9012 root     /usr/sbin/apache2           eth0        5.678      8.901 KB/sec
      ? root     unknown TCP                            0.000      0.000 KB/sec

  TOTAL                                                 19.257     34.702 KB/sec
```

### 5.5 nload

实时显示网络接口的带宽使用情况。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install nload

# CentOS/RHEL
sudo yum install nload
```

**语法：**
```bash
nload [选项] [设备]
```

**常用选项：**
- `-t interval`：刷新间隔（毫秒）
- `-u unit`：单位（h=自动，b=Bit/s，k=kBit/s，m=MBit/s，g=GBit/s）
- `-U unit`：单位（H=自动，B=Byte/s，K=kByte/s，M=MByte/s，G=GByte/s）
- `-a period`：平均周期（秒）

**示例：**
```bash
$ nload eth0
```

**输出解释：**
```
Device eth0 [192.168.1.100] (1/2):
================================================================================
Incoming:
                     Curr: 1.25 MBit/s
                     Avg:  0.85 MBit/s
                     Min:  0.00 Bit/s
                     Max:  2.50 MBit/s
                     Ttl: 125.50 MByte

Outgoing:
                     Curr: 0.75 MBit/s
                     Avg:  0.55 MBit/s
                     Min:  0.00 Bit/s
                     Max:  1.50 MBit/s
                     Ttl:  75.25 MByte
```

### 5.6 tcpdump

网络数据包捕获和分析工具。

**语法：**
```bash
tcpdump [选项] [过滤表达式]
```

**常用选项：**
- `-i interface`：指定网络接口
- `-c count`：捕获指定数量的包
- `-w file`：将数据包写入文件
- `-r file`：从文件读取数据包
- `-n`：不进行DNS解析
- `-v, -vv, -vvv`：详细输出
- `-X`：以十六进制和ASCII显示包内容
- `-s snaplen`：设置捕获长度

**示例：**
```bash
# 捕获指定接口的所有包
$ sudo tcpdump -i eth0

# 捕获HTTP流量
$ sudo tcpdump -i eth0 port 80

# 捕获特定主机的流量
$ sudo tcpdump -i eth0 host 192.168.1.100

# 保存到文件
$ sudo tcpdump -i eth0 -w capture.pcap
```

**输出解释：**
```
14:30:15.123456 IP 192.168.1.100.54321 > 192.168.1.200.80: Flags [S], seq 123456789, win 65535, length 0
14:30:15.124567 IP 192.168.1.200.80 > 192.168.1.100.54321: Flags [S.], seq 987654321, ack 123456790, win 65535, length 0
```

- 时间戳：数据包捕获时间
- `IP`：协议类型
- `源地址.端口 > 目标地址.端口`：连接信息
- `Flags`：TCP标志位
- `seq`：序列号
- `ack`：确认号
- `win`：窗口大小
- `length`：数据长度

## 6. 进程监控

### 6.1 ps

显示当前运行的进程信息。

**语法：**
```bash
ps [选项]
```

**常用选项：**
- `aux`：显示所有进程的详细信息
- `ef`：显示所有进程的完整信息
- `-p PID`：显示指定进程
- `-u USER`：显示指定用户的进程
- `-C COMMAND`：显示指定命令的进程
- `--sort=FIELD`：按指定字段排序

**示例：**
```bash
# 显示所有进程
$ ps aux

# 按CPU使用率排序
$ ps aux --sort=-%cpu

# 按内存使用率排序
$ ps aux --sort=-%mem

# 显示进程树
$ ps auxf
```

**输出解释：**
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  19356  1234 ?        Ss   10:00   0:01 /sbin/init
user1     1234  2.5  5.2 123456 12345 pts/0    S+   10:30   0:15 /usr/bin/process
```

- `USER`：进程所有者
- `PID`：进程ID
- `%CPU`：CPU使用百分比
- `%MEM`：内存使用百分比
- `VSZ`：虚拟内存大小（KB）
- `RSS`：物理内存大小（KB）
- `TTY`：终端类型
- `STAT`：进程状态
- `START`：启动时间
- `TIME`：累计CPU时间
- `COMMAND`：命令行

### 6.2 pstree

以树状格式显示进程关系。

**语法：**
```bash
pstree [选项] [PID|USER]
```

**常用选项：**
- `-p`：显示进程ID
- `-u`：显示用户名变化
- `-a`：显示命令行参数
- `-c`：不合并相同的分支
- `-h`：高亮当前进程
- `-n`：按PID排序

**示例：**
```bash
$ pstree -p
```

**输出解释：**
```
systemd(1)─┬─NetworkManager(1234)
           ├─sshd(5678)───sshd(9012)───bash(3456)───pstree(7890)
           ├─apache2(2468)─┬─apache2(1357)
           │               ├─apache2(2468)
           │               └─apache2(3579)
           └─mysqld(4680)
```

### 6.3 htop

交互式进程查看器，top的增强版。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install htop

# CentOS/RHEL
sudo yum install htop
```

**语法：**
```bash
htop [选项]
```

**常用选项：**
- `-d DELAY`：设置刷新间隔
- `-u USER`：只显示指定用户的进程
- `-p PID`：只显示指定进程
- `-s COLUMN`：按指定列排序
- `-t`：显示进程树

**交互式快捷键：**
- `F1`：帮助
- `F2`：设置
- `F3`：搜索
- `F4`：过滤
- `F5`：树视图
- `F6`：排序
- `F9`：杀死进程
- `F10`：退出
- `Space`：标记进程
- `u`：显示指定用户进程
- `t`：切换树视图
- `H`：显示/隐藏线程
- `K`：显示/隐藏内核线程

## 7. 日志监控

### 7.1 tail

显示文件末尾内容，常用于实时监控日志。

**语法：**
```bash
tail [选项] [文件]
```

**常用选项：**
- `-f, --follow`：实时跟踪文件变化
- `-F`：跟踪文件名（文件被重命名或删除后继续跟踪）
- `-n NUM`：显示最后NUM行
- `-c NUM`：显示最后NUM字节
- `--pid=PID`：当指定进程结束时停止跟踪
- `-s SEC`：睡眠间隔

**示例：**
```bash
# 实时监控日志文件
$ tail -f /var/log/syslog

# 显示最后100行
$ tail -n 100 /var/log/messages

# 同时监控多个文件
$ tail -f /var/log/syslog /var/log/auth.log
```

### 7.2 journalctl

systemd的日志查看工具。

**语法：**
```bash
journalctl [选项]
```

**常用选项：**
- `-f, --follow`：实时跟踪日志
- `-u UNIT`：显示指定服务的日志
- `-p PRIORITY`：按优先级过滤
- `--since TIME`：显示指定时间之后的日志
- `--until TIME`：显示指定时间之前的日志
- `-n NUM`：显示最后NUM行
- `-r`：反向显示（最新的在前）
- `--no-pager`：不使用分页器

**示例：**
```bash
# 显示所有日志
$ journalctl

# 实时跟踪日志
$ journalctl -f

# 显示指定服务的日志
$ journalctl -u sshd

# 显示今天的日志
$ journalctl --since today

# 显示最近1小时的日志
$ journalctl --since "1 hour ago"

# 显示错误级别的日志
$ journalctl -p err
```

### 7.3 dmesg

显示内核环形缓冲区的消息。

**语法：**
```bash
dmesg [选项]
```

**常用选项：**
- `-T, --ctime`：显示人类可读的时间戳
- `-w, --follow`：实时跟踪新消息
- `-l, --level LIST`：按级别过滤
- `-f, --facility LIST`：按设施过滤
- `-c, --read-clear`：读取后清除缓冲区
- `-C, --clear`：清除缓冲区
- `-n, --console-level LEVEL`：设置控制台日志级别

**示例：**
```bash
# 显示所有内核消息
$ dmesg

# 显示带时间戳的消息
$ dmesg -T

# 实时跟踪新消息
$ dmesg -w

# 只显示错误消息
$ dmesg -l err
```

## 8. 性能分析工具

### 8.1 strace

跟踪系统调用和信号。

**语法：**
```bash
strace [选项] [命令]
strace [选项] -p PID
```

**常用选项：**
- `-p PID`：跟踪指定进程
- `-f`：跟踪子进程
- `-e EXPR`：指定要跟踪的系统调用
- `-o FILE`：输出到文件
- `-c`：统计系统调用
- `-t`：显示时间戳
- `-T`：显示系统调用耗时
- `-s SIZE`：设置字符串显示长度

**示例：**
```bash
# 跟踪命令的系统调用
$ strace ls

# 跟踪指定进程
$ strace -p 1234

# 只跟踪文件操作
$ strace -e trace=file ls

# 统计系统调用
$ strace -c ls
```

### 8.2 ltrace

跟踪库函数调用。

**语法：**
```bash
ltrace [选项] [命令]
ltrace [选项] -p PID
```

**常用选项：**
- `-p PID`：跟踪指定进程
- `-f`：跟踪子进程
- `-e EXPR`：指定要跟踪的函数
- `-o FILE`：输出到文件
- `-c`：统计函数调用
- `-t`：显示时间戳
- `-T`：显示函数调用耗时
- `-s SIZE`：设置字符串显示长度

**示例：**
```bash
# 跟踪命令的库函数调用
$ ltrace ls

# 跟踪指定进程
$ ltrace -p 1234

# 只跟踪特定函数
$ ltrace -e malloc,free ls
```

### 8.3 perf

Linux性能分析工具。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install linux-tools-common linux-tools-generic

# CentOS/RHEL
sudo yum install perf
```

**常用子命令：**
- `perf top`：实时显示性能热点
- `perf record`：记录性能数据
- `perf report`：分析性能数据
- `perf stat`：显示性能统计
- `perf list`：列出可用事件

**示例：**
```bash
# 实时显示系统性能热点
$ sudo perf top

# 记录程序性能数据
$ sudo perf record ./my_program

# 分析性能数据
$ sudo perf report

# 显示程序性能统计
$ sudo perf stat ./my_program
```

## 9. 系统服务监控

### 9.1 systemctl

systemd服务管理工具。

**语法：**
```bash
systemctl [选项] [命令] [服务名]
```

**常用命令：**
- `status`：显示服务状态
- `start`：启动服务
- `stop`：停止服务
- `restart`：重启服务
- `reload`：重新加载配置
- `enable`：开机自启
- `disable`：禁用自启
- `is-active`：检查是否运行
- `is-enabled`：检查是否自启
- `list-units`：列出所有单元

**示例：**
```bash
# 查看服务状态
$ systemctl status sshd

# 启动服务
$ sudo systemctl start apache2

# 设置开机自启
$ sudo systemctl enable nginx

# 列出所有运行的服务
$ systemctl list-units --type=service --state=running

# 列出失败的服务
$ systemctl list-units --failed
```

### 9.2 service

传统的服务管理工具（SysV init）。

**语法：**
```bash
service [服务名] [命令]
```

**常用命令：**
- `start`：启动服务
- `stop`：停止服务
- `restart`：重启服务
- `reload`：重新加载配置
- `status`：显示服务状态

**示例：**
```bash
# 查看服务状态
$ service sshd status

# 重启服务
$ sudo service apache2 restart

# 列出所有服务
$ service --status-all
```

## 10. 综合监控工具

### 10.1 glances

跨平台的系统监控工具。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install glances

# CentOS/RHEL
sudo yum install glances

# 使用pip安装
pip install glances
```

**语法：**
```bash
glances [选项]
```

**常用选项：**
- `-t SEC`：刷新间隔
- `-s`：服务器模式
- `-c HOST`：客户端模式
- `-p PORT`：指定端口
- `-w`：Web服务器模式
- `--disable-plugin PLUGIN`：禁用插件

**示例：**
```bash
# 启动glances
$ glances

# Web模式（浏览器访问）
$ glances -w

# 服务器模式
$ glances -s

# 客户端连接
$ glances -c 192.168.1.100
```

### 10.2 nmon

AIX和Linux性能监控工具。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install nmon

# CentOS/RHEL
sudo yum install nmon
```

**使用方法：**
```bash
$ nmon
```

**交互式快捷键：**
- `c`：CPU统计
- `m`：内存统计
- `d`：磁盘统计
- `n`：网络统计
- `t`：进程统计
- `r`：资源统计
- `k`：内核统计
- `h`：帮助
- `q`：退出

### 10.3 atop

高级系统和进程监控工具。

**安装：**
```bash
# Ubuntu/Debian
sudo apt-get install atop

# CentOS/RHEL
sudo yum install atop
```

**语法：**
```bash
atop [选项] [间隔] [次数]
```

**常用选项：**
- `-a`：显示活跃进程
- `-c`：显示命令行
- `-d`：显示磁盘统计
- `-m`：显示内存统计
- `-n`：显示网络统计
- `-s`：显示调度统计
- `-v`：显示各种统计
- `-y`：显示线程统计

**交互式快捷键：**
- `g`：通用信息
- `m`：内存信息
- `d`：磁盘信息
- `n`：网络信息
- `c`：按CPU排序
- `M`：按内存排序
- `D`：按磁盘排序
- `A`：按活跃度排序

## 11. 监控脚本示例

### 11.1 系统资源监控脚本

```bash
#!/bin/bash
# 系统资源监控脚本

LOG_FILE="/var/log/system_monitor.log"
THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=90

# 获取当前时间
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 检查CPU使用率
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
CPU_USAGE=${CPU_USAGE%.*}

# 检查内存使用率
MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')

# 检查磁盘使用率
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)

# 记录日志
echo "[$TIMESTAMP] CPU: ${CPU_USAGE}%, MEM: ${MEM_USAGE}%, DISK: ${DISK_USAGE}%" >> $LOG_FILE

# 检查阈值并发送告警
if [ $CPU_USAGE -gt $THRESHOLD_CPU ]; then
    echo "[$TIMESTAMP] WARNING: CPU usage is ${CPU_USAGE}%" >> $LOG_FILE
fi

if [ $MEM_USAGE -gt $THRESHOLD_MEM ]; then
    echo "[$TIMESTAMP] WARNING: Memory usage is ${MEM_USAGE}%" >> $LOG_FILE
fi

if [ $DISK_USAGE -gt $THRESHOLD_DISK ]; then
    echo "[$TIMESTAMP] WARNING: Disk usage is ${DISK_USAGE}%" >> $LOG_FILE
fi
```

### 11.2 进程监控脚本

```bash
#!/bin/bash
# 进程监控脚本

PROCESS_NAME="nginx"
LOG_FILE="/var/log/process_monitor.log"

# 检查进程是否运行
if pgrep -x "$PROCESS_NAME" > /dev/null; then
    echo "[$(date)] $PROCESS_NAME is running" >> $LOG_FILE
else
    echo "[$(date)] WARNING: $PROCESS_NAME is not running" >> $LOG_FILE
    # 尝试重启进程
    systemctl start $PROCESS_NAME
    if [ $? -eq 0 ]; then
        echo "[$(date)] $PROCESS_NAME restarted successfully" >> $LOG_FILE
    else
        echo "[$(date)] ERROR: Failed to restart $PROCESS_NAME" >> $LOG_FILE
    fi
fi
```

## 12. 最佳实践

### 12.1 监控策略

1. **分层监控**
   - 基础设施层：CPU、内存、磁盘、网络
   - 应用层：进程、服务、日志
   - 业务层：关键指标、用户体验

2. **告警设置**
   - 设置合理的阈值
   - 避免告警风暴
   - 分级告警机制

3. **数据保留**
   - 短期：详细数据（1-7天）
   - 中期：汇总数据（1-3个月）
   - 长期：趋势数据（1年以上）

### 12.2 性能优化建议

1. **CPU优化**
   - 识别CPU密集型进程
   - 优化算法和代码
   - 合理设置进程优先级
   - 使用多核并行处理

2. **内存优化**
   - 监控内存泄漏
   - 优化缓存策略
   - 调整交换分区
   - 使用内存映射文件

3. **磁盘优化**
   - 使用SSD替代HDD
   - 优化文件系统
   - 定期清理日志
   - 使用RAID提高性能

4. **网络优化**
   - 监控网络带宽
   - 优化网络配置
   - 使用负载均衡
   - 压缩网络传输

### 12.3 故障排查流程

1. **问题识别**
   - 收集症状信息
   - 确定影响范围
   - 评估紧急程度

2. **初步分析**
   - 检查系统资源
   - 查看错误日志
   - 分析监控数据

3. **深入调查**
   - 使用性能分析工具
   - 跟踪系统调用
   - 分析网络流量

4. **问题解决**
   - 实施临时措施
   - 制定永久方案
   - 验证解决效果

5. **总结改进**
   - 记录问题原因
   - 更新监控策略
   - 完善预防措施

---

本文档涵盖了Linux系统运维中最常用的监控命令和工具，通过合理使用这些工具，可以有效监控系统状态，及时发现和解决问题，确保系统稳定运行。建议根据实际需求选择合适的工具，并建立完善的监控体系。
```