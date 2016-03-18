#include "stdafx.h"
#include "AudioFactory.h"


AudioFactory*  AudioFactory::CreateInstance(){
	static AudioFactory* fac = NULL;
	if( !fac ){fac = new AudioFactory();}
	return fac;
}

AudioPlay* AudioFactory::CreateAudioStream(const TCHAR* filetype){
	AudioPlay* play = NULL;
	if(!_tcscmp(filetype, _T(".mp3"))){
		play = new BASSPlay();
		play->mtype = MP3;
	}else if(!_tcscmp(filetype, _T(".flac"))){
		play = new FLACBASSPlay();
		play->mtype = FLAC;
	}else{
		play = new AudioPlay();
		play->mtype = NONE;
	}
	return play;
}

AudioPlay* AudioFactory::CreateAudioStream(const LTSTRING* filetype){
	return this->CreateAudioStream(filetype->c_str());
}

MUSICTYPE AudioFactory::CheckAudioType(const TCHAR* filetype){
	if(!_tcscmp(filetype, _T(".mp3"))){
		return MP3;
	}else if(!_tcscmp(filetype, _T(".flac"))){
		return FLAC;
	}else{
		return NONE;
	}
}

MUSICTYPE AudioFactory::CheckAudioType(const LTSTRING* filetype){
	return this->CheckAudioType(filetype->c_str());
}

