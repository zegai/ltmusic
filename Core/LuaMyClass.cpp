 #include "StdAfx.h"
#include "luamyclass.h"
#include "mp3play.h"
#include "Log.h"
#include <commdlg.h>
#include <Shlwapi.h>
int LuaMyClass::Play(lua_State* luaState)
{
    PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
    if(ppMyClass && (*ppMyClass))
    {
		int lhs = static_cast<int>(lua_tointeger(luaState, 2));
		const char* path = lua_tostring(luaState, 3);
		LTSTRING strpath;
		#ifdef _UNICODE
			UTF8_to_Unicode(path, strlen(path), strpath);
		#else
		#endif
		//MultiByteToWideChar(CP_ACP, 0, rhs.c_str(), -1, (LPWSTR)transto, rhs.length());
        Mul_Node node;
		node.Mes_Type = PLAY;
		node.UserData.play.playflag = lhs;
		node.UserData.play.ltstring =  new LTSTRING(strpath);
		(*ppMyClass)->inslistNode(node);
        return 0;     
    }
    //lua_pushnil(luaState);
    return 0;
}

int LuaMyClass::Pause(lua_State* luaState)
{
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{
		Mul_Node node;
		node.Mes_Type = PAUSE;
		(*ppMyClass)->inslistNode(node);
		return 0;     
	}
	return 0;
}

int LuaMyClass::Init(lua_State* luaState)
{
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{
		Mul_Node node;
		node.Mes_Type = INIT;
		(*ppMyClass)->inslistNode(node);
		return 0;     
	}
	return 0;
}

int LuaMyClass::Stop(lua_State* luaState)
{
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{
		const char* rhs = static_cast<const char*>(lua_tostring(luaState,2));
		Mul_Node node;
		node.Mes_Type = STOP;
		(*ppMyClass)->inslistNode(node);
		return 0;     
	}
	return 0;
}

int LuaMyClass::Jump(lua_State* luaState)
{
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{
		int rhs = static_cast<int>(lua_tointeger(luaState,2));
		
		Mul_Node node;
		node.Mes_Type = JUMP;
		node.UserData.JumpPersent = rhs;
		(*ppMyClass)->inslistNode(node);
		return 0;     
	}
	return 0;
}
int LuaMyClass::GetPath(lua_State* luaState){
	static WCHAR wszModulePath[MAX_PATH];
	GetModuleFileNameW(NULL,wszModulePath,MAX_PATH);
	PathAppend(wszModulePath, L"..\\");
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{

#ifdef _UNICODE
			std::string retv;
			Unicode_to_UTF8(wszModulePath, ::wcslen(wszModulePath), retv);
			lua_pushstring(luaState, retv.c_str());
#else
			lua_pushstring(luaState, (char*)(path));
			lua_pushstring(luaState, (char*)(Name));
#endif

			return 1;
	}
	lua_pushnil(luaState);
	return 1;

}
int LuaMyClass::OpenFile(lua_State* luaState)
{
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{
		OPENFILENAME opfn;
		memset(&opfn, 0, sizeof(opfn));
		opfn.lStructSize = sizeof(OPENFILENAME);
		opfn.lpstrFilter = _T("MP3文件\0*.mp3\0FLAC文件\0*.flac\0");
		opfn.nFilterIndex = 1;

		TCHAR path[100] = {0};
		opfn.lpstrFile = path;
		opfn.nMaxFile = sizeof(path);
		opfn.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST;
		if(GetOpenFileName(&opfn)){
			TCHAR Name[_MAX_FNAME] = {0};
			_tsplitpath_s(path, NULL, 0, NULL, 0, Name, _MAX_FNAME, NULL, 0);
			
			#ifdef _UNICODE
				std::string retv;
				Unicode_to_UTF8(path, ::wcslen(path), retv);
				lua_pushstring(luaState, retv.c_str());
				Unicode_to_UTF8(Name, ::wcslen(Name), retv);
				lua_pushstring(luaState, retv.c_str());
			#else
				lua_pushstring(luaState, (char*)(path));
				lua_pushstring(luaState, (char*)(Name));
			#endif
			
			DWORD value = 0;
			MusicControl::GetMusicInfo(MCI_STATUS_LENGTH, path, value);
			lua_pushnumber(luaState, value);
			return 3;
		}
	}
	lua_pushnil(luaState);
	lua_pushnil(luaState);
	lua_pushnil(luaState);
	return 3; 
}



int LuaMyClass::GetTime(lua_State* luaState)
{
	std::string comparev(lua_tostring(luaState, 2));
	TCHAR transto[100] = {0};
	MultiByteToWideChar(CP_ACP, 0, comparev.c_str(), -1, (LPWSTR)transto, comparev.length());
	if(_tcscmp(transto, _T("FULLTIME")) == 0){
		unsigned a = MusicControl::GetInstance()->MusicGetFullTime();
		lua_pushnumber(luaState,a);
		return 1;
	}
	else if(_tcscmp(transto, _T("CURTIME")) == 0){
		unsigned a = MusicControl::GetInstance()->MusicGetCurTime();
		lua_pushnumber(luaState, a);
		return 1;
	}
	lua_pushnil(luaState);
	return 1;
}
int LuaMyClass::Volume(lua_State* luaState){
	PlayMid<Mul_Node>** ppMyClass = 
		reinterpret_cast<PlayMid<Mul_Node>**>(luaL_checkudata(luaState,1,MUSIC_LUA_CLASS));   
	if(ppMyClass && (*ppMyClass))
	{
		int rhs = static_cast<int>(lua_tointeger(luaState,2));

		Mul_Node node;
		node.Mes_Type = VOLUME;
		node.UserData.JumpPersent = rhs;
		(*ppMyClass)->inslistNode(node);
		return 0;     
	}
	return 0;
}

static XLLRTGlobalAPI LuaMyClassMemberFunctions[] = 
{
    {"Play",LuaMyClass::Play},
	{"Pause",LuaMyClass::Pause},
	{"Stop",LuaMyClass::Stop},
	{"Jump",LuaMyClass::Jump},
	{"GetTime",LuaMyClass::GetTime},
	{"OpenFile",LuaMyClass::OpenFile},
	{"GetPath",LuaMyClass::GetPath},
	{"Init", LuaMyClass::Init},
	{"Volume", LuaMyClass::Volume},
    {NULL,NULL}
};

void LuaMyClass::RegisterClass(XL_LRT_ENV_HANDLE hEnv)
{
    if(hEnv == NULL)
    {
        return;
    }
	MusicControl* control = MusicControl::GetInstance();
	HANDLE controlt = ::CreateThread(NULL, 0, MusicControl::PlayThread, control, NULL, NULL);
    long nLuaResult = XLLRT_RegisterClass(hEnv,MUSIC_LUA_CLASS,LuaMyClassMemberFunctions,NULL,0);
}
//------------------------------------------------------------------
int LuaMyClassFactory::CreateInstance(lua_State* luaState)
{
    PlayMid<Mul_Node>* pResult = PlayMid<Mul_Node>::GetInstance();
    XLLRT_PushXLObject(luaState,MUSIC_LUA_CLASS,pResult);
    return 1;
}

LuaMyClassFactory* __stdcall LuaMyClassFactory::Instance(void*)
{
    static LuaMyClassFactory* s_pTheOne = NULL;
    if(s_pTheOne == NULL)
    {
        s_pTheOne = new LuaMyClassFactory();
    }
    return s_pTheOne;
}

static XLLRTGlobalAPI LuaMyClassFactoryMemberFunctions[] = 
{
    {"CreateInstance",LuaMyClassFactory::CreateInstance},
    {NULL,NULL}
};

void LuaMyClassFactory::RegisterObj(XL_LRT_ENV_HANDLE hEnv)
{
    if(hEnv == NULL)
	{
        return ;
	}

    XLLRTObject theObject;
    theObject.ClassName = MUSIC_FACTORY_LUA_CLASS;
    theObject.MemberFunctions = LuaMyClassFactoryMemberFunctions;
    theObject.ObjName = MUSIC_FACTORY_LUA_OBJ;
    theObject.userData = NULL;
    theObject.pfnGetObject = (fnGetObject)LuaMyClassFactory::Instance;

    XLLRT_RegisterGlobalObj(hEnv,theObject); 
}