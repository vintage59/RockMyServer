/*
Thanks to CAPS LOCK FUCK YEAH for plugin hidden url wich is the base of this one
*/

#define PLUGIN_VERSION "3.0"
#include <sourcemod>

new Handle:g_hTimer[MAXPLAYERS + 1]

public Plugin:myinfo =  {
	name = "Rock the server !", 
	author = "CAPS LOCK FUCK YEAH, vintage", 
	description = "Send music to your players with streaming by HTML5", 
	version = PLUGIN_VERSION, 
	url = "http://dodsplugins.mtxserv.fr"
}

public OnPluginStart() {
	CreateConVar("Rock_The_Server_version", PLUGIN_VERSION, "", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY)
	RegAdminCmd("sm_playzik", Command_url, ADMFLAG_KICK, "Command to send sounds")
	LoadTranslations("common.phrases")
	RegConsoleCmd("say", Command_Say)
	RegConsoleCmd("say_team", Command_Say)
	HookEvent("dod_game_over", RoundWin)
	HookEvent("dod_round_win", RoundWin)
}

public Action:Command_url(client, args)
{
	
	new String:arg1[32], String:arg2[128], argcount
	
	argcount = GetCmdArgs();
	if (argcount == 0 || argcount == 1)
	{
		ReplyToCommand(client, "Usage: sm_playzik <target> <URL>")
		return Plugin_Handled
	}
	if (argcount == 2)
	{
		GetCmdArg(1, arg1, sizeof(arg1))
		GetCmdArg(2, arg2, sizeof(arg2))
		new String:target_name[MAX_TARGET_LENGTH]
		new target_list[MAXPLAYERS], target_count
		new bool:tn_is_ml
		target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, target_name, sizeof(target_name), tn_is_ml)
		
		if (target_count <= 0)
		{
			/* This function replies to the admin with a failure message */
			ReplyToTargetError(client, target_count)
			return Plugin_Handled
		}
		
		for (new i = 0; i < target_count; i++)
		{
			DoUrl(target_list[i], arg2)
		}
		PrintToChatAll("\x01Type \x04!stop \x01for stopping sound")
	}
	return Plugin_Handled
}

public Action:DoUrl(client, String:url[128])
{
	new Handle:setup = CreateKeyValues("data")
	
	KvSetString(setup, "title", "Musique Please!")
	KvSetNum(setup, "type", MOTDPANEL_TYPE_URL)
	KvSetString(setup, "msg", url)
	
	ShowVGUIPanel(client, "info", setup, false)
	CloseHandle(setup)
	return Plugin_Handled
}

public Action:Command_Say(client, args)
{
	decl String:Client_Said[128]
	
	GetCmdArgString(Client_Said, sizeof(Client_Said) - 1)
	StripQuotes(Client_Said)
	TrimString(Client_Said)
	if (StrEqual(Client_Said, "!stop"))
	{
		PrintToChat(client, "..\x04Sound stopped !\x01...")
		DoUrl(client, "about:blank")
	}
	return Plugin_Continue
}

public RoundWin(Handle:event, const String:name[], bool:dontBroadcast)
{
	for (new x = 1; x <= MaxClients; x++)
	{
		if (IsClientInGame(x))
		{
			DoUrl(x, "about:blank")
		}
	}
}

/*public OnClientAuthorized(client, const String:auth[])
{
	QueryClientConVar(client, "cl_disablehtmlmotd", ConVarQueryFinished:htmlfilter);
}
*/
public OnClientPutInServer(client)
{
	QueryClientConVar(client, "cl_disablehtmlmotd", ConVarQueryFinished:htmlfilter);
	g_hTimer[client] = CreateTimer(30.0, message, client)
}

public OnClientDisconnect(client)
{
	if (g_hTimer[client] != INVALID_HANDLE)
	{
		KillTimer(g_hTimer[client])
		g_hTimer[client] = INVALID_HANDLE
	}
}

public Action:message(Handle:Timer, any:client)
{
	PrintToChat(client, "\x04[Music system]\x01\to stop a sound\n\x04!stop\x01 in chat! Or \x04bind\x01 a key!")
	if (g_hTimer[client] != INVALID_HANDLE)
	{
		KillTimer(g_hTimer[client])
		g_hTimer[client] = INVALID_HANDLE
	}
}

public htmlfilter(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName1[], const String:cvarValue1[])
{
	if (IsClientConnected(client))
	{
		if (strcmp(cvarValue1, "1", true) == 0)
		{
			PrintToChat(client, "\x04-------------------------------------------\x01")
			PrintToChat(client, "-----HTMLMOTD is disabled in your cfg----------")
			PrintToChat(client, "-----You won't have access to our sounds-------")
			PrintToChat(client, "------To have fun with us : in console :-------")
			PrintToChat(client, "----     \x04cl_disablehtmlmotd=0\x01 !!!! ----")
			PrintToChat(client, "\x04-------------------------------------------\x01")
		}
	}
}
