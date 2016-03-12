#include "stdafx.h"
#include "mp3play.h"
#include <Digitalv.h>
#include "bass.h"

void MusicControl::MusicPlay(Mul_Node &Node)
{
	//new play
	if (Node.UserData.play.playflag == 0 && 
		audio->Cur_Path_->compare(Node.UserData.play.ltstring->c_str())){
		audio->Audio_Stop();
		audio->Audio_Open(Node.UserData.play.ltstring);
		audio->Audio_Volume(audio->Volume_);
		audio->Audio_Play();
	}
	else if (Node.UserData.play.playflag == 1) { //pause to play
		audio->Audio_Play();
	}
	Current_Type_ = PLAY_T;
	LTSTRING* tmp = NULL;
	if ((tmp = Node.UserData.play.ltstring) != NULL){
		delete tmp;
	}
}

void 
MusicControl::MusicStop(Mul_Node &Node)
{
	audio->Audio_Play();
	Current_Type_ = STOP_T;
}

void 
MusicControl::MusicPause(Mul_Node &Node)
{
	audio->Audio_Pause();
	Current_Type_ = PAUSE_T;
}

void 
MusicControl::MusicJump(Mul_Node &Node){
	audio->Audio_Jump(Node.UserData.JumpPersent);
}
void 
MusicControl::MusicInit(Mul_Node &Node)
{
	audio->Audio_Init();

}

void 
MusicControl::MusicVolume(Mul_Node &Node){
	audio->Audio_Volume(Node.UserData.JumpPersent);
}

unsigned 
MusicControl::MusicGetFullTime()
{
	return audio->Sec_;
}
unsigned 
MusicControl::MusicGetCurTime()
{
	audio->Audio_GetCurTime();
	return audio->Cur_;
}

bool
MusicControl::GetMusicInfo(DWORD reg,const TCHAR* path,OUT DWORD& str)
{
	return MusicControl::GetInstance()->audio->Audio_GetInfo(reg, path, str);
}

DWORD WINAPI 
MusicControl::PlayThread(PVOID udata)
{
	assert(udata);
	
	MusicControl* ucontrol = static_cast<MusicControl*>(udata);
	
	auto qqueue = ucontrol->Queue_Instance_;
	
	HANDLE ev = qqueue->PGetEvent();
	
	Mul_Node ControlNode;
	
	typedef void (MusicControl::*ptrWork)(Mul_Node&);
	//初始化响应函数列表
	ptrWork work[] = {
		(&MusicControl::MusicPlay),
		(&MusicControl::MusicPause),
		(&MusicControl::MusicStop),
		(&MusicControl::MusicJump),
		(&MusicControl::MusicInit),
		(&MusicControl::MusicVolume),
	};
	size_t ptr_c = sizeof(work)/sizeof(ptrWork);
	for (;;){
		DWORD ret = WaitForSingleObject(ev, 1000);
		if (WAIT_OBJECT_0 == ret){
			while (qqueue->getlistNode(ControlNode)){
				if(ControlNode.Mes_Type <= ptr_c);
					(ucontrol->*work[ControlNode.Mes_Type])(ControlNode);
			}
			qqueue->ResetEv();
		}
		else if (WAIT_TIMEOUT == ret){
			//log("Time Out\n");
			ucontrol->MusicGetCurTime();
		}
	}
}