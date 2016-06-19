unit UntFlowersFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GDIPAPI,GDIPOBJ, ExtCtrls;

type
  TTrFrom = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    m_Blend: BLENDFUNCTION;
    m_FAPPPath : string;
    m_hdcMemory: HDC;
    m_hdcScreen: HDC;
    hBMP: HBITMAP;
    sizeWindow: SIZE;
    rct: TRECT;
    ptSrc: TPOINT;
    m_ScreenW, m_ScreenH : Integer;
    m_FlowersCount : Integer;
    procedure SetTransparent();
    procedure DrawWindow(BackImgFile :string; nTran: integer);
    procedure wmnchittest(var msg:twmnchittest);message wm_nchittest; 
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DrawFlowers(g:TGPGraphics;aHDC : HDC);
    procedure WMLBUTTONUP(var msg:TWMLButtonUp);message WM_LButtonUp;
    procedure WMkillfocus(var msg: TWMKillFocus);message WM_killfocus;
  public
    constructor Create(AOwner: TComponent); reintroduce; override;
    destructor Destroy; reintroduce;
  end;

var
  TrFrom: TTrFrom;
  
implementation

uses UntForeGround;

{$R *.dfm}
{ TTrFrom }

constructor TTrFrom.Create(AOwner: TComponent);
begin
  inherited;
  m_ScreenW:=GetSystemMetrics(SM_CXSCREEN);
  m_ScreenH:=GetSystemMetrics(SM_CYSCREEN);
  Width := m_ScreenW;
  Height := m_ScreenH;
  Left := 0;
  Top := 0;
  m_FlowersCount := 44;
  m_FAPPPath := ExtractFilePath(Application.ExeName);
  m_Blend.BlendOp := AC_SRC_OVER; //   the   only   BlendOp   defined   in   Windows   2000
  m_Blend.BlendFlags := 0; //   Must   be   zero
  m_Blend.AlphaFormat := AC_SRC_ALPHA; //This   flag   is   set   when   the   bitmap   has   an   Alpha   channel
  m_Blend.SourceConstantAlpha := 255;
  SetTransparent();
  m_hdcScreen := GetDC(Self.Handle);
  m_hdcMemory := CreateCompatibleDC(m_hdcScreen);
  hBMP := CreateCompatibleBitmap(m_hdcScreen,m_ScreenW, m_ScreenH);
  SelectObject(m_hdcMemory, hBMP);
  GetWindowRect(Handle, rct);
//  DrawWindow(m_FAPPPath+'bg.png',100);
  Timer1.Enabled := True;
  Self.Icon.Handle := Application.Icon.Handle;
end;

procedure TTrFrom.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FindWindow('Shell_TrayWnd',nil);//GetDesktopWindow; // 重新定义Parent对象句柄
end;

destructor TTrFrom.Destroy;
begin
  ReleaseDC(0, m_hdcScreen);
  m_hdcScreen := 0;
  DeleteDC(m_hdcMemory);
  m_hdcMemory := 0;
  DeleteObject(hBMP);
   inherited Destroy;
end;

procedure TTrFrom.DrawFlowers(g: TGPGraphics; aHDC: HDC);
var
  img : TGPImage;
  rFile : string;
  rX,rY : Integer;
  resStream: TResourceStream;
  StreamAdapter : TStreamAdapter;
begin

  resStream := TResourceStream.Create(HInstance, Format('Flowers%d',[Random(m_FlowersCount)]), 'SkinPng');
  StreamAdapter := TStreamAdapter.Create(resStream);
  img := TGPImage.Create(StreamAdapter);

  rX := Random(m_ScreenW)-100;
  rY := Random(m_ScreenH)-100;
  g.DrawImage(img,rX,rY);
  img.Free;
  resStream.Free;
end;

procedure TTrFrom.DrawWindow(BackImgFile: string; nTran: integer);
var
  GPGraph: TGPGraphics;
  img : TGPImage;
begin
  GPGraph := TGPGraphics.Create(m_hdcMemory);
  GPGraph.SetSmoothingMode(SmoothingModeHighQuality);
  img := TGPImage.Create(BackImgFile);
//画出图片---------------------------
  //GPGraph.DrawImage(IMG, 0, 0);
  DrawFlowers(GPGraph,m_hdcMemory);
//----------------------------------
  sizeWindow.cx := m_ScreenW;
  sizeWindow.cy := m_ScreenH;
  ptSrc.x := 0;
  ptSrc.y := 0;

  UpdateLayeredWindow(Handle, m_hdcScreen, nil,@sizeWindow, m_hdcMemory, @ptSrc, 0, @m_Blend, ULW_ALPHA);

  GPGraph.ReleaseHDC(m_hdcMemory);
  GPGraph.Free;
  img.Free;
end;

procedure TTrFrom.SetTransparent();
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_TOOLWINDOW);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);
end;

procedure TTrFrom.wmnchittest(var msg: twmnchittest);
begin
  inherited;
end;

procedure TTrFrom.Timer1Timer(Sender: TObject);
begin
  DrawWindow(m_FAPPPath+'bg.png',100);
end;

procedure TTrFrom.WMLBUTTONUP(var msg: TWMLButtonUp);
begin
  close;
end;

procedure TTrFrom.FormDeactivate(Sender: TObject);
begin
 // close;
end;

procedure TTrFrom.WMkillfocus(var msg: TWMKillFocus);
begin
  //CLOSE;
end;

procedure TTrFrom.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := False;
  ForeGroundFrm.Show;
end;

procedure TTrFrom.FormShow(Sender: TObject);
begin
Timer2.Enabled := True;
end;

end.
