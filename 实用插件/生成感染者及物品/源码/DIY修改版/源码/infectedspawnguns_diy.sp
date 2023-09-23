#include <sourcemod>

// Make the admin menu plugin optional
#undef REQUIRE_PLUGIN
#include <adminmenu>
 
// Keep track of the top menu 
new Handle:hTopMenu = INVALID_HANDLE;

new TopMenuObject:menuSpawnInfected = INVALID_TOPMENUOBJECT;
new TopMenuObject:menuSpawnWeapons = INVALID_TOPMENUOBJECT;
new TopMenuObject:menuSpawnItems = INVALID_TOPMENUOBJECT;
new TopMenuObject:menuForcePanic = INVALID_TOPMENUOBJECT;

new String:TAG[] = "\x04[提示] \x03";

public Plugin:myinfo = 
{
	name = "Left 4 Dead Infected Spawner",
	author = "Fexii",
	description = "Provides commands for spawning infected",
	version = "1.0",
	url = "http://www.sourcemod.net/"
};

public OnPluginStart()
{
	RegAdminCmd("sm_spawn_infected",
		Command_Spawn_Infected,
		ADMFLAG_KICK,
		"Spawn an infected where you are aiming.");
	
	RegAdminCmd("sm_force_panic_event",
		Command_Force_Panic,
		ADMFLAG_KICK,
		"Forces a director panic event.");
	
	RegAdminCmd("sm_spawn_weapons",
		Command_Spawn_Weapons,
		ADMFLAG_KICK,
		"Spawn weapons.");

	RegAdminCmd("sm_spawn_items",
		Command_Spawn_Items,
		ADMFLAG_KICK,
		"Spawn items.");

	// See if the menu plugin is already ready
	new Handle:topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		// If so, manually fire the callback
		OnAdminMenuReady(topmenu);
	}
}

public AdminMenuInfectedHandler(Handle:topmenu, 
			TopMenuAction:action,
			TopMenuObject:object_id,
			param,
			String:buffer[],
			maxlength)
{
	if (action == TopMenuAction_DisplayTitle)
	{
		Format(buffer, maxlength, "生成感染者:", param);
	}
	else if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "生成感染者", param);
	}
}

public AdminMenuItemsHandler(Handle:topmenu, 
			TopMenuAction:action,
			TopMenuObject:object_id,
			param,
			String:buffer[],
			maxlength)
{
	if (action == TopMenuAction_DisplayTitle)
	{
		Format(buffer, maxlength, "生成物品:", param);
	}
	else if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "生成物品", param);
	}
}



public InfectedMenuHandler(Handle:topmenu, 
			TopMenuAction:action,
			TopMenuObject:object_id,
			param,
			String:buffer[],
			maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		if (object_id == menuSpawnInfected)
			Format(buffer, maxlength, "生成感染者", param);
		else if (object_id == menuForcePanic)
			Format(buffer, maxlength, "生成尸潮", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (object_id == menuSpawnInfected)
			DisplayInfectedMenu(param);
		else if (object_id == menuForcePanic)
			ForcePanicEvent(param);
	}
}

public WeaponAndItemMenuHandler(Handle:topmenu, 
			TopMenuAction:action,
			TopMenuObject:object_id,
			param,
			String:buffer[],
			maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		if (object_id == menuSpawnWeapons)
			Format(buffer, maxlength, "生成武器", param);
		else if (object_id == menuSpawnItems)
			Format(buffer, maxlength, "生成物品", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (object_id == menuSpawnWeapons)
			DisplayWeaponsMenu(param);
		else if (object_id == menuSpawnItems)
			DisplayFiredItemMenu(param);
	}
}

public Action:Command_Spawn_Infected(client, args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "\x04[提示] \x03%t", "命令仅在游戏中生效");
		return Plugin_Handled;
	}
	
	DisplayInfectedMenu(client);
	
	return Plugin_Handled;
}

public Action:Command_Spawn_Weapons(client, args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "\x04[提示] \x03%t", "命令仅在游戏中生效");
		return Plugin_Handled;
	}
	
	DisplayWeaponsMenu(client);
	
	return Plugin_Handled;
}

public Action:Command_Spawn_Items(client, args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "\x04[提示] \x03%t", "命令仅在游戏中生效");
		return Plugin_Handled;
	}
	
	DisplayFiredItemMenu(client);
	
	return Plugin_Handled;
}

public Action:Command_Force_Panic(client, args)
{
	ForcePanicEvent(client);
	return Plugin_Handled;
}

DisplayInfectedMenu(client)
{
	if (!IsClientInGame(client) || IsClientInKickQueue(client))
		return;
	
	new Handle:menu1 = CreateMenu(InfectedSpawnHandler);
	SetMenuTitle(menu1, "生成感染者:");
	AddMenuItem(menu1, "common", "普通感染者");
	AddMenuItem(menu1, "hunter", "猎人");
	AddMenuItem(menu1, "boomer", "呕吐者");
	AddMenuItem(menu1, "smoker", "吸烟者");
	AddMenuItem(menu1, "witch", "女巫");
	AddMenuItem(menu1, "tank", "坦克");
	SetMenuExitBackButton(menu1, true);
	DisplayMenu(menu1, client, MENU_TIME_FOREVER);
}

DisplayWeaponsMenu(client)
{
	if (!IsClientInGame(client) || IsClientInKickQueue(client))
		return;
	
	new Handle:menu2 = CreateMenu(WeaponsSpawnHandler);
	SetMenuTitle(menu2, "生成武器:");
	AddMenuItem(menu2, "pistol", "小手枪");
	AddMenuItem(menu2, "smg", "乌兹冲锋枪");
	AddMenuItem(menu2, "pumpshotgun", "单发霰弹枪");
	AddMenuItem(menu2, "rifle", "M16步枪");
	AddMenuItem(menu2, "hunting_rifle", "狙击猎枪");
	AddMenuItem(menu2, "autoshotgun", "连发霰弹枪");
	AddMenuItem(menu2, "ammo", "弹药");
	SetMenuExitBackButton(menu2, true);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);

}DisplayFiredItemMenu(client)
{
	if (!IsClientInGame(client) || IsClientInKickQueue(client))
		return;
	
	new Handle:menu3 = CreateMenu(FireitemSpawnHandler);
	SetMenuTitle(menu3, "生成物品:");
	AddMenuItem(menu3, "first_aid_kit", "急救包");
	AddMenuItem(menu3, "pain_pills", "止疼药");
	AddMenuItem(menu3, "molotov", "火瓶");
	AddMenuItem(menu3, "pipe_bomb", "手雷");
	AddMenuItem(menu3, "gascan", "汽油桶");
	AddMenuItem(menu3, "propanetank", "煤气罐");
	AddMenuItem(menu3, "oxygentank", "氧气瓶");
	SetMenuExitBackButton(menu3, true);
	DisplayMenu(menu3, client, MENU_TIME_FOREVER);
}

public InfectedSpawnHandler(Handle:menu1, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu1, param2, info, sizeof(info));
		SpawnInfected(param1, info);
		DisplayInfectedMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu1);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(hTopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
}

public WeaponsSpawnHandler(Handle:menu2, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu2, param2, info, sizeof(info));
		SpawnWeapons(param1, info);
		DisplayWeaponsMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(hTopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
}

public FireitemSpawnHandler(Handle:menu3, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu3, param2, info, sizeof(info));
		SpawnWeapons(param1, info);
		DisplayFiredItemMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu3);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(hTopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
}

SpawnInfected(client, String:name[])
{
	new String:command[] = "z_spawn";
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "z_spawn %s", name);
	SetCommandFlags(command, flags);
	
	ShowActivity2(client, TAG, "生成了\x04%s", name);
}

SpawnWeapons(client, String:name[])
{
	new String:command[] = "give";
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "give %s", name);
	SetCommandFlags(command, flags);
	
	ShowActivity2(client, TAG, "生成了\x04%s", name);
}

ForcePanicEvent(client)
{
	new String:command[] = "director_force_panic_event";
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, command);
	SetCommandFlags(command, flags);
	
	ShowActivity2(client, TAG, "生成了一波尸潮");
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
	{
		hTopMenu = INVALID_HANDLE;
	}
}
 
public OnAdminMenuReady(Handle:topmenu)
{
	// Block us from being called twice
	if (topmenu == hTopMenu)
	{
		return;
	}
	
	hTopMenu = topmenu;
	
	new TopMenuObject:objInfectedMenu = FindTopMenuCategory(hTopMenu, "Left4DeadInfected");
	if (objInfectedMenu == INVALID_TOPMENUOBJECT)
		objInfectedMenu = AddToTopMenu(
			hTopMenu,
			"Left4DeadInfected",
			TopMenuObject_Category,
			AdminMenuInfectedHandler,
			INVALID_TOPMENUOBJECT
		);
	
	new TopMenuObject:objWeaponAndItemMenu = FindTopMenuCategory(hTopMenu, "Left4DeadWeaponAndItems");
	if (objWeaponAndItemMenu == INVALID_TOPMENUOBJECT)
		objWeaponAndItemMenu = AddToTopMenu(
			hTopMenu,
			"Left4DeadWeaponAndItems",
			TopMenuObject_Category,
			AdminMenuItemsHandler,
			INVALID_TOPMENUOBJECT
		);
	


	menuSpawnInfected = AddToTopMenu(
		hTopMenu,
		"L4D_Infected_Spawn_Item",
		TopMenuObject_Item,
		InfectedMenuHandler,
		objInfectedMenu,
		"sm_spawn_infected",
		ADMFLAG_KICK
	);
	
	menuForcePanic = AddToTopMenu(
		hTopMenu,
		"L4D_Force_Panic_Item",
		TopMenuObject_Item,
		InfectedMenuHandler,
		objInfectedMenu,
		"sm_force_panic_event",
		ADMFLAG_KICK
	);

	menuSpawnWeapons = AddToTopMenu(
		hTopMenu,
		"L4D_Weapons_Spawn_Item",
		TopMenuObject_Item,
		WeaponAndItemMenuHandler,
		objWeaponAndItemMenu,
		"sm_spawn_weapons",
		ADMFLAG_KICK
	);

	menuSpawnItems = AddToTopMenu(
		hTopMenu,
		"L4D_Items_Spawn_Item",
		TopMenuObject_Item,
		WeaponAndItemMenuHandler,
		objWeaponAndItemMenu,
		"sm_spawn_items",
		ADMFLAG_KICK
	);
}