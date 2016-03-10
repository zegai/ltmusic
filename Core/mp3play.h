#pragma once

#include "stdafx.h"
#include "AudioPlay.h"
#include "../core/Log.h"



#ifdef _DEBUG
#define try
#define catch(X) if(0)
#define log printf
#endif // _DEBUG


class SLock{
public:
	SLock(CRITICAL_SECTION &crt):lock(crt){EnterCriticalSection(&lock);};
	virtual ~SLock(){LeaveCriticalSection(&lock);};
	void Lock(){EnterCriticalSection(&lock);}
	void UnLock(){LeaveCriticalSection(&lock);}
private:
	CRITICAL_SECTION& lock;
};

template<
	typename T,
	typename _Container = std::queue<T>
>
class PlayMid{
public:

	typedef typename _Container::value_type value_type;

	static PlayMid<T>* GetInstance(){
		static PlayMid<T>* ins = NULL;
		if (ins == NULL){
			ins = new PlayMid<T>();
		}
		return ins;
	}

	bool getlistNode(value_type& node){
		SLock single(lock_);
		if (plist_.size()){
			new (&node) T(plist_.front());
			plist_.pop();
			return true;
		}
		return false;
	}

	void inslistNode(value_type& node){
		SLock single(lock_);
		plist_.push(node);
		SetEvent(EventHandle);
	}

	void ResetEv(){
		SLock single(lock_);
		ResetEvent(EventHandle);
	}

	HANDLE PGetEvent(){
		return EventHandle;
	}

	void PSetEvent(HANDLE eventtmp){
		SLock single(lock_);
		EventHandle = eventtmp;
	}
protected:
	explicit PlayMid(){
		InitializeCriticalSection(&lock_);
		EventHandle = CreateEvent(NULL,TRUE, FALSE, _T("QueueEV"));
	};

private:
	CRITICAL_SECTION lock_;
	_Container plist_;

	HANDLE EventHandle;
};
enum MType{

	PLAY = 0,
	PAUSE,
	STOP,
	JUMP,
	INIT,
	PLAY_T = 1000,
	PAUSE_T,
	STOP_T,
};

typedef struct Mul_Node_{
	MType Mes_Type;
	union UData{
		struct PlayStruct{
			unsigned playflag;	//0: stop to play, 1: pause to play, 2: change path to play
			LTSTRING* ltstring;
		}play;
		LTSTRING* ltstring; 			
		unsigned JumpPersent;	/*0-1000*/
	}UserData;
}Mul_Node;

class MusicControl
{
public:
	static DWORD WINAPI PlayThread(PVOID udata);
public:
	static MusicControl* GetInstance(){
		static MusicControl* tmp = NULL;
		if(tmp == NULL){
			tmp = new MusicControl();
		}
		return tmp;
	}

	void MusicPlay(Mul_Node &Node);
	void MusicPause(Mul_Node &Node);
	void MusicStop(Mul_Node &Node);
	void MusicJump(Mul_Node &Node);
	void MusicInit(Mul_Node &Node);
	unsigned MusicGetCurTime();
	unsigned MusicGetFullTime();
	#define OUT
	#define IN
	static bool GetMusicInfo(DWORD reg,const TCHAR* path,OUT DWORD& str);
protected:
	explicit MusicControl():
	Current_Type_(STOP_T)
	{
		Queue_Instance_ = PlayMid<Mul_Node>::GetInstance();
		audio = new BASSPlay();
	};
	MusicControl(AudioPlay* paudio):audio(paudio),Current_Type_(STOP_T){
		Queue_Instance_ = PlayMid<Mul_Node>::GetInstance();
	};

private:
	PlayMid<Mul_Node> *Queue_Instance_;
	MType Current_Type_;
	AudioPlay* audio;

};