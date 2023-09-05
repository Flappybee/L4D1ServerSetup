原地址:
https://forums.alliedmods.net/showthread.php?p=2757211



插件命令:(仅管理员可用)
sm_glowinfo                                => Outputs to the chat the glow info about the entity at your crosshair. (z flag required)
sm_glowreload                              => Reload the glow configs. (z flag required)
sm_glowremove                              => Remove plugin glow from entity at crosshair. (z flag required)
sm_glowremoveall                           => Remove all glows created by the plugin. (z flag required)
sm_glowadd                                 => Add glow to entity at crosshair. (z flag required)
sm_glowall                                 => Add glow to everything possible. (z flag required)
sm_print_cvars_l4d1_glow_item              => Print the plugin related cvars and their respective values to the console. (z flag required)








控制台变量

// 启用/禁用此插件.
// 0 = 禁用, 1 = 启用.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"

l4d1_glow_item_enable "1"




// 当急救箱子被打开后移除急救包的发光.
// 0 = 禁用, 1 = 启用.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"

l4d1_glow_item_health_cabinet "1"




// 切换（启动/停止）发光的间隔（秒）.
// -
// Default: "0.3"
// Minimum: "0.100000"

l4d1_glow_item_interval "0.3"





// 物品数量为 0 时停止发光.
// 0 = 关闭, 1 = 开启.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"

l4d1_glow_item_remove_spawner "1" 