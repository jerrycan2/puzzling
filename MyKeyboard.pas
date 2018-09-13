//customizable keyboard form.
unit MyKeyboard; // max rows/cols: KEYBOARDMATRIXMAX = 256

interface

uses
    System.Classes, System.Types, System.UITypes, System.SysUtils, System.Character,
    FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.Types, FMX.Controls,
    FMX.Effects, FMX.Dialogs, FMX.Edit, FMX.Memo, FMX.Layouts, FMX.Graphics, FMX.Styles,
    FMX.ImgList, FMX.colors; // , normalizer;

type
    TKeyBoardData = TArray<String>;
    TKeyBoardSet = TArray<TKeyBoardData>;
    TKeyType = (ktNormal = Ord('a'), ktEnter, ktSpace, ktShift, ktCtrl, ktAlt, ktSym, ktSwitch, ktDone, ktEsc, ktDel,
      ktBack, ktFunction, ktLeft, ktRight, ktUp, ktDown, ktNonSpacing, ktIgnoreKey);

    TOnClickEvent = procedure(Sender: TObject; var Key: char; KeyCode: integer; var KeyType: TKeyType) of object;
    TSetTarget = procedure(obj: TObject) of object;

    TKeyBoardInfo = record
        KeyBoard: TKeyBoardSet; // all keyboards in the array must have the same nr and type of keys
        FontSize: single;
        KeyHeight: single;
        KeyWidth: single;
        FGcolor, BGcolor, KeyColor: TAlphaColor;
        Keymargin, Rowmargin: integer;
        KeyAlign: TAlignLayout;
        RowAlign: TAlignLayout;
        KeyStyle: string;
        ImageList: TImageList;
    end;

    TKeyBoardKey = class(TSpeedButton)
    public
        FKeyValue: char;
        FKeyType: TKeyType;
        FKeyCode: integer; // row * 256 + column; for reverse identification
        constructor create(AOwner: TComponent; KeyStyle: string = ''); reintroduce;
        //procedure ApplyKeyStyle(Sender: TObject);
    end;


 // TRectangle based so you can easily change fill or stroke
    TMyKeyBoard = class(TRectangle)
    private
        FKeys: array of array of TKeyBoardKey; // array[length(kbKeyValues), max(kbKeyValues string lengths)]
        FKeyBoard: TKeyBoardSet;
        FEffect: TEffect;
        FTarget: TObject;
        FShiftKeyPtr: TKeyBoardKey; // ref to shiftkey for easy access
        FImageList: TImageList;
        FOwner: TControl;
        Fis_rtl: boolean;
        FMaxHeight: single;
        procedure MyKeyClick(Sender: TObject); // get value from keyboardkey
        procedure MyKeyMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: single);
        procedure MyKeyMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: single);
        procedure CreateKeyBoardKeys(const KeyBoardInfo: TKeyBoardInfo);
        procedure ReadKeyValues(const KeyBoardInfo: TKeyBoardInfo; keyboardindex: integer);
    public
        constructor create(AOwner: TControl; const KeyBoardInfo: TKeyBoardInfo); reintroduce;
        Destructor  Destroy; override;
        procedure ClearKeys;
        procedure setRTLmode(is_rtl: boolean);
        procedure disableKey(keycode: integer; is_enabled: boolean);
        function GetHeight: single;
        procedure SetTarget(obj: TObject);
        procedure ReadKeyTypes(KeyBoardInfo: TKeyBoardInfo; keyboardindex: integer);
        function getCurrTarget: TObject;
    var
        OnKeyClick: TOnClickEvent;

    var
        kbSetTarget: TSetTarget;
        // procedure AddKeyBoardState(KeyValues: array of string);
        // function GetKeyObj(KeyCode: integer): TKeyBoardKey;
    end;

const
{$IFDEF MSWINDOWS}
    STRINGSTART = 1;
{$ELSE}
    STRINGSTART = 0; // for string indexing
{$ENDIF}
    KEYBOARDMATRIXMAX = 256; // max 256 * 256 keys

    { key types:  (see TKeyType)
      a normal   g sym      m function
      b enter    h switch   n left
      c space    i done     o right
      d shift    j esc      p up
      e ctrl     k del      q down
      f alt      l back     r nonspacing

      key type, key value, shift val in corresponding position in 3 sets of strings
      if key type = a (ktNormal), key value is in KB1, shifted value in KB1SHIFT
      if key type <> a, the corresponding value of KB1 and KB1SHIFT is ignored.
      The numbers following the letters in types indicate the size of the key.
      (multiples  of the width of a single key). So c3 means a spacebar, 3 keys wide.
      Each key type <> a can have an image (from imagelist) or a string displayed.
      The rows do not have to be equal length. They are centered by creating margins.

      A keyboard has N languages, each language has an alfanumeric and a symbol display,
      each display has a normal and a shift value;

    }

implementation

// uses IEMain;
// *****************************************************************
// ************************KeyBoardKey******************************
// *****************************************************************

constructor TKeyBoardKey.create(AOwner: TComponent; KeyStyle: string = '');
var
    obj: TFMXObject;
begin
    Inherited create(AOwner);
    Parent := TFMXObject(AOwner); // create key
    if KeyStyle <> '' then
    begin
        ControlType := FMX.Controls.TControlType.Platform;
        Self.StyleLookup := KeyStyle;
//        Self.OnApplyStyleLookup := ApplyKeyStyle;
        ApplyStyle;
    end;
    Width := 48;
    Height := 32;
    OnClick := TMyKeyBoard(Parent).MyKeyClick;
end;

// *****************************************************************
// **************************MyKeyBoard*****************************
// *****************************************************************

function sumrow(const s: string): integer;
var
    i: integer;
begin
    Result := 0;
    for i := Low(s) to High(s) do inc(Result, StrToInt(s[i]));
end;

// iterates through the types array to get length of longest row
function getmax(const arr: array of string): integer;
var
    n, largest, sum: integer;
begin
    largest := sumrow(arr[0]); // no error check
    if Length(arr) > 1 then
        for n := 1 to High(arr) do
        begin
            sum := sumrow(arr[n]);
            if sum > largest then largest := sum;
        end;
    Result := largest;
end;

constructor TMyKeyBoard.create(AOwner: TControl; const KeyBoardInfo: TKeyBoardInfo);
var
    len, rows, maxlen: integer;
    Types: TKeyBoardData;
    rect: TFMXObject;
begin
    Inherited create(AOwner); // create TRectangle
    FOwner := AOwner;
    Visible := True;
    Parent := TFMXObject(AOwner);
    Align := TAlignLayout.Client;
    Name := 'kb1';
    kbSetTarget := SetTarget;
    Types := KeyBoardInfo.KeyBoard[0]; // create first (default) keyboard
    maxlen := getmax(Types);
    rows := Length(Types); // array length of one keyboardconf = nr of rows
    BoundsRect := TRectF.create(0, 0, AOwner.Width, rows * (KeyBoardInfo.KeyHeight + KeyBoardInfo.Rowmargin));
    FEffect := TInnerGlowEffect.create(Self);
    FTarget := nil;
    FMaxHeight := rows * KeyBoardInfo.KeyHeight + (rows + 1) * KeyBoardInfo.Keymargin;

    AOwner.Height := FMaxHeight;
//    FImageList := KeyBoardInfo.ImageList;
    CreateKeyBoardKeys(KeyBoardInfo);
    ReadKeyTypes(KeyBoardInfo, 1);
    ReadKeyValues(KeyBoardInfo, 2);
end;

destructor TMyKeyBoard.Destroy;
begin
    ClearKeys;
    Inherited;
end;

procedure TMyKeyBoard.setRTLmode(is_rtl: boolean);
begin
    Fis_rtl := is_rtl;//true = right to left, false = left to right
end;

procedure TMyKeyBoard.ClearKeys;
var
    i, j: integer;
begin
    for i := 0 to High(FKeys) do
    begin
        for j := 0 to High(FKeys[i]) do
        begin
            FreeAndNil(FKeys[i, j]);
        end;
    end;
end;

function TMyKeyBoard.getCurrTarget: TObject;
begin
    Result := Self.FTarget;
end;

function TMyKeyBoard.GetHeight: single;
begin
    Result := FMaxHeight;
end;

procedure TMyKeyBoard.disableKey(keycode: integer; is_enabled: boolean);
var
    row, keynr: integer;
begin
    row := keycode div 256;
    keynr := keycode mod 256;
    FKeys[row, keynr].Enabled := is_enabled;
end;

// create keys, their sizes and layout. Put them in the FKeys[] array
// this must be called first
procedure TMyKeyBoard.CreateKeyBoardKeys(const KeyBoardInfo: TKeyBoardInfo);
var
    i, J: integer;
    keydata: TKeyBoardData;
    rownumkeys: integer;
    rowlayout: TLayout;
    keycount: integer;
    rows: integer;
    rowlength: integer; // length in multiples of key.width
    KeyType: TKeyType;
    keyswide: integer;
    keyunitwidth, keyunitheight: single;
    Key: TKeyBoardKey;
    maxlen: integer;
    x, RowPosition: single;
    r: TBounds;
    obj: TFMXObject;
begin
    // add rowmargin?
    keydata := KeyBoardInfo.KeyBoard[0]; // first in array is always the keydata
    rows := Length(keydata);
    r := TBounds.Create(TRectF.Create(KeyBoardInfo.Keymargin,KeyBoardInfo.Rowmargin/2,0,KeyBoardInfo.Rowmargin/2));
    if Assigned(FKeys) then ClearKeys;

    SetLength(FKeys, rows); // FKeys: array of (row)array of TKeyBoardKey
    try
        for i := 0 to rows - 1 do // todo: surround with try..except
        // keyboard rows
        begin
            rowlength := sumrow(keydata[i]); // nr of key.width's
            maxlen := getmax(keydata); // max of rowlengths
            rownumkeys := Length(keydata[i]); // nr of keys
            SetLength(FKeys[i], rownumkeys);
            keyunitwidth := (Width-r.Left) / maxlen;  //width of 1 key'unit' (key + left margin)
            if KeyBoardInfo.KeyHeight = 0 then keyunitheight := keyunitwidth
            else keyunitheight := KeyBoardInfo.KeyHeight;
            rowlayout := TLayout.create(Self);
            rowlayout.HitTest := False;
            rowlayout.Name := 'kbrow' + IntToStr(i);
            rowlayout.Parent := Self;
            // TLayout = child of the TRectangle
            rowlayout.Width := Self.BoundsRect.Width;
            rowlayout.Height := keyunitheight + KeyBoardInfo.Rowmargin;
            rowlayout.Position.X := 0;
            rowlayout.Position.Y := i * rowlayout.Height;

            rowlayout.Align := KeyBoardInfo.RowAlign;
            // rowalign: usually 'scale' otherwise it doesn't autoresize
            Fill.Color := KeyBoardInfo.BGcolor;
            keycount := 0;
            RowPosition := 0;
            for J := 0 to rownumkeys - 1 do
            // keyboard keys
            begin
                keyswide := StrToInt(keydata[i][STRINGSTART + J]); //this key's nr. of width units
                Assert(keyswide > 0, 'key cannot have zero width');
                Key := TKeyBoardKey.create(rowlayout, KeyBoardInfo.KeyStyle);
                Key.Width := keyswide * keyunitwidth - r.Left;
                Key.Height := keyunitheight;
                Key.Margins := r;
                Key.Position.X := RowPosition;
                Key.Position.Y := 2;
                RowPosition := RowPosition + Key.Width + r.Left;
                Key.Align := TAlignLayout.Left;
                Key.Font.Size := KeyBoardInfo.FontSize;
                Key.StyleLookup := KeyBoardInfo.KeyStyle;
                Key.StyledSettings := Key.StyledSettings - [TStyledSetting.Size];
                Key.ApplyStyle;
                FKeys[i, keycount] := Key;
                keycount := keycount + 1;
            end;
            if rowlength < maxlen then
            begin
                FKeys[i, 0].Margins.Left := ((maxlen - rowlength) * KeyBoardInfo.KeyWidth) / 2;
                FKeys[i, keycount - 1].Margins.Right := ((maxlen - rowlength) * KeyBoardInfo.KeyWidth) / 2;
            end;
            for J := keycount - 1 downto 0 do FKeys[i, J].Align := KeyBoardInfo.KeyAlign;
        end;

    except on E: Exception do
        ShowMessage(E.Message);
    end;
    r.Free;
end;

// set the types of all created keys in FKeys[]
procedure TMyKeyBoard.ReadKeyTypes(KeyBoardInfo: TKeyBoardInfo; keyboardindex: integer);
var
    i, J: integer;
    Key: TKeyBoardKey;
    ktype: TKeyType;
    eff: TEffect;
begin
    try
        for i := 0 to High(FKeys) do
        begin
            assert(High(FKeys[i]) = KeyBoardInfo.KeyBoard[keyboardindex][i].Length-1, 'there must be equal nr. of keys and keytypes');
            for J := 0 to High(FKeys[i]) do
            begin
                Key := FKeys[i, J];
                ktype := TKeyType(KeyBoardInfo.KeyBoard[keyboardindex][i][STRINGSTART + J]);
                Key.FKeyType := ktype;
                case ktype of
                    ktNormal:
                        begin
                        end;
                    ktEnter:
                        begin
                        end;
                    ktSpace:
                        begin
                        end;
                    ktShift:
                        begin
                            Key.StaysPressed := true;
                            Key.IsPressed := False;
                            FShiftKeyPtr := Key;
                            eff := TGlowEffect.create(Key);
                            eff.Enabled := False;
                            eff.Trigger := 'IsPressed=true';
                            Key.AddObject(eff);
                        end;
                    ktNonSpacing:
                        begin
                            // MainForm.ApplyStyleLookupSetBackground(key, TAlphaColorRec.Darkblue);
                            // key.StyledSettings := [];
                            // key.Font.Size := 24;

                        end;
                    ktDone:
                        begin
                            Key.StyleLookup := 'arrowdowntoolbuttonbordered';
                            Key.ApplyStyle;
                        end;
                end;

            end;
        end;

    except on E: Exception do
        ShowMessage(E.Message);
    end;
end;

// set the values of all created keys
procedure TMyKeyBoard.ReadKeyValues(const KeyBoardInfo: TKeyBoardInfo; keyboardindex: integer);
var
    i, J: integer;
    board: TKeyBoardData;
    rows, rowlength: integer;
    ktype: TKeyType;
    Key: TKeyBoardKey;
begin
    board := KeyBoardInfo.KeyBoard[keyboardindex];
    try
        for i := 0 to High(FKeys) do
        begin
            assert(High(FKeys[i]) = board[i].Length-1, 'there must be equal nr. of keys and keyvalues');
            for J := 0 to High(FKeys[i]) do
            begin
                Key := FKeys[i, J];
                Key.FKeyCode := i * 256 + J;
                ktype := Key.FKeyType;
                case ktype of
                    ktNormal, ktNonSpacing:
                        begin
                            Key.FKeyValue := board[i][STRINGSTART + J];
                            Key.Text := Key.FKeyValue;
                        end;
                    ktEnter:
                        begin
                            Key.FKeyValue := chr(vkReturn);
                            // key.Text := 'enter';
                        end;
                    ktSpace:
                        begin
                            Key.FKeyValue := chr(vkSpace);
                            Key.Text := 'space';
                        end;
                    ktShift:
                        begin
                            Key.Text := 'shift';
                            Key.FKeyValue := chr(0);
                            Key.StaysPressed := true;
                            FShiftKeyPtr := Key;
                        end;
                    ktDel:
                        begin
                            Key.FKeyValue := chr(vkDelete);
                            Key.Text := 'Del';
                        end;
                    ktBack:
                        begin
                            Key.FKeyValue := chr(vkBack);
                        end;
                    ktLeft:
                        begin
                            Key.FKeyValue := chr(vkLeft);
                        end;
                    ktRight:
                        begin
                            Key.FKeyValue := chr(vkRight);
                        end;
                    ktUp:
                        begin
                            Key.FKeyValue := chr(vkUp);
                        end;
                    ktDown:
                        begin
                            Key.FKeyValue := chr(vkDown);
                        end;
                    ktDone:
                        begin
                            Key.FKeyValue := chr(0);
                            //Key.Text := '↓';
                            //Key.ImageIndex := 0;
                       end;
                    ktFunction:
                        begin
                            Key.FKeyValue := chr(0);
                            Key.Text := 'clear';
                        end
                else Key.Text := chr(Ord(ktype));
                    // ktAlt:
                    // ktSym:
                    // ktSwitch:
                    //
                    // ktEsc:
                    // ktFunction:
                end;
            end;
        end;

    except on E: Exception do
        ShowMessage(E.Message);
    end;
end;

procedure TMyKeyBoard.SetTarget(obj: TObject);
begin // this is a 'procedure of object' (TSetTarget)
    if obj is TEdit then FTarget := TEdit(obj)
    else if obj is TMemo then FTarget := TMemo(obj)
    else if obj is TLabel then FTarget := TLabel(obj);
end;

procedure TMyKeyBoard.MyKeyMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: single);
begin
    // TKeyBoardKey(Sender).AddObject(kEffect);
end;

procedure TMyKeyBoard.MyKeyMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: single);
begin
    // TKeyBoardKey(Sender).RemoveObject(kEffect);
end;

procedure TMyKeyBoard.MyKeyClick(Sender: TObject);
var // this is a 'procedure of object' (TOnClickEvent)
    thischar: char;
    thiscode: integer;
    thistype: TKeyType;
    Key: TKeyBoardKey;
    kb: TMyKeyBoard;
    s: string;
    pos, len: integer;
begin
    Key := TKeyBoardKey(Sender);
    kb := TMyKeyBoard(Parent);
    thischar := Key.FKeyValue; // nb: var param: set 0 to prevent entering in kTarget
    thiscode := Key.FKeyCode;
    thistype := Key.FKeyType;
    if Assigned(kb.OnKeyClick) then
    begin
        kb.OnKeyClick(Sender, thischar, thiscode, thistype); // execute event handler
    end; // thischar is a var parameter, can be changed in the event handler
    case thistype of
        ktNormal:
            begin        //todo: move all application-dependent actions to OnKeyClick handler
                if (thischar <> #0) and Assigned(kb.FTarget) then
                begin
                    if (kb.FTarget is TEdit) or (kb.FTarget is TMemo) then
                    begin // insert value of clicked/tapped key at cursor position
                        s := TEdit(kb.FTarget).Text;
                        pos := TEdit(kb.FTarget).SelStart;
                        len := TEdit(kb.FTarget).SelLength;
                        TEdit(kb.FTarget).Text := s.Substring(0, pos) + thischar + s.Substring(pos + len);
                        // substring always 0-based
                        TEdit(kb.FTarget).CaretPosition := pos + 1;
                        // if thistype = ktNormal then Self.FShiftKeyPtr.IsPressed := False;

                    end
                end;
            end;
        ktDone:
            begin
                kb.FOwner.Height := 0; //StartTriggerAnimation(Self, 'IsSelected=false') ;
                //kb.Visible := false;
            end;
        ktDel:
            begin
            end;
    end;
end;

end.
