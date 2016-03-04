#pragma once
#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>
#define  DEFAULT_FILE	("ERR.log")

#ifdef _UNICODE
	#define LogString std::wstring
#else
	#define LogString std::string
#endif

static void Unicode_to_UTF8(const wchar_t* in, unsigned int len, std::string& out)
{   
	size_t out_len = len * 3 + 1;
	char* pBuf = new char[out_len];
	if ( NULL == pBuf )
	{
		return;
	}
	char* pResult = pBuf;
	memset(pBuf, 0, out_len);

	out_len = ::WideCharToMultiByte(CP_UTF8, 0, in, len, pBuf, len * 3, NULL, NULL);
	out.assign( pResult, out_len );

	delete [] pResult;
	pResult = NULL;
	return;
}

static void UTF8_to_Unicode(const char* in, unsigned int len, std::wstring& out)
{
	wchar_t* pBuf = new wchar_t[len + 1];
	if ( NULL == pBuf )
	{
		return;
	}
	size_t out_len = (len + 1) * sizeof(wchar_t);
	memset(pBuf, 0, (len + 1) * sizeof(wchar_t));
	wchar_t* pResult = pBuf;

	out_len = ::MultiByteToWideChar(CP_UTF8, 0, in, len, pBuf, len * sizeof(wchar_t));
	out.assign( pResult, out_len );


	delete [] pResult;
	pResult = NULL;
}

static void Unicode_to_ANSI(const wchar_t* in, unsigned int len, std::string& out)
{
	int bufferlen = (int)::WideCharToMultiByte(CP_ACP,0,in,(int)len,NULL,0,NULL,NULL);
	char* pBuffer = new char[bufferlen + 4];
	if ( NULL == pBuffer )
	{
		return;
	}
	int out_len = ::WideCharToMultiByte(CP_ACP,0,in,(int)len,pBuffer,bufferlen+2,NULL,NULL);   
	pBuffer[bufferlen] = '\0';
	out.assign( pBuffer, out_len );
	delete[] pBuffer;
}

static void ANSI_to_Unicode(const char* in, unsigned int len, std::wstring& out)
{
	int wbufferlen = (int)::MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,in,(int)len,NULL,0);
	wchar_t* pwbuffer = new wchar_t[wbufferlen+4];
	if ( NULL == pwbuffer )
	{
		return;
	}
	wbufferlen = (int)::MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,in,(int)len,pwbuffer,wbufferlen+2);
	pwbuffer[wbufferlen] = '\0';
	out.assign( pwbuffer, wbufferlen );
	delete[] pwbuffer;
	return;
}


class logfile
{
public:
	static logfile* getlog(const char* filename){
		if(logcontain == NULL)
			logcontain = new logfile(filename);
		return logcontain;
	}
	static logfile* getlog(){
		if (logcontain == NULL){
			getlog(DEFAULT_FILE);
		}
		return logcontain;
	}

	bool WriteData(const wchar_t* data){
		std::string retv;
		Unicode_to_UTF8(data, ::wcslen(data),retv);
		fwrite(retv.c_str(), sizeof(char), retv.length(), f_handle);
		return true;

	}

	bool WriteData(const char* data){
		fwrite(data, sizeof(char), strlen(data), f_handle);
		return true;
	}

	bool WriteData(const std::string* data){
		fwrite(data->c_str(), sizeof(char), data->size(), f_handle);
		return true;
	}

	bool WriteData(const std::wstring* data){
		std::string retv;
		Unicode_to_UTF8(data->c_str(), data->length(),retv);
		fwrite(retv.c_str(), sizeof(char), retv.length(), f_handle);
		return true;
	}

protected:
	logfile(const char* filename){
		f_handle=fopen(filename,"a+");
		//assert(f_handle);
	}
	virtual ~logfile(){fclose(f_handle);};
private:
	static logfile* logcontain;
	FILE* f_handle;

};



template<typename _T>
struct HasToString{
	template<typename U, std::string (U::*)() const>
	struct match;
	template<typename U>
	static char helper(match<U, &U::ToString> *);
	template<typename U>
	static int helper(...);
	enum { value = sizeof(helper<_T>(NULL)) == 1 };
};
template<typename _T>
struct IsChar{
	static const bool Char = false;
};
template<>
struct IsChar<char *>{
	static const bool Char = true;
};
template<>
struct IsChar<const char *>{
	static const bool Char = true;
};

template<>
struct IsChar<wchar_t *>{
	static const bool Char = true;
};
template<>
struct IsChar<const wchar_t *>{
	static const bool Char = true;
};

template<bool, bool>
struct WriteLogPar
{
	template<typename _T>
	static bool toString(const _T &pv){
		logfile::getlog()->WriteData("Undefined Print\n");
		return false;
	}
};
template<>
struct WriteLogPar<true,false>
{
	template<typename _T>
	static bool toString(const _T &pv){
		logfile::getlog->WriteData(pv.ToString());    
		return true;
	}
};
template<>
struct WriteLogPar<false,true>
{
	template<typename _T>
	static bool toString(const _T &pv){
		logfile::getlog()->WriteData(pv);
		return true;
	}
};
template<typename _T>
inline bool WriteLog(_T &tvalue)
{
	return WriteLogPar<HasToString<_T>::value, IsChar<_T>::Char>::toString(tvalue);
}
template<>
inline bool WriteLog(LogString &tvalue)
{
	return WriteLogPar<false, true>::toString(tvalue.c_str());
}
template<>
inline bool WriteLog(LogString* &tvalue)
{
	return WriteLogPar<false, true>::toString(tvalue->c_str());
}

template<typename _T>
static bool ToString(const _T& data,int line, const char* file, const char* conv){
	//typedef _T value_type;
	//WriteLog(typeid(_T).name);
	WriteLog(data);
	WriteLog("\t");
	WriteLog(line);
	WriteLog("\t");
	WriteLog(file);
	WriteLog("\t");
	WriteLog(conv);
	return true;
}

static bool ToString(const char* data,int line, const char* file, const char* conv){
	//typedef _T value_type;
	//WriteLog(typeid(_T).name);
	WriteLog(data);
	logfile::getlog()->WriteData("\t\t\t"); 
	WriteLog(line);
	logfile::getlog()->WriteData("\t"); 
	WriteLog(file);
	logfile::getlog()->WriteData("\t"); 
	WriteLog(conv);
	return true;
}

static bool ToString(const TCHAR* data,int line, const char* file, const char* conv){
	//typedef _T value_type;
	//WriteLog(typeid(_T).name);
	WriteLog(data);
	logfile::getlog()->WriteData("\t\t\t"); 
	WriteLog(line);
	logfile::getlog()->WriteData("\t"); 
	WriteLog(file);
	logfile::getlog()->WriteData("\t"); 
	WriteLog(conv);
	return true;
}

#define WIRTELOG(data)	\
	ToString(data,	\
	__LINE__,\
	__FILE__,\
	"\r\n"\
	)

#endif // _LOG_H_