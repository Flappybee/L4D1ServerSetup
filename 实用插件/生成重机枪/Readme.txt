原地址：
https://forums.alliedmods.net/showthread.php?p=1622557

指令
!mg        // 在鼠标十字处生成一个非永久机枪。 用法: 使用!mg 0生成二代重机枪，使用!mg 1生成1代重机枪
!mgsave    // 在鼠标十字处生成一个永久机枪，并保存在cfg文件中。 用法: 使用!mgsave 0生成二代重机枪，使用!mgsave 1生成1代重机枪
!mglist    // 显示使用本插件生成的重机枪的列表以及它们的位置坐标
!mgdel     // 删除离你最近的重机枪并将其从config文件中删除(如果存在)
!mgclear   // 删除当前地图中的所有重机枪
!mgwipe    // 删除当前地图中的所有重机枪并将其从config文件中删除


控制台变量
// 0=关闭插件, 1=开启插件.
l4d_mini_gun_allow "1"

// Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
l4d_mini_gun_modes ""

// Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
l4d_mini_gun_modes_off ""

// Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
l4d_mini_gun_modes_tog "0"

// -1=All, 0=Off, other value randomly spawns that many from the config.
l4d_mini_gun_random "2"

// 插件版本.
l4d_mini_gun_version 


！！！！！本插件中的config文件是自动生成，名为l4d_mini_gun.cfg，保存于目录\cfg\sourcemod\中