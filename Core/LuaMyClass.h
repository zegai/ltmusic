 #pragma once


#define MUSIC_LUA_CLASS "HelloBolt.Music"
#define MUSIC_FACTORY_LUA_CLASS "HelloBolt.Music.Factory.Class"
#define MUSIC_FACTORY_LUA_OBJ "HelloBolt.Music.Factory"

class LuaMyClass
{
public:
    static int Play(lua_State* luaState);
	static int Pause(lua_State* luaState);
	static int Stop(lua_State* luaState);
	static int Jump(lua_State* luaState);
	static int GetTime(lua_State* luaState);
	static int GetPath(lua_State* luaState);
	static int Init(lua_State* luaState);
	static int OpenFile(lua_State* luaState);
	static int Volume(lua_State* luaState);
public:
    static void RegisterClass(XL_LRT_ENV_HANDLE hEnv);
};

//Ϊ���ܴ���MyClass Instance,���붨��һ���೧����
class LuaMyClassFactory
{
public:
    static LuaMyClassFactory* __stdcall Instance(void*);

    static int CreateInstance(lua_State* luaState);
   
public:
    static void RegisterObj(XL_LRT_ENV_HANDLE hEnv);
};
