unit sorts;

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes,
    System.Variants, System.IOUtils,
    FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
    FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
    FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView, FMX.Layouts,
    FMX.Memo, FMX.ScrollBox, FMX.Memo.Types;

type
    Tsortform = class(TForm)
        ToolBar1: TToolBar;
        CustomList: TMemo;
        procedure FormCreate(Sender: TObject);
        procedure CustomListClick(Sender: TObject);
    private
        { Private declarations }
    public
        caretpos: integer;
    end;

var
    sortform: Tsortform;

implementation

{$R *.fmx}

procedure Tsortform.CustomListClick(Sender: TObject);
begin
    caretpos := caretpos + 1000;
    CustomList.CaretPosition := TCaretPosition.Create(caretpos, 0);
end;

procedure Tsortform.FormCreate(Sender: TObject);
var
    filenaam: string;
    myEncoding: TEncoding;
begin
    myEncoding := TEncoding.UTF8;
    filenaam := TPath.Combine(TPath.GetDocumentsPath, 'retrograde op lengte nl.txt');
    CustomList.Lines.LoadFromFile(filenaam, myEncoding);
end;

end.
