# arukas-port-tool
获取 Arukas Docker 的容器的映射端口，并把本机的某端口转发到此端口。
   因为端口转发功能使用的是 firewall-cmd 应该仅适用于CentOS 7.
   不知道 CentOS 6 能不能用 firewalld ，我对 iptables 不太熟悉，如果有对 iptables 熟悉的，可以把脚本最后的几条 firewall-cmd 命令改成 iptables 的命令，这样就能适配 CentOS 6 了 。
依赖命令：curl  jq  host firewall-cmd 


用法：./update_arukas_port Token:Secret  Arukas_Endpoint Arukas_Port Local_Port

Token和Secret通过 https://app.arukas.io/settings/api-keys 获取。注意：使用时Token和Secret使用冒号连起来。
Arukas_Endpoint 是目标容器的 Endpoint ，可以通过此 Endpoint 来标识目标容器。
Arukas_Port 是目标容器的自定义端口，此端口是创建 docker 时自己填的那个，比如22和8388和80什么的。
Local_Port 是开在本地的端口。
没写死循环，如果要实现“每隔多少小时自动更新端口信息”类似的功能，请自行写循环或者用定时任务什么的来调用此脚本。
