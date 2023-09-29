#include <sourcemod>
#pragma semicolon 1

public Plugin:myinfo = 
{
        name = "L4D服务器名",
        author = "HMBSbige",
        description = "更改服务器名",
        version = "1.0",
        url = "https://github.com/HMBSbige"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();
    if( test != Engine_Left4Dead)
    {
        strcopy(error, err_max, "插件仅支持求生之路1.");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

public OnPluginStart()
{
        HookEvent("round_start", CheckTheChineseName);
}
public CheckTheChineseName(Handle:event, const String:name[], bool:dontBroadcast)
{

        new String:sPath[PLATFORM_MAX_PATH];
        BuildPath(Path_SM, sPath, sizeof(sPath),"configs/hostname/hostname.txt");
        
        new Handle:file = OpenFile(sPath, "r");
        if(file == INVALID_HANDLE)
        return;
        
        new String:readData[256];
        while(!IsEndOfFile(file) && ReadFileLine(file, readData, sizeof(readData)))
        {
                SetConVarString(FindConVar("hostname"),readData);
        }
}