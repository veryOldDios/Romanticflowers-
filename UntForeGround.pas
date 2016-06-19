unit UntForeGround;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,GDIPAPI,GDIPOBJ, pngimage, ExtCtrls, Math;
type
  TApple = record
     image : TGPImage;
     x,y,w,h : Integer;
     visiable : Boolean;
     drawTimes : Cardinal;
     Direction : Cardinal;
  end;
  TAppleList = array of TApple;
type
  tForeGroundFrm = class(TForm)
    FrameControl: TTimer;
    procedure FrameControlTimer(Sender: TObject);
  private
    m_Blend: BLENDFUNCTION;
    m_FAPPPath : string;
    FPictureFile: string;
    m_ScreenW, m_ScreenH : Integer;
    m_Frame : Cardinal;
    m_AppleList : TAppleList;
    procedure SetTransparent(nTran: integer);
    procedure DrawWindow(BackImgFile :string; nTran: integer);
    procedure DrawPic(g:TGPGraphics;AHDC:HDC);
    procedure wmnchittest(var msg:twmnchittest);message wm_nchittest; //这个代码是声明用的
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetPictureFile(const Value: string); //由于不是主窗口，置顶需要重载
  public
    constructor Create(AOwner: TComponent); reintroduce; override;
    destructor Destroy; reintroduce;
  published
    property PictureFile: string  read FPictureFile write SetPictureFile;
  end;

var
  ForeGroundFrm: tForeGroundFrm;

implementation

uses UntFlowersFrm;

{$R *.dfm}

{ TTransparentForm }

constructor tForeGroundFrm.Create(AOwner: TComponent);
var
  resStream: TResourceStream;
  StreamAdapter : TStreamAdapter;
  i : Integer;
  recname : string;
begin
  inherited;
  m_ScreenW:=GetSystemMetrics(SM_CXSCREEN);
  m_ScreenH:=GetSystemMetrics(SM_CYSCREEN);
  Width := m_ScreenW;
  Height := m_ScreenH;
  Left := 0;
  Top := 0;
  m_FAPPPath := ExtractFilePath(Application.ExeName);
  m_Frame := 0;
  m_Blend.BlendOp := AC_SRC_OVER; //   the   only   BlendOp   defined   in   Windows   2000
  m_Blend.BlendFlags := 0; //   Must   be   zero
  m_Blend.AlphaFormat := AC_SRC_ALPHA; //This   flag   is   set   when   the   bitmap   has   an   Alpha   channel
  m_Blend.SourceConstantAlpha := 255;
  SetTransparent(100);
  FPictureFile := 'apple\apple.png';
  {载入图片}
  SetLength(m_AppleList,24);
  for i:=0 to 22 do
  begin
    if i<10 then
      recname := '0'+IntToStr(i)
    else
      recname := IntToStr(i);
    resStream := TResourceStream.Create(HInstance, Format('apple%s',[recname]), 'SkinPng');
    StreamAdapter := TStreamAdapter.Create(resStream);
    m_AppleList[i].image := TGPImage.Create(StreamAdapter);
    m_AppleList[i].visiable := False;
    m_AppleList[i].x := 0;
    m_AppleList[i].y := 0;
    m_AppleList[i].w := m_AppleList[i].image.GetWidth;
    m_AppleList[i].h := m_AppleList[i].image.GetHeight;
    m_AppleList[i].drawTimes := 0;
    resStream.Free;
//    StreamAdapter.Free;
  end;
  {载入heart}
    resStream := TResourceStream.Create(HInstance, 'heart00', 'SkinPng');
    StreamAdapter := TStreamAdapter.Create(resStream);
    m_AppleList[23].image := TGPImage.Create(StreamAdapter);
    m_AppleList[23].visiable := False;
    m_AppleList[23].x := 0;
    m_AppleList[23].y := 0;
    m_AppleList[23].w := m_AppleList[i].image.GetWidth;
    m_AppleList[23].h := m_AppleList[i].image.GetHeight;
    m_AppleList[23].drawTimes := 0;
    resStream.Free;
  {载入完毕}
  FrameControl.Enabled := True;
  Self.Icon.Handle := Application.Icon.Handle;
end;

procedure tForeGroundFrm.CreateParams(var Params: TCreateParams);
begin
  inherited createparams(params);
  with params do
  begin
    Style := WS_POPUP or SW_HIDE;
    ExStyle := WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW;
    WndParent := TrFrom.Handle;
//窗体显示后怎么再次更改这个值WndParent？？？？
  end;

end;

destructor tForeGroundFrm.Destroy;
begin

end;

procedure tForeGroundFrm.DrawPic(g: TGPGraphics; AHDC: HDC);
var
  image : TGPImage;
  rect : TGPRectF;
begin
  case m_Frame of
    1:
    begin
      IF m_AppleList[23].drawTimes=0 then
      begin
        m_AppleList[23].Direction := Random(360);
      end;
      Inc(m_AppleList[23].drawTimes);
      rect := MakeRect(m_AppleList[23].x,m_AppleList[23].y+0.0,256,256);
      g.DrawImage(m_AppleList[23].image,rect,0,0,m_AppleList[23].w,m_AppleList[23].h,UnitPixel);
      if (m_AppleList[23].Direction in [0..45,135..225]) or ((m_AppleList[23].Direction>315) and (m_AppleList[23].Direction<360)) then
      begin
        if (m_AppleList[23].Direction in [0..45]) or ((m_AppleList[23].Direction>315) and (m_AppleList[23].Direction<360)) then
          Inc(m_AppleList[23].x,3)
        else
          Dec(m_AppleList[23].x,3);
      end  else
      begin
        if m_AppleList[23].Direction in [45..134] then
          Inc(m_AppleList[23].y,3)
        else
          Dec(m_AppleList[23].y,3);
      end;
      if m_AppleList[23].x<0 then
      begin
        m_AppleList[23].Direction := 90+Random(45);
        
      end else
      if m_AppleList[23].x>m_ScreenW-256 then
      begin
        m_AppleList[23].Direction := 135+Random(90);
      end else
      if m_AppleList[23].y<0 then
      begin
        m_AppleList[23].Direction := Random(180);
      end else
      if m_AppleList[23].y>m_ScreenH-256 then
      begin
        m_AppleList[23].Direction := 180+Random(180);
      end;
      if (m_AppleList[23].Direction in [0,45,90,135,180,225])  or (m_AppleList[23].Direction=270) or (m_AppleList[23].Direction=315) then
      begin
        Inc(m_AppleList[23].Direction);
      end else
      if (m_AppleList[23].Direction=360) then
        m_AppleList[23].Direction:=1;
      if (m_AppleList[23].Direction in [0..45,135..225]) or ((m_AppleList[23].Direction>315) and (m_AppleList[23].Direction<360)) then
      begin
        if (m_AppleList[23].Direction in [0..45,135..180] )then
          m_AppleList[23].y := m_AppleList[23].y + Round(3*tan(m_AppleList[23].Direction*pi/180))
        else
          m_AppleList[23].y := m_AppleList[23].y - Round(3*tan(m_AppleList[23].Direction*pi/180))
      end  else
      begin
        if (m_AppleList[23].Direction in [90..134]) or ((m_AppleList[23].Direction>225) and (m_AppleList[23].Direction<270)) then
          m_AppleList[23].x := m_AppleList[23].x - Round(3*tan(m_AppleList[23].Direction*pi/180))
        else
          m_AppleList[23].x := m_AppleList[23].x + Round(3*tan(m_AppleList[23].Direction*pi/180))
      end;
//      m_AppleList[23].y := Round(m_AppleList[23].x * tan(m_AppleList[23].Direction*pi/180));
      //m_AppleList[23].y := m_AppleList[23].y+Round(3*tan(m_AppleList[23].Direction*pi/180));
    end;
  end;
m_Frame := 1;
end;

procedure tForeGroundFrm.DrawWindow(BackImgFile: string; nTran: integer);
var
  GPGraph: TGPGraphics;
  hBMP: HBITMAP;
  sizeWindow: SIZE;
  rct: TRECT;
  ptSrc: TPOINT;

  m_hdcMemory: HDC;
  m_hdcScreen: HDC;
begin
  m_hdcScreen := GetDC(Self.Handle);
  m_hdcMemory := CreateCompatibleDC(m_hdcScreen);
  hBMP := CreateCompatibleBitmap(m_hdcScreen,self.Width, Self.Height);
  SelectObject(m_hdcMemory, hBMP);
  GetWindowRect(Handle, rct);
  GPGraph := TGPGraphics.Create(m_hdcMemory);
  GPGraph.SetSmoothingMode(SmoothingModeHighQuality);
//画出图片---------------------------
  DrawPic(GPGraph,m_hdcMemory);
//----------------------------------
  sizeWindow.cx := self.Width;
  sizeWindow.cy := Self.Height;
  ptSrc.x := 0;
  ptSrc.y := 0;

  UpdateLayeredWindow(Handle, m_hdcScreen, nil,@sizeWindow, m_hdcMemory, @ptSrc, 0, @m_Blend, ULW_ALPHA);

  GPGraph.ReleaseHDC(m_hdcMemory);
  ReleaseDC(0, m_hdcScreen);
  m_hdcScreen := 0;
  DeleteObject(hBMP);
  DeleteDC(m_hdcMemory);
  m_hdcMemory := 0;
  GPGraph.Free;
end;

procedure tForeGroundFrm.SetPictureFile(const Value: string);
begin
  FPictureFile := Value;
  Invalidate;
end;

procedure tForeGroundFrm.SetTransparent(nTran: integer);
begin
    //   Alpha   Value
  if (nTran < 0) or (nTran > 100) then
    nTran := 100;
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_TOOLWINDOW);
end;

procedure tForeGroundFrm.wmnchittest(var msg: twmnchittest);
begin
  inherited;
  if Msg.Result = HTClient then
    Msg.Result := HTCaption;
end;

procedure tForeGroundFrm.FrameControlTimer(Sender: TObject);
begin
DrawWindow('',100);
end;

end.
