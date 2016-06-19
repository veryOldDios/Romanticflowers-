program Flowers;

{$R 'FlowersRc.res' 'FlowersRc.rc'}

uses
  Forms,
  UntFlowersFrm in 'UntFlowersFrm.pas' {TrFrom},
  UntForeGround in 'UntForeGround.pas' {ForeGroundFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTrFrom, TrFrom);
  Application.CreateForm(TForeGroundFrm, ForeGroundFrm);
  Application.Run;
end.
