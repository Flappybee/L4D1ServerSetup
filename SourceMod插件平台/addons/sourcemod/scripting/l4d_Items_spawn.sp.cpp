/*
*	Items Spawn
*	Copyright (C) 2023 辣椒冰激凌
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



#define PLUGIN_VERSION 		"1.0"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D1] Items Spawn
*	Author	:	辣椒冰激凌
*	Desc	:	Spawn items at the cursor.
*	Link	:	
*	Plugins	:	

========================================================================================
	Change Log:

1.0 (27-Sep-2023)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define CVAR_FLAGS			FCVAR_NOTIFY
#define CHAT_TAG			"\x04[\x05Items Spawn\x04] \x01"
#define CONFIG_SPAWNS		"data/l4d_spawn_weapon.cfg"
#define MAX_SPAWNS			32
#define	MAX_WEAPONS			11


ConVar g_hCvarAllow, g_hCvarCount, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog;
int g_iCvarCount, g_iPlayerSpawn, g_iRoundStart, g_iSave[MAXPLAYERS+1], g_iSpawnCount, g_iSpawns[MAX_SPAWNS][3];
bool g_bCvarAllow, g_bMapStarted;
Menu  g_hMenuList;

ConVar g_hAmmoHunting, g_hAmmoRifle, g_hAmmoShotgun, g_hAmmoSmg;
int g_iAmmoAutoShot, g_iAmmoHunting, g_iAmmoRifle, g_iAmmoShotgun, g_iAmmoSmg;

static char g_sWeaponNames[MAX_WEAPONS][] =
{
	"M16自动步枪",
	"连发霰弹枪",
	"狙击猎枪",
	"乌兹冲锋枪",
	"单发霰弹枪",
	"小手枪",
	"火瓶",
	"手雷",
	"医疗包",
	"止疼药",
	"安全门"
};
static char g_sWeapons[MAX_WEAPONS][] =
{
	"weapon_rifle",
	"weapon_autoshotgun",
	"weapon_hunting_rifle",
	"weapon_smg",
	"weapon_pumpshotgun",
	"weapon_pistol",
	"weapon_molotov",
	"weapon_pipe_bomb",
	"weapon_first_aid_kit",
	"weapon_pain_pills",
	"checkpoint_door_-01"
};
static char g_sWeaponModels[MAX_WEAPONS][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pistol_1911.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_medkit.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",
	"models/props_doors/checkpoint_door_-01.mdl"
};

// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D1] Items Spawn",
	author = "辣椒冰激凌",
	description = "Spawns items at the cursor.",
	version = PLUGIN_VERSION,
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead )
	{
		strcopy(error, err_max, "插件仅支持求生之路1.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	// Cvars
	g_hCvarAllow =		CreateConVar(	"l4d_items_spawn_allow",			"1",			"0=禁用插件, 1=启用插件.", CVAR_FLAGS );
	g_hCvarModes =		CreateConVar(	"l4d_items_spawn_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =	CreateConVar(	"l4d_items_spawn_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =	CreateConVar(	"l4d_items_spawn_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarCount =		CreateConVar(	"l4d_items_spawn_count",			"0",			"0=Infinite. How many items/weapons to give from 1 spawner.", CVAR_FLAGS );
	
	CreateConVar(						"l4d_items_spawn_version",			PLUGIN_VERSION, "插件版本.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,				"l4d_items_spawn");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarCount.AddChangeHook(ConVarChanged_Cvars);
	

	g_hAmmoRifle =			FindConVar("ammo_assaultrifle_max");
	g_hAmmoSmg =			FindConVar("ammo_smg_max");
	g_hAmmoHunting =		FindConVar("ammo_huntingrifle_max");

	g_hAmmoRifle.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoSmg.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoHunting.AddChangeHook(ConVarChanged_Cvars);


	g_hAmmoShotgun =	FindConVar("ammo_buckshot_max");
	g_hAmmoShotgun.AddChangeHook(ConVarChanged_Cvars);



	// Commands
	RegAdminCmd("sm_items_spawn",			CmdSpawnerTemp,		ADMFLAG_ROOT, 	"Opens a menu of weapons/items to spawn. Spawns a temporary weapon at your crosshair.");



	// Menu
	g_hMenuList = new Menu(ListMenuHandler);
	int max = MAX_WEAPONS;
	for( int i = 0; i < max; i++ )
	{
		g_hMenuList.AddItem("", g_sWeaponNames[i]);
	}
	g_hMenuList.SetTitle("创建武器");
	g_hMenuList.ExitBackButton = true;

}

public void OnPluginEnd()
{
	ResetPlugin();
}

public void OnMapStart()
{
	g_bMapStarted = true;
	int max = MAX_WEAPONS;
	for( int i = 0; i < max; i++ )
	{
		PrecacheModel(g_sWeaponModels[i], true);
	}
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetPlugin(false);
}



// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}


void GetCvars()
{
	g_iCvarCount		= g_hCvarCount.IntValue;
	g_iAmmoRifle		= g_hAmmoRifle.IntValue;
	g_iAmmoShotgun		= g_hAmmoShotgun.IntValue;
	g_iAmmoSmg			= g_hAmmoSmg.IntValue;
	g_iAmmoHunting		= g_hAmmoHunting.IntValue;

}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
		HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);
		HookEvent("round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
		HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		ResetPlugin();
		UnhookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);
		UnhookEvent("round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
		UnhookEvent("round_end",		Event_RoundEnd,		EventHookMode_PostNoCopy);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_bMapStarted == false )
			return false;

		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}


void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin(false);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(1.0, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(1.0, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

Action TimerStart(Handle timer)
{
	ResetPlugin();
	return Plugin_Continue;
}


// ====================================================================================================
//					CREATE SPAWN
// ====================================================================================================
void CreateSpawn(const float vOrigin[3], const float vAngles[3], int index = 0, int model = 0, int autospawn = false)
{
	if( g_iSpawnCount >= MAX_SPAWNS )
		return;

	int iSpawnIndex = -1;
	for( int i = 0; i < MAX_SPAWNS; i++ )
	{
		if( !IsValidEntRef(g_iSpawns[i][0]) )
		{
			iSpawnIndex = i;
			break;
		}
	}

	if( iSpawnIndex == -1 )
		return;


	if( autospawn)
	{
		model = GetRandomInt(0, MAX_WEAPONS-1);
	}

	char classname[64];
	strcopy(classname, sizeof(classname), g_sWeapons[model]);

	int iCount = g_iCvarCount;
	if( iCount != 1 )
	{
		StrCat(classname, sizeof(classname), "_spawn");
	}

	int entity_weapon = -1;
	entity_weapon = CreateEntityByName(classname);
	if( entity_weapon == -1 )
		ThrowError("Failed to create entity '%s'", classname);

	DispatchKeyValue(entity_weapon, "solid", "6");
	DispatchKeyValue(entity_weapon, "model", g_sWeaponModels[model]);
	DispatchKeyValue(entity_weapon, "rendermode", "3");
	DispatchKeyValue(entity_weapon, "disableshadows", "1");

	if( iCount <= 0 ) // Infinite
	{
		DispatchKeyValue(entity_weapon, "spawnflags", "8");
		DispatchKeyValue(entity_weapon, "count", "9999");
	}
	else if( iCount != 1 )
	{
		char sCount[5];
		IntToString(iCount, sCount, sizeof(sCount));
		DispatchKeyValue(entity_weapon, "count", sCount);
	}

	float vAng[3], vPos[3];
	vPos = vOrigin;
	vAng = vAngles;
	if( model == (8) ) // First aid
	{
		vAng[0] += 90.0;
		vPos[2] += 1.0;
	}

	TeleportEntity(entity_weapon, vPos, vAng, NULL_VECTOR);
	DispatchSpawn(entity_weapon);

	if( iCount == 1 )
	{
		int ammo;

		switch (model)
		{
			case 0:						ammo = g_iAmmoRifle;
			case 1:						ammo = g_iAmmoAutoShot;
			case 2:						ammo = g_iAmmoHunting;
			case 3:						ammo = g_iAmmoSmg;
			case 4:						ammo = g_iAmmoShotgun;
		}


		if( model == 1 ) ammo = g_iAmmoShotgun;

		SetEntProp(entity_weapon, Prop_Send, "m_iExtraPrimaryAmmo", ammo, 4);
	}
	SetEntityMoveType(entity_weapon, MOVETYPE_NONE);


	g_iSpawns[iSpawnIndex][0] = EntIndexToEntRef(entity_weapon);
	g_iSpawns[iSpawnIndex][1] = index;

	g_iSpawnCount++;
}



// ====================================================================================================
//					COMMANDS
// ====================================================================================================
//					sm_items_spawn
// ====================================================================================================
int ListMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Select )
	{
		CmdSpawnerTempMenu(client, index);
		g_hMenuList.DisplayAt(client, g_hMenuList.Selection, MENU_TIME_FOREVER);
	}

	return 0;
}

Action CmdSpawnerTemp(int client, int args)
{
	if( !client )
	{
		ReplyToCommand(client, "[提示] 此命令仅可在 %s", IsDedicatedServer() ? "专用服务器中的游戏中使用." : "监听服务器的聊天框中使用.");
		return Plugin_Handled;
	}
	else if( g_iSpawnCount >= MAX_SPAWNS )
	{
		PrintToChat(client, "%s错误: 不可再次创建该物体. 已创建: (\x05%d/%d\x01).", CHAT_TAG, g_iSpawnCount, MAX_SPAWNS);
		return Plugin_Handled;
	}

	g_iSave[client] = 0;
	g_hMenuList.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

void CmdSpawnerTempMenu(int client, int weapon)
{
	if( !client )
	{
		ReplyToCommand(client, "[提示] 此命令仅可在 %s", IsDedicatedServer() ? "专用服务器中的游戏中使用." : "监听服务器的聊天框中使用.");
		return;
	}
	else if( g_iSpawnCount >= MAX_SPAWNS )
	{
		PrintToChat(client, "%s错误: 不可再次创建该物体. 已创建: (\x05%d/%d\x01).", CHAT_TAG, g_iSpawnCount, MAX_SPAWNS);
		return;
	}
	float vPos[3], vAng[3];
	if (!SetTeleportEndPoint(client, vPos, vAng))
	{
		PrintToChat(client, "%s此处不可放置, 请重试.", CHAT_TAG);
		return;
	}
	CreateSpawn(vPos, vAng, 0, weapon);
	return;
}

// ====================================================================================================
//					STUFF
// ====================================================================================================
bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

void ResetPlugin(bool all = true)
{
	g_iSpawnCount = 0;
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;

	if( all )
		for( int i = 0; i < MAX_SPAWNS; i++ )
			RemoveSpawn(i);
}

void RemoveSpawn(int index)
{
	int entity, client;

	entity = g_iSpawns[index][0];
	g_iSpawns[index][0] = 0;
	g_iSpawns[index][1] = 0;

	if( IsValidEntRef(entity) )
	{
		client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if( client < 0 || client > MaxClients || !IsClientInGame(client) )
		{
			RemoveEntity(entity);
		}
	}
}



// ====================================================================================================
//					POSITION
// ====================================================================================================
float GetGroundHeight(float vPos[3])
{
	float vAng[3];

	Handle trace = TR_TraceRayFilterEx(vPos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_ALL, RayType_Infinite, _TraceFilter);
	if( TR_DidHit(trace) )
		TR_GetEndPosition(vAng, trace);

	delete trace;
	return vAng[2];
}

// Taken from "[L4D2] Weapon/Zombie Spawner"
// By "Zuko & McFlurry"
bool SetTeleportEndPoint(int client, float vPos[3], float vAng[3])
{
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vAng);

	Handle trace = TR_TraceRayFilterEx(vPos, vAng, MASK_SHOT, RayType_Infinite, _TraceFilter);

	if (TR_DidHit(trace))
	{
		float vNorm[3];
		float degrees = vAng[1];
		TR_GetEndPosition(vPos, trace);
		GetGroundHeight(vPos);
		vPos[2] += 1.0;
		TR_GetPlaneNormal(trace, vNorm);
		GetVectorAngles(vNorm, vAng);
		if (vNorm[2] == 1.0)
		{
			vAng[0] = 0.0;
			vAng[1] = degrees + 180;
		}
		else
		{
			if (degrees > vAng[1])
				degrees = vAng[1] - degrees;
			else
				degrees = degrees - vAng[1];
			vAng[0] += 90.0;
			RotateYaw(vAng, degrees + 180);
		}
	}
	else
	{
		delete trace;
		return false;
	}

	vAng[1] += 90.0;
	vAng[2] -= 90.0;
	delete trace;
	return true;
}

bool _TraceFilter(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

//---------------------------------------------------------
// do a specific rotation on the given angles
//---------------------------------------------------------
void RotateYaw(float angles[3], float degree)
{
	float direction[3], normal[3];
	GetAngleVectors(angles, direction, NULL_VECTOR, normal);

	float sin = Sine(degree * 0.01745328);	 // Pi/180
	float cos = Cosine(degree * 0.01745328);
	float a = normal[0] * sin;
	float b = normal[1] * sin;
	float c = normal[2] * sin;
	float x = direction[2] * b + direction[0] * cos - direction[1] * c;
	float y = direction[0] * c + direction[1] * cos - direction[2] * a;
	float z = direction[1] * a + direction[2] * cos - direction[0] * b;
	direction[0] = x;
	direction[1] = y;
	direction[2] = z;

	GetVectorAngles(direction, angles);

	float up[3];
	GetVectorVectors(direction, NULL_VECTOR, up);

	float roll = GetAngleBetweenVectors(up, normal, direction);
	angles[2] += roll;
}

//---------------------------------------------------------
// calculate the angle between 2 vectors
// the direction will be used to determine the sign of angle (right hand rule)
// all of the 3 vectors have to be normalized
//---------------------------------------------------------
float GetAngleBetweenVectors(const float vector1[3], const float vector2[3], const float direction[3])
{
	float vector1_n[3], vector2_n[3], direction_n[3], cross[3];
	NormalizeVector(direction, direction_n);
	NormalizeVector(vector1, vector1_n);
	NormalizeVector(vector2, vector2_n);
	float degree = ArcCosine(GetVectorDotProduct(vector1_n, vector2_n)) * 57.29577951;   // 180/Pi
	GetVectorCrossProduct(vector1_n, vector2_n, cross);

	if (GetVectorDotProduct(cross, direction_n) < 0.0)
		degree *= -1.0;

	return degree;
}