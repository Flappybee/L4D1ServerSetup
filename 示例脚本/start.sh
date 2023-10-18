/home/steamuser/Steam/l4d1server/srcds_run -game left4dead -insecure +hostport 27015 -condebug +map l4d_hospital01_apartment +exec server.cfg -nomaster

#末尾的-nomaster会让服务器只接受使用ip连接，不能通过大厅进入，一般调试的时候加上，希望和别人一起玩的时候就需要去掉