#pragma once

union handle_type{
	MCIDEVICEID MCIType;
	HSTREAM BassType;
};

class AudioPlay
{
public:
	AudioPlay(void);
	virtual ~AudioPlay(void);

public:
	virtual bool Audio_Open(LTSTRING* strpath);
	virtual void Audio_Jump(unsigned persent);
	virtual bool Audio_GetInfo(DWORD reg,const TCHAR* path,OUT DWORD& str);
	virtual void Audio_GetCurTime();
	virtual void Audio_Pause();
	virtual void Audio_Play();
	virtual void Audio_Stop();
	virtual void Audio_Release();
	virtual void Audio_Init();
	virtual void Audio_Volume(unsigned persent);
	//virtual bool Audio_Handle_Status();
protected:
	handle_type type;
public:
	unsigned Sec_;
	unsigned Cur_;
	unsigned Volume_;
	LTSTRING* Cur_Path_;
};

class BASSPlay : public AudioPlay{
public:
	BASSPlay(void);
	~BASSPlay(void);
public:
	bool Audio_Open(LTSTRING* strpath);
	void Audio_Jump(unsigned persent);
	bool Audio_GetInfo(DWORD reg,const TCHAR* path,OUT DWORD& str);
	void Audio_GetCurTime();
	void Audio_Pause();
	void Audio_Play();
	void Audio_Stop();
	void Audio_Release();
	void Audio_Init();
	void Audio_Volume(unsigned persent);
	//bool Audio_Handle_Status();
};