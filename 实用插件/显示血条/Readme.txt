原地址：
https://forums.alliedmods.net/showthread.php?p=2736513

命令列表

!hplaser					打开一个控制血条显隐的菜单
!hidehplaser				关闭血条显示.
!showhplaser				开启血条显示.
!print_cvars_l4d_hp_laser	打印此插件相关变量和变量值(仅管理员可用)


控制台变量
// 0 = 血条左对齐. (表现较差)
// 1 = 血条居中对齐. (表现更好)
// -
// 默认值: "1"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_align_center "1"

// 血条背景的Alpha值.
// 0 = 透明, 255 = 不透明.
// -
// 默认值: "240"
// 最小值: "0.000000"
// 最大值: "255.000000"
l4d_hp_laser_alpha "240"

// 攻击一个特殊感染者之后多久出现血条显示
// 0 = 无延时.
// -
// 默认值: "0.0"
// 最小值: "0.000000"
l4d_hp_laser_attack_delay "0.0"

// 当幸存者为黑白状态时用白色血条显示.
// 0 = 关闭, 1 = 打开.
// -
// 默认值: "1"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_black_and_white "1"

// 客户端想隐藏血条时最大alpha值为
// -1 = 关闭.
// -
// 默认值: "0"
// 最小值: "-1.000000"
// 最大值: "255.000000"
l4d_hp_laser_client_alpha_max "0"

// 允许客户端保存偏好cookies.
// 0 = 关闭, 1 = 开启.
// -
// 默认值: "1"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_cookies "1"

// 启用/禁用此插件.
// 0 = Disable, 1 = Enable.
// -
// 默认值: "1"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_enable "1"

// 两者之间必须至少相距多远才可看见血条
// 0 = 总是可以看见.
// -
// 默认值: "0"
// 最小值: "0.000000"
l4d_hp_laser_fade_distance "0"

// Display a laser beam HP to fill the bar.
// Note: Disable this if you intend to show a lot of laser beams HP. The game limits the number of beams rendered at the same time when limit exceeds it may not draw then all.
// 0 = 关闭, 1 = 开启.
// -
// 默认值: "1"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_fill "1"

// Hp条的alpha值.
// 0 = 不可见, 255 = 完全可见
// -
// 默认值: "40"
// 最小值: "0.000000"
// 最大值: "255.000000"
l4d_hp_laser_fill_alpha "40"

// 血条颜色随血量变化模式. 
// 0 = 默认. (颜色: 绿色 40HP+, 黄色 39HP~25HP, 红色 24HP-), 1 = 梯度模式.
// 注意: 黄色的血量取决于游戏控制台变量的 "survivor_limp_health" 的值.
// -
// 默认值: "0"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_gradient_color "0"

// HP血条的高度值.
// -
// 默认值: "2.0"
// 最小值: "0.000000"
l4d_hp_laser_height "2.0"

// 哪支队伍可以看见血量条.
// 0 = 无, 1 = 幸存者, 2 = 感染者, 4 = 旁观者, 8 = HOLDOUT.
// Add numbers greater than 0 for multiple options.
// Example: "3", enables for 幸存者 and 感染者.
// -
// 默认值: "3"
// 最小值: "0.000000"
// 最大值: "15.000000"
l4d_hp_laser_infected_team "3"

// Width of the 感染者 laser beam HP.
// -
// 默认值: "25.0"
// 最小值: "0.000000"
l4d_hp_laser_infected_width "25.0"

// Model of the laser beam HP.
// -
// 默认值: "vgui/white_additive.vmt"
l4d_hp_laser_model "vgui/white_additive.vmt"

// Which teams should multiply the laser beam HP alpha based on the client render alpha.
// 0 = NONE, 1 = 幸存者, 2 = 感染者, 4 = 旁观者, 8 = HOLDOUT.
// 可以使用加法进行组合.
// 例如: "3", enables for 幸存者 and 感染者.
// -
// 默认值: "2"
// 最小值: "0.000000"
// 最大值: "15.000000"
l4d_hp_laser_multiply_alpha_team "2"

// Render type used to draw the laser beams.
// 0 = Timer (0.1 seconds - less expensive), 1 = OnGameFrame (by frame - more expensive).
// -
// 默认值: "0"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_render_frame "0"

// Which special 感染者 should have a laser beam HP.
// 1 = SMOKER, 2 = BOOMER, 4 = HUNTER, 8 = SPITTER, 16 = JOCKEY, 32 = CHARGER, 64 = TANK.
// Add numbers greater than 0 for multiple options.
// Example: "127", enables laser beam HP for all SI.
// -
// 默认值: "64"
// 最小值: "0.000000"
// 最大值: "127.000000"
l4d_hp_laser_si "64"

// Show a laser beam HP to the 幸存者 only if the special 感染者 is on sight.
// 0 = OFF, 1 = ON.
// -
// 默认值: "1"
// 最小值: "0.000000"
// 最大值: "1.000000"
l4d_hp_laser_sight "1"

// How many frames should skip while using l4d_hp_laser_render_type = "1" (OnGameFrame). Frames may vary depending on your tickrate. Using a higher value than 2 becomes slower than with the timer on 默认值 tick rate (30)
// -
// 默认值: "1"
// 最小值: "0.000000"
l4d_hp_laser_skip_frame "1"

// Which teams spectators can see a laser beam HP.
// 0 = NONE, 1 = 幸存者, 2 = 感染者, 4 = 旁观者, 8 = HOLDOUT.
// Add numbers greater than 0 for multiple options.
// Example: "3", enables for 幸存者 and 感染者.
// -
// 默认值: "3"
// 最小值: "0.000000"
// 最大值: "15.000000"
l4d_hp_laser_spectator_team "3"

// Which teams survivors can see a laser beam HP.
// 0 = NONE, 1 = 幸存者, 2 = 感染者, 4 = 旁观者, 8 = HOLDOUT.
// Add numbers greater than 0 for multiple options.
// Example: "3", enables for 幸存者 and 感染者.
// -
// 默认值: "3"
// 最小值: "0.000000"
// 最大值: "15.000000"
l4d_hp_laser_survivor_team "3"

// Width of the 幸存者 laser beam HP.
// -
// 默认值: "15.0"
// 最小值: "0.000000"
l4d_hp_laser_survivor_width "15.0"

// Which teams should have a laser beam HP.
// 0 = NONE, 1 = 幸存者, 2 = 感染者, 4 = 旁观者, 8 = HOLDOUT.
// Add numbers greater than 0 for multiple options.
// Example: "3", enables for 幸存者 and 感染者.
// -
// 默认值: "3"
// 最小值: "0.000000"
// 最大值: "15.000000"
l4d_hp_laser_team "3"

// Additional Z axis distance of laser beam HP based on client position.
// -
// 默认值: "85"
// 最小值: "0.000000"
l4d_hp_laser_z_axis "85" 