unit settings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox,
  FMX.SpinBox, FMX.StdCtrls, FMX.Layouts;

type
  TSettingsPopup = class(TForm)
    SpinBox1: TSpinBox;
    FontLabel: TLabel;
    ScaledLayout1: TScaledLayout;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure SpinBox1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    NewFontSize: Single;
  end;

var
  SettingsPopup: TSettingsPopup;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

procedure TSettingsPopup.FormShow(Sender: TObject);
begin
    SpinBox1.SetFocus; //otherwise the form disappears on 1st click
end;

procedure TSettingsPopup.SpinBox1Change(Sender: TObject);
begin
    NewFontSize := SpinBox1.Value;
    FontLabel.TextSettings.Font.Size := SpinBox1.Value;

end;

end.
