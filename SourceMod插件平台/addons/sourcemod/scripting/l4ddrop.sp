#define PLUGIN_VERSION "1.11"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define FL_PISTOL_PRIMARY (1<<6) // Is 1 when you have a primary weapon and dual pistols
#define FL_PISTOL (1<<7) // Is 1 when you have dual pistols

public Plugin myinfo = 
{
	name = "[L4D1] Drop Weapon",
	author = "Frustian, Figa, (improved by Dragokas & SilverShot)",
	description = "Allows players to drop the weapon they are holding, or another items they have",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=311156"
}

/*
	Fork by Dragokas
	
	1.11 (24-Apr-2021)
	 - Added Traditional and Simplified Chinese translations (thanks to Harry Potter).
	
	1.10 (23-Apr-2021)
	 - "give" command flags restoring, instead of forcing FCVAR_CHEAT.
	 - Forced restriction to use with L4D1 only.
	 - Code beautified.
	
	1.9 (25-Mar-2020)
	- Small optimizations
	
	1.8
	- Added support for "Prototype Grenades" plugin. This require "preferences" to set other than 1.
	- Added immunity for root admin "z" to limits on using drop command.
	- Fixed entities leak (thanks to SilverShot).
	- Added some safe checks, code optimizations.
	- Translation is optimized and appended.
	
	1.7
	- Converted to a new syntax and methodmaps.
	- Fixed potential crash caused by too often usage of drop command (see new ConVars).
	
	1.6.
	- Update for previous exploit: removed dependency on specific player model (thanks to SilverShot)
    - Updated translation file.
	
	1.5.
	- Fixed exploit for infinite pipe/molotov (thanks to SilverShot)
	
	1.3.
	- Removed F3 key binding
	
	1.3
	- Added IsClientInGame() check.
*/

ConVar g_hSpecify, g_hRestrict, g_hTimeViolation, g_hMinInterval;
int g_iLastTime[MAXPLAYERS+1], g_iTimes[MAXPLAYERS+1], g_iTimeViolation[MAXPLAYERS+1], ammoOffset;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead ) {
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("drop.phrases");

	CreateConVar("l4d_drop_version2", PLUGIN_VERSION, "Drop Weapon Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	g_hSpecify 			= CreateConVar("l4d_drop_specify", 			"1", 	"Allow to specify weapon name in the sm_drop <argument> (1 - On / 0 - Off)", FCVAR_NOTIFY);
	g_hMinInterval 		= CreateConVar("l4d_drop_mininterval", 		"1", 	"Minimum allowed interval between each drop (in sec.)", FCVAR_NOTIFY);
	g_hRestrict 		= CreateConVar("l4d_drop_restrict", 		"0", 	"Number of times / in minute allowed for player to use drop command (0 - to disable restriction)", FCVAR_NOTIFY);
	g_hTimeViolation 	= CreateConVar("l4d_drop_timeviolation", 	"20", 	"Number of seconds to violate player for using drop command too often", FCVAR_NOTIFY);
	
	RegConsoleCmd("sm_drop", Command_Drop, "Drop currently equipped weapon on the floor");
	
	ammoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
}

public Action Command_Drop(int client, int args)
{
	if( !client || !IsClientInGame(client) )
		return Plugin_Handled;
	
	if( GetClientTeam(client) != 2 || !IsPlayerAlive(client) )
		return Plugin_Handled;
	
	static char weapon[32];
	if( args > 1 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_drop [weapon]");
		return Plugin_Handled;
	}
	
	if( g_iLastTime[client] != 0 )
	{
		// not often than X sec between each drop
		if( GetTime() - g_iLastTime[client] < g_hMinInterval.IntValue && !IsClientRootAdmin(client) )
		{
			PrintToChat(client, "%t", "Too_often"); // You can't use drop too often!
			return Plugin_Handled;
		}
		
		// not more than X drops per minute
		if( GetTime() - g_iLastTime[client] < 60 )
		{
			g_iTimes[client]++;
		}
		
		if( g_iTimes[client] > g_hRestrict.IntValue && !IsClientRootAdmin(client) )
		{
			g_iTimes[client] = 0;
			g_iTimeViolation[client] = GetTime() + g_hTimeViolation.IntValue;
			PrintToChat(client, "%t", "End_Limit"); // Your limit of drops is exceeded
			return Plugin_Handled;
		}
		
		// if violation is applied
		if( g_iTimeViolation[client] > GetTime() && !IsClientRootAdmin(client) )
		{
			PrintToChat(client, "%t", "Wait_Drop"); // You must wait some time before you can drop again
			return Plugin_Handled;
		}
	}
	g_iLastTime[client] = GetTime();

	if( args == 1 )
	{
		if( g_hSpecify.IntValue )
		{
			GetCmdArg(1, weapon, 32);
			if( (StrContains(weapon, "pump") != -1 || StrContains(weapon, "auto") != -1 || StrContains(weapon, "shot") != -1 || StrContains(weapon, "rifle") != -1 || StrContains(weapon, "smg") != -1 || StrContains(weapon, "uzi") != -1 || StrContains(weapon, "m16") != -1 || StrContains(weapon, "hunt") != -1) && GetPlayerWeaponSlot(client, 0) != -1 )
				DropSlot(client, 0);
			else if( (StrContains(weapon, "pistol") != -1) && GetPlayerWeaponSlot(client, 1) != -1 )
				DropSlot(client, 1);
			else if( (GetPlayerWeaponSlot(client, 2) != -1) && (StrContains(weapon, "pipe") != -1) ) {
				if( !UsePipeExploit(client, false) )
					DropSlot(client, 2);
			}
			else if( (GetPlayerWeaponSlot(client, 2) != -1) && (StrContains(weapon, "mol") != -1) ) {
				if( !UsePipeExploit(client, true) )
					DropSlot(client, 2);
			}
			else if( (StrContains(weapon, "kit") != -1 || StrContains(weapon, "pack") != -1 || StrContains(weapon, "med") != -1) && GetPlayerWeaponSlot(client, 3) != -1 )
				DropSlot(client, 3);
			else if( (StrContains(weapon, "pill") != -1) && GetPlayerWeaponSlot(client, 4) != -1 )
				DropSlot(client, 4);
			else
				PrintToChat(client, "%t", "drop_nothing", weapon);
		}
		else
			ReplyToCommand(client, "%t", "drop_specify");
		return Plugin_Handled;
	}
	GetClientWeapon(client, weapon, sizeof(weapon));
	if( strcmp(weapon, "weapon_pumpshotgun") == 0 || strcmp(weapon, "weapon_autoshotgun") == 0 || strcmp(weapon, "weapon_rifle") == 0 || strcmp(weapon, "weapon_smg") == 0 || strcmp(weapon, "weapon_hunting_rifle") == 0 )
		DropSlot(client, 0);
	else if( strcmp(weapon, "weapon_pistol") == 0 )
		DropSlot(client, 1);
	else if( strcmp(weapon, "weapon_pipe_bomb") == 0 ) {
		if( !UsePipeExploit(client, false) )
			DropSlot(client, 2);
	}
	else if( strcmp(weapon, "weapon_molotov") == 0 ) {
		if( !UsePipeExploit(client, true) )
			DropSlot(client, 2);
	}
	else if( strcmp(weapon, "weapon_first_aid_kit") == 0 )
		DropSlot(client, 3);
	else if( strcmp(weapon, "weapon_pain_pills") == 0 )
		DropSlot(client, 4);
	return Plugin_Handled;
}

bool UsePipeExploit(int client, bool bMolotov) // thanks to SilverShot
{
	int wep = GetPlayerWeaponSlot(client, 2);
	
	float deltaNextAttack = GetEntPropFloat(wep, Prop_Send, "m_flNextPrimaryAttack") - GetGameTime();
	
	if( deltaNextAttack > 0)
	{
		MsgExploit(client, bMolotov);
		return true;
	}
	return false;
}

void MsgExploit(int client, bool bMolotov)
{
	if( bMolotov )
		PrintToChat(client, "%t", "drop_exploit_molotov", client);
	else
		PrintToChat(client, "%t", "drop_exploit_pipe_bomb", client);
}

public void DropSlot(int client, int slot)
{
	int iWeap, index, iHammerId;
	float cllocation[3];
	
	iWeap = GetPlayerWeaponSlot(client, slot);
	
	if( iWeap != -1 )
	{
		char sWeapon[32];
		int ammo;
		int clip;

		GetEdictClassname(iWeap, sWeapon, 32);
		switch( slot ) {
			case 0:
			{
				clip = GetEntProp(iWeap, Prop_Send, "m_iClip1");
				ClientCommand(client, "vocalize PlayerSpotOtherWeapon");
				if( 0 == strcmp(sWeapon, "weapon_pumpshotgun") )
				{
					ammo = GetEntData(client, ammoOffset+(6*4));
					SetEntData(client, ammoOffset+(6*4), 0);
					PrintToChatAll("%t", "drop_pumpshotgun", client);
				}
				else if( 0 == strcmp(sWeapon, "weapon_autoshotgun") )
				{
					ammo = GetEntData(client, ammoOffset+(6*4));
					SetEntData(client, ammoOffset+(6*4), 0);
					PrintToChatAll("%t", "drop_autoshotgun", client);
				}
				else if( 0 == strcmp(sWeapon, "weapon_smg") )
				{
					ammo = GetEntData(client, ammoOffset+(5*4));
					SetEntData(client, ammoOffset+(5*4), 0);
					PrintToChatAll("%t", "drop_smg", client);
				}
				else if( 0 == strcmp(sWeapon, "weapon_rifle") )
				{
					ammo = GetEntData(client, ammoOffset+(3*4));
					SetEntData(client, ammoOffset+(3*4), 0);
					PrintToChatAll("%t", "drop_rifle", client);
				}
				else if( 0 == strcmp(sWeapon, "weapon_hunting_rifle") )
				{
					ammo = GetEntData(client, ammoOffset+(2*4));
					SetEntData(client, ammoOffset+(2*4), 0);
					PrintToChatAll("%t", "drop_hunting_rifle", client);
				}
			}
			case 1:
			{
				if( (GetEntProp(client, Prop_Send, "m_iAddonBits") & (FL_PISTOL|FL_PISTOL_PRIMARY)) > 0 )
				{
					if( iWeap != -1 ) {
						clip = GetEntProp(iWeap, Prop_Send, "m_iClip1");
						RemovePlayerItem(client, iWeap);
						AcceptEntityInput(iWeap, "Kill");
					}
					int iflags = GetCommandFlags("give");
					SetCommandFlags("give", iflags &~ FCVAR_CHEAT);
					FakeClientCommand(client, "give pistol", sWeapon);
					SetCommandFlags("give", iflags);
					
					iWeap = GetPlayerWeaponSlot(client, 1);
					
					if (clip < 15)
						SetEntProp(iWeap, Prop_Send, "m_iClip1", 0);
					else
						SetEntProp(iWeap, Prop_Send, "m_iClip1", clip-15);
					
					index = CreateEntityByName(sWeapon);
					if( index != -1 )
					{
						GetClientAbsOrigin(client, cllocation);
						cllocation[2]+=20;
						TeleportEntity(index,cllocation, NULL_VECTOR, NULL_VECTOR);
						DispatchSpawn(index);
						ActivateEntity(index);
					}
					PrintToChatAll("%t", "drop_pistol", client);
					ClientCommand(client, "vocalize PlayerSpotPistol");
				}
				else
					PrintToChat(client, "%t", "drop_last_pistol");
				return;
			}
			case 2:
			{
				if( 0 == strcmp(sWeapon, "weapon_pipe_bomb") )
				{
					PrintToChatAll("%t", "drop_pipe_bomb", client);
					ClientCommand(client, "vocalize PlayerSpotGrenade");
				}
				else if( 0 == strcmp(sWeapon, "weapon_molotov") )
				{
					PrintToChatAll("%t", "drop_molotov", client);
					ClientCommand(client, "vocalize PlayerSpotMolotov");
				}
				iHammerId = GetEntProp(iWeap, Prop_Data, "m_iHammerID");
			}
			case 3:
			{
				if( 0 == strcmp(sWeapon, "weapon_first_aid_kit") )
				{
					PrintToChatAll("%t", "drop_first_aid_kit", client);
					ClientCommand(client, "vocalize PlayerSpotFirstAid");
				}
			}
			case 4:
			{
				if( 0 == strcmp(sWeapon, "weapon_pain_pills") )
				{
					PrintToChatAll("%t", "drop_pills", client);
					ClientCommand(client, "vocalize PlayerSpotPills");
				}
			}
		}
		
		index = CreateEntityByName(sWeapon);
		if( index != -1 )
		{
			GetClientAbsOrigin(client, cllocation);
			cllocation[2]+=20;
			TeleportEntity(index,cllocation, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(index);
			ActivateEntity(index);
			
			iWeap = GetPlayerWeaponSlot(client, slot);
			if( iWeap != -1 )
			{
				RemovePlayerItem(client, iWeap);
				AcceptEntityInput(iWeap, "Kill");
			}
			
			if( slot == 0 )
			{
				SetEntProp(index, Prop_Send, "m_iExtraPrimaryAmmo", ammo);
				SetEntProp(index, Prop_Send, "m_iClip1", clip);
			}
			if( slot == 2 )
			{
				 SetEntProp(index, Prop_Data, "m_iHammerID", iHammerId);
			}
		}
	}
}

stock bool IsClientRootAdmin(int client)
{
	return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}
