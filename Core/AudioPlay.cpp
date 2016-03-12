#include "StdAfx.h"
#include "AudioPlay.h"

AudioPlay::AudioPlay(void):Sec_(0),
	Cur_(0),Volume_(100)
{
	Cur_Path_ = new LTSTRING(_T("NULL"));
}


AudioPlay::~AudioPlay(void)
{
}

void AudioPlay::Audio_Init(){

}
bool AudioPlay::Audio_Open(LTSTRING* strpath){
	MCI_OPEN_PARMS mciOp;
	mciOp.lpstrDeviceType = _T("mpegvideo");
	mciOp.lpstrElementName = strpath->c_str();
	MCIERROR ret = mciSendCommand(
		NULL,
		MCI_OPEN,
		MCI_OPEN_ELEMENT,
		(DWORD)(LPVOID)&mciOp);
	if(ret){
		type.MCIType = NULL;
		TCHAR buf[128] = {0};
		mciGetErrorString(ret, buf, 128);
		return false;
	}
	type.MCIType = mciOp.wDeviceID;

	MCI_STATUS_PARMS mciStatus;
	mciStatus.dwItem = MCI_STATUS_LENGTH;
	ret = mciSendCommand(
		type.MCIType,
		MCI_STATUS,
		MCI_WAIT | MCI_STATUS_ITEM,
		(DWORD)(LPVOID)&mciStatus);

	Sec_ = mciStatus.dwReturn;
	if(Cur_Path_)
		delete Cur_Path_;
	Cur_Path_ = new LTSTRING(strpath->c_str());
	return true;
}

void AudioPlay::Audio_Play(){
	assert(type.MCIType);
	MCI_PLAY_PARMS mciPlay;
	DWORD ret = mciSendCommand(
		type.MCIType,
		MCI_PLAY,
		MCI_NOTIFY ,
		(DWORD)(LPVOID)&mciPlay);
	//
}

void AudioPlay::Audio_Pause(){
	assert(type.MCIType);
	MCI_PLAY_PARMS mciPause; 
	DWORD ret = mciSendCommand(
		type.MCIType,
		MCI_PAUSE,
		0,
		(DWORD)(LPVOID)&mciPause);
}

bool AudioPlay::Audio_GetInfo(DWORD reg,const TCHAR* path,OUT DWORD& str){
	MCI_OPEN_PARMS mciOp;
	MCIDEVICEID Dev_Id_;
	mciOp.lpstrDeviceType = _T("mpegvideo");
	mciOp.lpstrElementName = path;
	MCIERROR ret = mciSendCommand(
		NULL,
		MCI_OPEN,
		MCI_OPEN_ELEMENT,
		(DWORD)(LPVOID)&mciOp);
	if(ret){
		Dev_Id_ = NULL;
		TCHAR buf[128] = {0};
		mciGetErrorString(ret, buf, 128);
		//log("MCI ERROR:%s\n", buf);
		return false;
	}
	Dev_Id_ = mciOp.wDeviceID;

	MCI_STATUS_PARMS mciStatus;
	mciStatus.dwItem = reg;
	ret = mciSendCommand(
		Dev_Id_,
		MCI_STATUS,
		MCI_WAIT | MCI_STATUS_ITEM,
		(DWORD)(LPVOID)&mciStatus);
	str = mciStatus.dwReturn;
	return true;
}

void AudioPlay::Audio_Jump(unsigned persent){
	unsigned jumpvalue = static_cast<unsigned>(Sec_*1.0*persent/1000);
	assert(jumpvalue > 0);
	MCI_SEEK_PARMS mciSeek;
	mciSeek.dwTo = jumpvalue;
	mciSendCommand(
		type.MCIType,
		MCI_SEEK,
		MCI_TO | MCI_WAIT,
		(DWORD)(LPVOID)&mciSeek);
}

void AudioPlay::Audio_GetCurTime(){
	MCI_STATUS_PARMS mciStatus;
	mciStatus.dwItem = MCI_STATUS_POSITION;
	MCIERROR ret = mciSendCommand(
		type.MCIType,
		MCI_STATUS,
		MCI_WAIT | MCI_STATUS_ITEM,
		(DWORD)(LPVOID)&mciStatus);
	if (ret)
	{
		TCHAR buf[100] = {0};
		mciGetErrorString(ret, buf, 100);
		return ;
	}
	Cur_ = mciStatus.dwReturn;
}

void AudioPlay::Audio_Stop(){
	if (type.MCIType != NULL)
	{
		mciSendCommand(type.MCIType, MCI_STOP, NULL, NULL);
		mciSendCommand(type.MCIType, MCI_CLOSE, NULL, NULL);
		type.MCIType = NULL;
		//
	}
}

void AudioPlay::Audio_Volume(unsigned persent){

}

void AudioPlay::Audio_Release(){

}



BASSPlay::BASSPlay(void){
	type.BassType = 0;
}
BASSPlay::~BASSPlay(void){}

bool BASSPlay::Audio_Open(LTSTRING* strpath){
	type.BassType = BASS_StreamCreateFile(FALSE,strpath->c_str(),0,0,0);
	if( !type.BassType ){
		return false;
	}
	DWORD len = (DWORD)BASS_ChannelGetLength(type.BassType,BASS_POS_BYTE);
	Sec_ = (unsigned int)BASS_ChannelBytes2Seconds(type.BassType, len)*1000; 
	if(Cur_Path_)
		delete Cur_Path_;
	Cur_Path_ = new LTSTRING(strpath->c_str());
	return true;
}

bool BASSPlay::Audio_GetInfo(DWORD reg,const TCHAR* path,OUT DWORD& str){
	BOOL r = BASS_Init(-1,44100,0,0,NULL);
	HSTREAM BassType = BASS_StreamCreateFile(FALSE,path,0,0,0);
	QWORD len = BASS_ChannelGetLength(BassType,BASS_POS_BYTE);
	str = (DWORD)BASS_ChannelBytes2Seconds(BassType, len)*1000;
	BASS_StreamFree(BassType);
	return true;
}

void BASSPlay::Audio_Init(){
	BOOL r = BASS_Init(-1,44100,0,0,NULL);
}

void BASSPlay::Audio_GetCurTime(){
	if(type.BassType){
		DWORD now = (DWORD)BASS_ChannelGetPosition(type.BassType,BASS_POS_BYTE);
		Cur_ = (unsigned int)BASS_ChannelBytes2Seconds(type.BassType, now)*1000; 
	} 
}

void BASSPlay::Audio_Pause(){
	BASS_ChannelPause(type.BassType);
}

void BASSPlay::Audio_Play(){
	BASS_ChannelPlay(type.BassType, false);
}

void BASSPlay::Audio_Stop(){
	BASS_ChannelStop(type.BassType);
}

void BASSPlay::Audio_Release(){

}

void BASSPlay::Audio_Volume(unsigned persent){
	Volume_ = persent;
	BOOL t = BASS_ChannelSetAttribute(type.BassType, BASS_ATTRIB_VOL, (float)persent/100);
}

void BASSPlay::Audio_Jump(unsigned persent){
	QWORD len = BASS_ChannelGetLength(type.BassType,BASS_POS_BYTE);
	len = len*persent/100;
	BOOL t = BASS_ChannelSetPosition(type.BassType, len, BASS_POS_BYTE);
}

