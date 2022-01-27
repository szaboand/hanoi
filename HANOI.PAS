{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+}
{$M 32768,0,655360}
Program Hanoi;
{*****************************************************************************
******************************************************************************
*                        Hanoi 2.0b Beta Verzi¢                              *
*                       1998.05.27. - 1998.11.27.                            *
*                       (P) Szab¢ Andr†s 1984-98                             *
******************************************************************************
*****************************************************************************}


Uses TWSys{V1.1a},TObject{V4.1d},TObjects{V4.1d};

{****************************************************************************}
{***                             T°pusok                                  ***}
{****************************************************************************}


{****************************************************************************}
{***                              Konstansok                              ***}
{****************************************************************************}

Const
 VMode                 :  word    = _640x480_256;   { Vide¢m¢d k¢dja         }
 ProgramName           :  string  = 'Hanoi torony 2.0 (C) Szab¢ Andr†s 1998';
 Info1                 :  string  = 'e-mail:szaboand@mail.petrik.mumszki.hu';

 MDVX                  :  word         = $0003;  { Mouse X oszt†sar†ny (SHR) }
 MDVY                  :  word         = $0003;  { Mouse X oszt†sar†ny (SHR) }
 PixRat                :  word         = $0001;  { Mouse Pixel/Ratio         }
 MouseAct              :  boolean      = TRUE;   { Saj†t mouse megjelen°tÇs  }

 BackgroundColor       :  byte    = $07;         { H†ttÇrszin                }
 DBackgroundColor      :  byte    = $08;         { SîtÇt h†ttÇrszin          }
 DDBackgroundColor     :  byte    = $00;         { SîtÇt h†ttÇrszin          }
 LBackgroundColor      :  byte    = $0F;         { Vil†gos h†ttÇrszin        }
 InfoTextColor         :  byte    = $0F;         { Info textszin             }
 DInfoTextColor        :  byte    = $08;         { SîtÇt info textszin       }
 TimeTextColor         :  byte    = $08;         { Idã textsz°n              }

 _SystemExitButtonCode            = $0001;       { Command k¢dok             }
 _GoOnButtonCode                  = $0002;       { Command k¢dok             }
 _StepButtonCode                  = $0003;       { Command k¢dok             }
 _IncButtonCode                   = $0004;       { Command k¢dok             }
 _DecButtonCode                   = $0005;       { Command k¢dok             }
 _NewButtonCode                   = $0006;       { Command k¢dok             }
 _InfoButtonCode                  = $0007;       { Command k¢dok             }

 _SystemExitButtonString          = '   KilÇp   ';{ Exit Button felirat      }
 _GoOnButtonString                = 'Start';     { GoOn Button felirat       }
 _StepButtonString                = 'LÇpÇs';     { Step Button felirat       }
 _IncButtonString                 = 'Lass°t';    { Inc Button felirat        }
 _DecButtonString                 = 'Gyors°t';   { Dec Button felirat        }
 _NewButtonString                 = '    Èj    ';{ New Button felirat        }
 _InfoButtonString                = 'Info';      { Info Button felirat       }

 MaxKorongSzeles                  = 80;          { Max. korongszÇlessÇg      }
 RudMagas                         = 300;         { R£d magass†ga             }
 RudSzeles                        = 10;          { R£d szÇlessÇge            }
 MaxKorongSzam                    = 64;          { Max. korongsz†m           }
 KorongSzam            : word     = 16;           { Korongok sz†ma            }
 EndProgram            : byte     = 0;           { KilÇpÇs jelzi             }
 StopProgram           : boolean  = True;        { µllj                      }
 Ready                 : boolean  = True;        { Fut†sra kÇsz jelzã        }

 ByStep                : boolean  = False;       { LÇpÇsenkÇnti vÇgrehajt†s  }
 MaxWaitTime                      = 42;
 WaitTime              : word     = 5;           { V†rakoz†s                 }

 KorongSzinek          : array [1..MaxKorongSzam] of byte =
                         ( 1,2,3,4,5,6,9,10,11,12,13,14,15,45,30,
                           16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
                           16,17,34,35,36,37,38,39,40,41,42,43,44,45,46,
                           31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,

                           61,62,63,64);

{****************************************************************************}
{***                          Objektumok                                  ***}
{****************************************************************************}

Type

 MyButtonType   = object(ButtonType)
  Procedure DoButton;virtual;
  Procedure SetInit;virtual;
 end;

 MyCButtonType   = object(CButtonType)
  Procedure DoCButton;virtual;
 end;

 TimeType       = object(TextType)
  WT           : word;
  Constructor  Init(IDd,XX,YY:word);
  Procedure    SetInit;virtual;
  Procedure    Draw;virtual;
  Procedure    Timer;virtual;
 end;

 RudType        = object
  X,Y           : word;                          { Rud X,Y pozici¢           }
  Szeles        : word;                          { Rudak szÇlessÇge          }
  Magas         : word;                          { Rud magass†ga             }
  Szin          : byte;                          { Rud szine                 }
  RudPos        : array [1..MaxKorongSzam] of word; { KorongPozici¢k         }
  KorongNum     : word;                          { KorongSzam                }
  KorongSzeles  : word;                          { LegszÇlesebb korong       }
  KorongMagas   : word;                          { Korong magass†g           }
  KorongKoz     : word;                          { Az korongok kÅlînbsÇge    }
  Procedure Init(XX,YY:word;C,K,F:byte);         { Inicializ†l†s             }
  Procedure Draw;                                { Rajzol†s                  }
  Function  LeKorong:word;                       { Korong levÇtele           }
  Procedure FelKorong(k:word);                   { Korong felrak†sa          }
 end;


{****************************************************************************}
{***                               V†ltoz¢k                               ***}
{****************************************************************************}

Var
 ExitButton           : MyButtonType;
 GoOnButton           : MyButtonType;
 StepButton           : MyButtonType;
 IncButton            : MyButtonType;
 DecButton            : MyButtonType;
 NewButton            : MyButtonType;
 InfoButton           : MyButtonType;
 TimeText             : TimeType;
 StepCButton          : MyCButtonType;

 CommandCode          : word;

 Rud                  : array [1..3] of RudType;

{****************************************************************************}
{***                    MyButtonType objektum met¢dusai                   ***}
{****************************************************************************}

Procedure MyButtonType.DoButton;
Begin
CommandCode:=ID;
End;

Procedure MyButtonType.SetInit;
Begin
Case ID of
     _SystemExitButtonCode : begin Group:=1;DX:=DX+2;end;
     _IncButtonCode        : begin DX:=DX+8;TX:=TX+4;end;
     _NewButtonCode        : begin DX:=DX+8;TX:=TX+4;end;
     _InfoButtonCode       : begin DX:=80;DY:=72;TX:=24;TY:=32;end;
     end;
End;

{****************************************************************************}
{***                         TimeType objektum met¢dusai                  ***}
{****************************************************************************}

Constructor TimeType.Init(IDd,XX,YY:word);
Begin
Inherited Init(IDd,XX,YY,11,2,nil);
End;

Procedure TimeType.SetInit;
Begin
Chars:=1;LineSpace:=1;DY:=CDY*(8+LineSpace);
TextColor:=TimeTextColor;TextBackColor:=BackgroundColor;
End;

Procedure TimeType.Timer;
Begin
If WT>0 then Dec(WT);
Draw;
End;

Procedure TimeType.Draw;
var t:string;tt:^byte;mh:boolean;
Begin
T:='HU-B '+GetTimeStr(0);
T:=T+chr(10)+GetDateStr(false)+chr(0);
TT:=@T;Inc(TT);TextPointer:=TT;mh:=false;
If (GetMouseX<X+DX+16) and (GetMouseY+16>Y) then begin mh:=true;MouseHide;end;
Inherited Draw;If MH then MouseShow;
End;

{****************************************************************************}
{***                       CButtonType objektum met¢dusai                 ***}
{****************************************************************************}

Procedure MyCButtonType.DoCButton;
Begin
If ByStep
      then begin
           StepButton.Off;GoOnButton.On;NewButton.Off;
           IncButton.On;DecButton.On;
           end
      else begin
           StepButton.On;GoOnButton.Off;If not Ready then NewButton.On;
           IncButton.Off;DecButton.Off;
           end;
ByStep:=not ByStep;
End;

{****************************************************************************}
{***                         RudType objektum met¢dusai                   ***}
{****************************************************************************}

Procedure RudType.Init(XX,YY:word;C,K,F:byte);
var i:word;
Begin
X:=XX;Y:=YY;Szeles:=RudSzeles;Szin:=C;
For I:=1 to K do If F>0 then RudPos[I]:=I else RudPos[I]:=0;
If F>0 then KorongNum:=K else KorongNum:=0;
KorongMagas:=RudMagas div (K+1);KorongSzeles:=80;
Magas:=(KorongMagas+1)*K+10;KorongKoz:=KorongSzeles div (K+1);
Draw;
End;

Procedure RudType.Draw;
var i,YY:word;KK:word;
Begin
SetColor(Szin);
Bar(X-Szeles div 2-2,Y+3,X+Szeles div 2+2,Y);
Bar(X-Szeles div 2,Y,X+Szeles div 2,Y-Magas);
For I:=1 to Szeles div 2
    do Bar(X-Szeles div 2+I,Y-I-Magas,X+Szeles div 2-I,Y-1-Magas);
I:=1;YY:=Y;KK:=KorongSzeles;
If KorongNum>0
   then while I<=KorongNum do
              begin
              SetColor(KorongSzinek[RudPos[I]]);
              Bar(X-KK div 2,YY,X+KK div 2,YY-KorongMagas);
              YY:=YY-KorongMagas-1;KK:=KK-KorongKoz;
              Inc(I);
              end
   else while I<=KorongSzam do
              begin
              SetColor(BackGroundColor);
              Bar(X-KK div 2,YY,X-RudSzeles div 2-1,YY-KorongMagas);
              Bar(X+RudSzeles div 2+1,YY,X+KK div 2,YY-KorongMagas);
              YY:=YY-KorongMagas-1;
              Inc(I);
              end
End;

Function RudType.LeKorong:word;
var D,YY,KK:word;
Begin
D:=RudPos[KorongNum];Dec(KorongNum);
YY:=Y-KorongNum*(KorongMagas+1);KK:=KorongSzeles;
SetColor(BackGroundColor);
Bar(X-KK div 2,YY,X-RudSzeles div 2-1,YY-KorongMagas);
Bar(X+RudSzeles div 2+1,YY,X+KK div 2,YY-KorongMagas);
SetColor(Szin);Bar(X-RudSzeles div 2,YY,X+RudSzeles div 2,YY-KorongMagas);
LeKorong:=D;
End;

Procedure RudType.FelKorong(k:word);
var YY,KK:word;
Begin
YY:=Y-KorongNum*(KorongMagas+1);
Inc(KorongNum);RudPos[KorongNum]:=k;
KK:=KorongSzeles-k*KorongKoz;
SetColor(KorongSzinek[K]);
Bar(X-KK div 2,YY,X+KK div 2,YY-KorongMagas);
End;

{****************************************************************************}
{***                              ShowWTime                               ***}
{****************************************************************************}

Procedure ShowWTime;
var I,J:word;
Begin
MouseHide;
SetColor(1);J:=GetMaxX-342;
For I:=1 to MaxWaitTime-WaitTime+1 do
    begin
    Bar(J,70,J+1,80);J:=J+3;
    end;
SetColor(BackGroundColor);Bar(J,70,J+1,80);
MouseShow;
End;

{****************************************************************************}
{***                              Info                                    ***}
{****************************************************************************}

Procedure Info;
Begin
End;

{****************************************************************************}
{***                            CommandProcess                            ***}
{****************************************************************************}

Procedure CommandProcess;
Begin
Case CommandCode of
     _IncButtonCode : If WaitTime<MaxWaitTime then begin Inc(WaitTime);ShowWTime;end;
     _DecButtonCode : If WaitTime>1 then begin Dec(WaitTime);ShowWTime;end;
     _InfoButtonCode: Info;
     end;
CommandCode:=0;
End;


{****************************************************************************}
{***                         HanioEnd                                     ***}
{****************************************************************************}

Procedure HanoiEnd;
var C:CommandType;
Begin
IncButton.Off;DecButton.Off;
StepButton.Off;GoOnButton.Off;StepCButton.Off;NewButton.On;
ClearCommandPuffer;CommandCode:=0;
repeat
      repeat If GetCommand(C)<>0 then TObjectProcess(C) until CommandCode<>0;
      Case CommandCode of
           _InfoButtonCode : CommandProcess;
           end;
until CommandCode<>0;
IncButton.On;DecButton.On;StepCButton.On;NewButton.Off;
If ByStep then StepButton.On else GoOnButton.On;
End;

{****************************************************************************}
{***                           Hanoi elj†r†s                              ***}
{****************************************************************************}

Procedure HanoiInit(Kszam:word);
var I:word;
Begin
Rud[1].Init(GetMaxX div 6,GetMaxY-35,14,KSzam,1);
Rud[2].Init(3*GetMaxX div 6,GetMaxY-35,4,KSzam,0);
Rud[3].Init(5*GetMaxX div 6,GetMaxY-35,1,KSzam,0);
End;

Procedure Athelyez(A,B:integer);
var C:CommandType;
Begin
Rud[B].FelKorong(Rud[A].LeKorong);
CommandCode:=0;TimeText.WT:=WaitTime;
Repeat
 If GetCommand(C)<>0 then TObjectProcess(C);
 Case CommandCode of
     _IncButtonCode,
     _DecButtonCode,
     _InfoButtonCode   : CommandProcess;
     _GoOnButtonCode       : begin
                             with GoOnButton do
                                  begin
                                  If StopProgram
                                     then begin BText:='Stop';TX:=9;NewButton.Off;end
                                     else begin BText:='Start';TX:=5;NewButton.On;end;
                                  Flag:=Flag or C_TObjectReDrawFlag;Draw;
                                  end;
                             StopProgram:=not StopProgram;CommandCode:=0;
                             end;
     end;
Until (CommandCode<>0) or ((not ByStep) and (TimeText.WT=0) and (not StopProgram))
      or (Rud[3].KorongNum=KorongSzam);
Case CommandCode of
     _SystemExitButtonCode : EndProgram:=1;
     _NewButtonCode        : EndProgram:=2;
     end;
End;

Procedure HanoiRek(n:integer;a,c,b:shortint);
Begin
If EndProgram<>0 then Exit;
if n=1 then Athelyez(a,b)
       else begin
            If EndProgram<>0 then Exit else HanoiRek(n-1,a,b,c);
            If EndProgram<>0 then Exit else Athelyez(a,b);
            If EndProgram<>0 then Exit else HanoiRek(n-1,c,a,b);
            end;
end;

{****************************************************************************}
{***              KÇpernyã/EgÇr inicializ†l†s Çs lez†r†s                  ***}
{****************************************************************************}

Function Init_Video:byte;
Var J,I:word;
Begin
If SetGraphMode(VMode)<>0 then begin Init_Video:=1;Exit;end;
SetRGBReg(7,32,32,32);SetRGBReg(15,48,48,48);
ClearScreen(BackGroundColor);
SetColor(BackGroundColor);Bar(0,GetMaxY-26,GetMaxX-1,GetMaxY-1);
SetColor(DBackGroundColor);Line(0,GetMaxY-27,GetMaxX-1,GetMaxY-27);
SetColor(DDBackGroundColor);Line(0,GetMaxY-28,GetMaxX-1,GetMaxY-28);
BorderDraw_2b(2,GetMaxY-25,90,18,BackGroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_3(GetMaxX-352,2,142,88,BackGroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_3(GetMaxX-204,2,198,88,BackGroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_2b(GetMaxX-346,66,130,14,BackGroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_3(1,2,GetMaxX-358,88,BackGroundColor,DBackGroundColor,LBackGroundColor);
Init_Video:=0;
End;

Function Init_Mouse:byte;
Begin
If MouseInit(MouseAct,PixRat,MDVX,MDVY)=0
   then Init_Mouse:=1
   else begin Init_Mouse:=0;MouseShow;end;
SetMousePos(GetMaxX div 2,GetMaxY-17);
{SetMouseArea(96,GetMaxY-32,GetMaxX-1,GetMaxY);}
End;

Procedure VideoDone;
Begin
Asm mov  ax,0003h;int 10h End;
WriteLn(ProgramName);
End;

{****************************************************************************}
{***                  Objektumok inicializ†l†sa/lez†r†sa                  ***}
{****************************************************************************}

Procedure ObjectInit;
Begin
GoOnButton.Init(_GoOnButtonCode,GetMaxX-56,38,_GoOnButtonString);
ExitButton.Init(_SystemExitButtonCode,GetMaxX-106,12,_SystemExitButtonString);
StepButton.Init(_StepButtonCode,GetMaxX-106,38,_StepButtonString);
StepButton.Off;
DecButton.Init(_DecButtonCode,GetMaxX-276,38,_DecButtonString);
IncButton.Init(_IncButtonCode,GetMaxX-344,38,_IncButtonString);
TimeText.Init(0,6,GetMaxY-21);SetTimer(1,1,0,0,Seg(TimeText),Ofs(TimeText));
StepCButton.Init(0,GetMaxX-330,12,'LÇpÇsenkÇnt');
StepCButton.CBFlag:=StepCButton.CBFlag or 1;
NewButton.Init(_NewButtonCode,GetMaxX-106,64,_NewButtonString);NewButton.Off;
InfoButton.Init(_InfoButtonCode,GetMaxX-196,12,_InfoButtonString);
End;

Procedure ObjectDone;
var i,j:word;
Begin
SetTimer(1,0,0,0,0,0);
InfoButton.Done;
NewButton.Done;
StepCButton.Done;
TimeText.Done;
IncButton.Done;
DecButton.Done;
StepButton.Done;
ExitButton.Done;
GoOnButton.Done;
End;

{****************************************************************************}
{***                   Inicializ†l†s/lez†r†sok                            ***}
{****************************************************************************}

Procedure Init;
Begin
If Init_Video<>0
   then begin WriteLn('Nem sikerÅlt a videom¢d inicializ†l†sa!');Halt;end;
Init_Mouse;
ObjectInit;
HanoiInit(KorongSzam);
End;

Procedure Done;
Begin
ObjectDone;
VideoDone;
End;

{****************************************************************************}
{***                               Fãprogram                              ***}
{****************************************************************************}

Procedure Main;
var C:CommandType;J:word;
Begin
ClearCommandPuffer;J:=1;
repeat
      Case J of
           1 : begin
               CommandCode:=0;NewButton.Off;
               EndProgram:=0;HanoiInit(KorongSzam);Ready:=True;
               {IncButton.Off;DecButton.Off;}ShowWTime;
               end;
           2 : repeat
                     repeat If GetCommand(C)<>0 then TObjectProcess(C) until CommandCode<>0;
                     Case CommandCode of
                               _IncButtonCode,
                               _DecButtonCode,
                               _InfoButtonCode   : CommandProcess;
                          end;
               until CommandCode<>0;
           3 : begin
               with GoOnButton do
                    begin
                    BText:='Stop';TX:=9;
                    Flag:=Flag or C_TObjectReDrawFlag;Draw;
                    end;
               If ByStep
                  then begin
                       NewButton.On;
                       StepButton.On;GoOnButton.Off;
                       StepButton.SetKeyFocus;
                       end
                  else begin IncButton.On;DecButton.On;end;
               StopProgram:=False;Ready:=False;
               HanoiRek(KorongSzam,1,2,3);
               end;
           4 : begin
               StopProgram:=True;
               If EndProgram=0 then HanoiEnd;
               end;
           5 : with GoOnButton do
                    begin
                    BText:='Start';TX:=5;
                    Flag:=Flag or C_TObjectReDrawFlag;
                    Draw;
                    end;
           end;
      Inc(J);
until CommandCode=_SystemExitButtonCode;
End;


{****************************************************************************}
{****************************************************************************}
{****************************************************************************}

BEGIN
Init;
TProcOn;
Main;
TProcOff;
Done;
END.