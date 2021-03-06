# LogcatDLL_Python

### 목적
Android Logcat을 GUI 환경에서 편하게 관리하자.

### 구성
- Delphi 2010 (Form DLL)
- python 2.7 (DLL 호출 및 callback 설정)

~~~pascal
(*
   제목  : PyThon에서 DLL 호출
   작성자: 박성완(adsloader@naver.com)
   작성일: 2010.05.24
   목적  : 파이썬 DLL 호출예제
   참고  : Delphi2010에서 PChar은 WideString(wchar)이다.
*)
library PyDLLTest;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Dialogs,
  Classes,
  UiTest in 'UiTest.pas' {frmMain};

var
  f : TfrmMain;

{$R *.res}
type
  PyFunc = function(n : Integer; pData: PChar) : integer; stdcall;
  ParaData =  packed record
    func: PyFunc;
    desc: PChar;
  end;

function SetFunc( p : ParaData) :Integer ; stdcall;
begin

  f := TfrmMain.Create(Nil);
  f.pFunc := p.func;
  f.pFunc(1, 'start');

  result := 0;
end;

procedure AppendMessage( str : PChar; t: Integer); stdcall;
begin
  f.AppendMessage(str, t);
end;

procedure SetStatus( str : PChar); stdcall;
begin
  f.SetStatus(str);
end;

procedure DoEvent;
begin
  f.ShowModal();
end;

procedure CloseForm;
begin
  f.Close();
end;

exports
  SetFunc,
  AppendMessage,
  SetStatus,
  CloseForm,
  DoEvent;

begin
end.
~~~


python은 한글파일이 **반드시 cp949 인코딩** 이어어야 한다. 파일의 인코딩까지도...

~~~python
# -*- coding: cp949 -*-
#-------------------------------------------------------------------------------
# Name:        logcat 
# Purpose:     android logcat 정리 
#
# Author:      snake
#
# Created:     26/11/2011
# Copyright:   (c) snake 2011
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python
import sys
import os
import os.path
import zipfile
import stat
import re
from ctypes import *
import struct
import os, sys, re, StringIO
import ctypes
from ctypes import byref
from threading import Thread
import time
#---------------------------------------------------------
# callback Function(CFUNC로 하지 말아라..!!!)
WFUNC = WINFUNCTYPE(c_int, c_int, c_wchar_p)
#---------------------------------------------------------

tags = ["AlarmManager"]

# 비스타 버전 이상과 Delphi 2010에선 wchar를 기본으로 사용한다.
class ParaData(Structure):
    _fields_ = [
    ("func", WFUNC),
    ("name", c_wchar_p)
    ]
   
class Display(Thread):

    def SetState(self, b):
        self.b = b

     # tag filter
    def IsTagLooking(self, tag):
        if tags[0] in tag:
          return 1
          
        return 0  
   
    def setFunc(self, p):
        self.p = p 
    
    def setFunc2(self, p):
        self.p2 = p 
     
    def setFunc3(self, p):
        self.p3 = p 
    
    def WriteLog(self, str):
        f = open ("history", "a")
        f.write(str + "\r\n")
        f.close()
    
    def run(self):
        try:
            os.unlink("history")
        except:
            pass

        
        # 로그 clear
        input = os.popen("adb logcat -c")
        input = os.popen("adb logcat")
        
        self.p2("log capture를 시작했습니다")
        while self.b:
            try:
                line = input.readline()
                #print line 
            except KeyboardInterrupt:
                break
            
            if self.IsTagLooking(line) == 0:
                continue
            
            self.WriteLog(line [:-2])
            self.p( line [:-2]  , c_int(1) )
        
            # 입력 종료 
            if len(line) == 0: break
        
        self.p3()

        print """
        Program이 종료되었습니다.
        """

# Delphi 폼과 연결된 클래스
class DelphiForm():
    def __init__(self):
        self.pydll = windll.LoadLibrary("PyDLLTest.dll")
        self.p     = ParaData(WFUNC(self.OnCallBack), "파이썬 설정 : Callback" )
        
    def OnCallBack(self, n, pData):
        if n == 1:
            self.d = Display()
            self.d.SetState(True)
            self.d.setFunc(self.AddMessage) 
            self.d.setFunc2(self.SetMessage)
            self.d.setFunc3(self.CloseForm)
            self.d.start() 

        if n ==2:
            self.MakeLog() 

        if n== 3:
            indx = int(str(pData))
            cmd  = "adb install %s.apk" % self.list[indx]
            l = os.popen(cmd)
            l.close()
            
            l = os.popen("adb shell am start -a android.intent.action.MAIN -n %s/%s" % ( self.list[indx], self.activitylist[indx] ) )
            l.close()

        if n== 4:
            tags[0] = str(pData)
            print tags[0] + " changed."
            
        
        return 0

    def AddMessage(self, str, n = 1):
        self.pydll.AppendMessage( c_wchar_p( str ), n )
   
    def SetMessage(self, str):
        self.pydll.SetStatus( c_wchar_p( str ))
   
    def CloseForm(self):
        self.pydll.CloseForm()

    def DoEvent(self):
        self.pydll.SetFunc(self.p)
        self.pydll.DoEvent()

    def MakeLog(self):
        now     = time.localtime()
        strTime = "%d-%d-%d_%02d_%02d_%02d.txt" % (now.tm_year, now.tm_mon, now.tm_mday, now.tm_hour, now.tm_min, now.tm_sec)
        os.system('copy history %s' % strTime) 
        if os.path.exists(strTime):
            self.SetMessage("%s로 저장되었습니다" % strTime)
def main():
    f = DelphiForm()
    f.DoEvent()

if __name__ == '__main__':
    main()
~~~

### 실행

![](/data/logcat_gui.gif)
