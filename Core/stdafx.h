// stdafx.h : ��׼ϵͳ�����ļ��İ����ļ���
// ���Ǿ���ʹ�õ��������ĵ�
// �ض�����Ŀ�İ����ļ�
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             //  �� Windows ͷ�ļ����ų�����ʹ�õ���Ϣ
// Windows ͷ�ļ�:
#include <windows.h>
#include <XLLuaRuntime.h>
#include <assert.h>
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <tchar.h>
#include <queue>
#include "bass.h"
#include "bassflac.h"
#include <mmsystem.h>
#pragma comment(lib, "winmm.lib")
#ifdef _UNICODE
#define LTSTRING std::wstring
#else
#define LTSTRING std::string
#endif


// TODO: �ڴ˴����ó�����Ҫ������ͷ�ļ�
