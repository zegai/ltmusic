#pragma once
#ifndef __AUDIOF_H__
#define __AUDIOF_H__
#include "AudioPlay.h"
#include "stdafx.h"
class AudioFactory
{
public:
	inline AudioPlay* CreateAudioStream(const LTSTRING* filetype);
	AudioPlay* CreateAudioStream(const TCHAR* filetype);
	inline MUSICTYPE CheckAudioType(const LTSTRING* filetype);
	MUSICTYPE CheckAudioType(const TCHAR* filetype);
	static AudioFactory* CreateInstance();
	virtual ~AudioFactory(){};
private:
	AudioFactory(){};
};
#endif