原地址:
https://forums.alliedmods.net/showthread.php?t=232928

github地址:
https://github.com/psbj/vote-blocker


控制台变量:
vb_version								//此插件版本


0 - 禁用此项功能, 1 - 启用此项功能
vb_enable								//启用插件(默认 1, 启用)
vb_log									//启用插件日志(默认 0, 禁用)
vb_respectimmunity						//尊重豁免权(默认 1, 启用)
vb_adminimmunity						//管理员豁免(默认 1, 启用)
vb_tankimmunity							//坦克扮演者豁免(默认 0, 禁用)



0 - 允许此项投票, x - 只有带有此项或者更高管理标志的玩家可发起投票(设置为z标志时只有root管理权限的玩家方可发起此项投票)
vb_spectatorvote						//作为旁观者发起投票(默认 b 标志权限以上)
vb_kick									//踢人投票(默认 0, 允许此项投票)
vb_returntolobby						//返回大厅投票(默认 b 标志权限以上)
vb_changealltalk						//改变全体语音设置投票(默认 b 标志权限以上)
vb_restartchapter						//重新开始战役投票(默认 0, 允许此项投票)
vb_changemission						//开始新战役投票(默认 0, 允许此项投票)
vb_changechapter						//改变章节投票(默认 0, 允许此项投票)
vb_changedifficulty						//改变游戏难度投票(默认 0, 允许此项投票)

0 - 不限制发起不允许投票的次数, n - 发起超过最大不合法投票次数的玩家将被自动踢出游戏
vb_blockcount							//默认次数: 3次, 发起非法投票次数超过三次时, 玩家将被自动踢出

控制台命令(管理员可用):
!veto	//强制否决此次投票
!pass	//强制通过此次投票