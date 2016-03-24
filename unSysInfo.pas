unit unSysInfo;

interface
uses windows,dialogs,sysUtils,Classes,Messages,Variants,Forms,Graphics;
type TWinVersion = (wvUnknown, wvWin95, wvWin98, wvWin98SE, wvWinNT, wvWinME, wvWin2000, wvWinXP, wvWinVista, wvWin7) ;

var
 VersionNames:array[0..9] of string = ('Unknown','Windows 95','Windows 98','Windows 98SE',
                                     'Windows NT','Windows Millenium','Windows 2000','Windows XP','Windows Vista','Windows 7');
 SystemCapacityNames:array[0..1] of string = ('32 bit','64 bit');
 function GetWindowsVersion:string;
 function GetModeCapacity:string;
 function getProcType(resStr:TStrings): String;
 function GetHardDiskPartitionType(const DriveLetter: Char): string;
 procedure GetMemoryStatus(memStat:TStrings);
 function DoScreenShot(AppName:string):TBitMap;
implementation
function DoScreenShot(AppName:string):TBitMap;
 var HW: HWND ;
     w,h : integer;
     DC : HDC;
     r : TRect;
     destBitmap:TBitMap;
 begin
  HW:=FindWindow(nil,PAnsiChar(AppName));
  if HW=0 then
   begin
    ShowMessage('Target application must be active');
    exit;
   end;
  SetForegroundWindow(HW);
  InvalidateRect(HW, nil, TRUE);
  UpdateWindow(HW);
  dc := GetWindowDC(HW) ;
  GetWindowRect(HW,r) ;
  w := r.Right - r.Left;
  h := r.Bottom - r.Top;
  try
   destBitmap:=TBitMap.Create;
   destBitmap.width := w;
   destBitmap.Height := h;
   BitBlt(destBitmap.Canvas.Handle,0,0,destBitmap.Width,destBitmap.Height,DC,0,0,SRCCOPY) ;
  finally
   ReleaseDC(HW, DC) ;
  end;
 result:=destBitmap;
end;

function GetWinVersion: TWinVersion;forward;
function IsWOW64: Boolean;forward;

procedure GetMemoryStatus(memStat:TStrings);
var MemoryStatus: TMemoryStatus;
function ToMB(arg:integer):integer;
  begin
   result:=(arg div 1024) div 1024;
  end;
 begin
  MemoryStatus.dwLength := SizeOf(MemoryStatus) ;
  GlobalMemoryStatus(MemoryStatus);
  with MemoryStatus do
   begin
     memStat.Add(IntToStr(dwMemoryLoad) +'% memory in use') ;
     memStat.Add(IntToStr(ToMb(dwTotalPhys)) +' Mb Total Physical Memory') ;
     memStat.Add(IntToStr(ToMb(dwAvailPhys)) +' Mb Available Physical Memory') ;
     memStat.Add(IntToStr(ToMb(dwTotalPageFile)) +' Mb Total Amount of Paging File') ;
     memStat.Add(IntToStr(ToMb(dwAvailPageFile)) +' Mb Available in paging file') ;
     memStat.Add(IntToStr(ToMb(dwTotalVirtual)) +' Mb User MBytes of Address space') ;
     memStat.Add(IntToStr(ToMb(dwAvailVirtual)) +' Mb Available User Mbytes of address space') ;
   end;
 end;
function GetHardDiskPartitionType(const DriveLetter: Char): string;
var
  NotUsed : DWORD;
  VolumeFlags : DWORD;
  VolumeInfo : array[0..MAX_PATH] of Char;
  VolumeSerialNumber : DWORD;
  PartitionType : array[0..32] of Char;
begin
  GetVolumeInformation(PChar(DriveLetter + ':\'),
    nil, SizeOf(VolumeInfo), @VolumeSerialNumber, NotUsed,
    VolumeFlags, PartitionType, 32);
  Result := PartitionType;
end;
 function GetModeCapacity:string;
  begin
   result:=SystemCapacityNames[ord(IsWOW64)];
  end;
function IsWOW64: Boolean;
type
  TIsWow64Process = function(
    Handle : THandle;
    var Res : BOOL
  ): BOOL; stdcall;
var
  IsWow64Result: BOOL;
  IsWow64Process: TIsWow64Process;
begin
  if GetWinVersion<wvWinXp then
    begin
     result:=false;
     exit;
    end;
  IsWow64Process := GetProcAddress(
    GetModuleHandle('kernel32'), 'IsWow64Process'
  );
  if Assigned(IsWow64Process) then
  begin
    if not IsWow64Process(GetCurrentProcess, IsWow64Result) then
      ShowMessage('Bad process handle');
    Result := IsWow64Result;
  end
  else
    Result := False;
end;


function getProcType(resStr:TStrings): String;
var
  _eax, _ebx, _ecx, _edx: Longword;
  i: Integer;
  b: Byte;
  b1: Word;
  s, s1, s2, s3, s_all: string;
  gn_speed_y: Integer;
  gn_text_y: Integer;

const
  gn_speed_x: Integer = 8;
  gn_text_x: Integer  = 15;
  gl_start: Boolean   = True;
 procedure info(s1,s2:string);
  begin
   resStr.Add(s1+s2);
  end;
begin
  asm                //asm call to the CPUID inst.
    mov eax,0         //sub. func call
    db $0F,$A2         //db $0F,$A2 = CPUID instruction
    mov _ebx,ebx
    mov _ecx,ecx
    mov _edx,edx
  end;
  for i := 0 to 3 do   //extract vendor id
  begin
    b := lo(_ebx);
    s := s + chr(b);
    b := lo(_ecx);
    s1:= s1 + chr(b);
    b := lo(_edx);
    s2:= s2 + chr(b);
    _ebx := _ebx shr 8;
    _ecx := _ecx shr 8;
    _edx := _edx shr 8;
  end;
  info('CPU', '');
  info('   - ' + 'Vendor ID: ', s + s2 + s1);
  asm
    mov eax,1
    db $0F,$A2
    mov _eax,eax
    mov _ebx,ebx
    mov _ecx,ecx
    mov _edx,edx
  end;
  b := lo(_eax) and 15;
  info('   - ' + 'Stepping ID: ', IntToStr(b));
  b := lo(_eax) shr 4;
  info('   - ' + 'Model Number: ', IntToHex(b, 1));
  b := hi(_eax) and 15;
  info('   - ' + 'Family Code: ', IntToStr(b));
  b := hi(_eax) shr 4;
  info('   - ' + 'Processor Type: ', IntToStr(b));
  //31.   28. 27.   24. 23.   20. 19.   16.
  //  0 0 0 0   0 0 0 0   0 0 0 0   0 0 0 0
  b := lo((_eax shr 16)) and 15;
  info('   - ' + 'Extended Model: ', IntToStr(b));
  b := lo((_eax shr 20));
  info('   - ' + 'Extended Family: ', IntToStr(b));
  b := lo(_ebx);
  info('   - ' + 'Brand ID: ', IntToStr(b));
  b := hi(_ebx);
  info('   - ' + 'Chunks: ', IntToStr(b));
  b := lo(_ebx shr 16);
  info('   - ' + 'Count: ', IntToStr(b));
  b := hi(_ebx shr 16);
  info('   - ' + 'APIC ID: ', IntToStr(b));
  //Bit 18 =? 1     //is serial number enabled?
  if (_edx and $40000) = $40000 then
    info('   - ' + 'Serial Number ', 'Enabled')
  else
    info('   - ' + 'Serial Number ', 'Disabled');
  s := IntToHex(_eax, 8);
  asm                  //determine the serial number
    mov eax,3
    db $0F,$A2
    mov _ecx,ecx
    mov _edx,edx
  end;
  s1 := IntToHex(_edx, 8);
  s2 := IntToHex(_ecx, 8);
  Insert('-', s, 5);
  Insert('-', s1, 5);
  Insert('-', s2, 5);
  info('   - ' + 'Serial Number: ', s + '-' + s1 + '-' + s2);
  asm
    mov eax,1
    db $0F,$A2
    mov _edx,edx
  end;
  info('', '');
  //Bit 23 =? 1
  if (_edx and $800000) = $800000 then
    info('MMX ', 'Supported')
  else 
    info('MMX ', 'Not Supported');
  //Bit 24 =? 1
  if (_edx and $01000000) = $01000000 then
    info('FXSAVE & FXRSTOR Instructions ', 'Supported')
  else 
    info('FXSAVE & FXRSTOR Instructions Not ', 'Supported');
  //Bit 25 =? 1
  if (_edx and $02000000) = $02000000 then
    info('SSE ', 'Supported')
  else 
    info('SSE ', 'Not Supported');
  //Bit 26 =? 1
  if (_edx and $04000000) = $04000000 then
    info('SSE2 ', 'Supported')
  else 
    info('SSE2 ', 'Not Supported');
  info('', '');
  asm     //execute the extended CPUID inst.
    mov eax,$80000000   //sub. func call
    db $0F,$A2
    mov _eax,eax
  end;
  if _eax > $80000000 then  //any other sub. funct avail. ?
  begin
    info('Extended CPUID: ', 'Supported');
    info('   - Largest Function Supported: ', IntToStr(_eax - $80000000));
    asm     //get brand ID
      mov eax,$80000002
      db $0F
      db $A2
      mov _eax,eax
      mov _ebx,ebx
      mov _ecx,ecx
      mov _edx,edx
    end;
    s  := '';
    s1 := '';
    s2 := '';
    s3 := '';
    for i := 0 to 3 do
    begin
      b := lo(_eax);
      s3:= s3 + chr(b);
      b := lo(_ebx);
      s := s + chr(b);
      b := lo(_ecx);
      s1 := s1 + chr(b);
      b := lo(_edx);
      s2 := s2 + chr(b);
      _eax := _eax shr 8;
      _ebx := _ebx shr 8;
      _ecx := _ecx shr 8;
      _edx := _edx shr 8;
    end;
    s_all := s3 + s + s1 + s2;
    asm
      mov eax,$80000003
      db $0F
      db $A2
      mov _eax,eax
      mov _ebx,ebx
      mov _ecx,ecx
    mov _edx,edx
    end;
    s  := '';
    s1 := '';
    s2 := '';
    s3 := '';
    for i := 0 to 3 do
    begin
      b := lo(_eax);
      s3 := s3 + chr(b);
      b := lo(_ebx);
      s := s + chr(b);
      b := lo(_ecx);
      s1 := s1 + chr(b);
      b := lo(_edx);
      s2 := s2 + chr(b);
      _eax := _eax shr 8;
      _ebx := _ebx shr 8;
      _ecx := _ecx shr 8;
      _edx := _edx shr 8;
    end;
    s_all := s_all + s3 + s + s1 + s2;
    asm
      mov eax,$80000004
      db $0F
      db $A2
      mov _eax,eax
      mov _ebx,ebx
      mov _ecx,ecx
      mov _edx,edx
    end;
    s  := '';
    s1 := '';
    s2 := '';
    s3 := '';
    for i := 0 to 3 do
    begin
      b  := lo(_eax);
      s3 := s3 + chr(b);
      b := lo(_ebx);
      s := s + chr(b);
      b := lo(_ecx);
      s1 := s1 + chr(b);
      b  := lo(_edx);
      s2 := s2 + chr(b);
      _eax := _eax shr 8;
      _ebx := _ebx shr 8;
      _ecx := _ecx shr 8;
      _edx := _edx shr 8;
    end;
    info('Brand String: ', '');
    if s2[Length(s2)] = #0 then setlength(s2, Length(s2) - 1);
    info('', '   - ' + s_all + s3 + s + s1 + s2);
  end
  else 
    info('   - Extended CPUID ', 'Not Supported.');
  result:='';
end;


function GetWindowsVersion:string;
  begin
   result:=VersionNames[ord(GetWinVersion)];
  end;
function GetWinVersion: TWinVersion;
var
   osVerInfo: TOSVersionInfo;
   majorVersion, minorVersion: Integer;
begin
   Result := wvUnknown;
   osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo) ;
   if GetVersionEx(osVerInfo) then
   begin
     minorVersion := osVerInfo.dwMinorVersion;
     majorVersion := osVerInfo.dwMajorVersion;
     case osVerInfo.dwPlatformId of
       VER_PLATFORM_WIN32_NT:
       begin
         if majorVersion <= 4 then
           Result := wvWinNT
         else if (majorVersion = 5) and (minorVersion = 0) then
           Result := wvWin2000
         else if (majorVersion = 5) and (minorVersion = 1) then
           Result := wvWinXP
         else if (majorVersion = 6) and (minorVersion = 0) then
           Result := wvWinVista
         else if (majorVersion = 6) and (minorVersion = 1) then
           Result := wvWin7;
       end;
       VER_PLATFORM_WIN32_WINDOWS:
       begin
         if (majorVersion = 4) and (minorVersion = 0) then
           Result := wvWin95
         else if (majorVersion = 4) and (minorVersion = 10) then
         begin
           if osVerInfo.szCSDVersion[1] = 'A' then
             Result := wvWin98SE
           else
             Result := wvWin98;
         end
         else if (majorVersion = 4) and (minorVersion = 90) then
           Result := wvWinME
         else
           Result := wvUnknown;
       end;
     end;
   end;
end;
end.
