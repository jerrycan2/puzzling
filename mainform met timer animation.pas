(*
  v3 voor Rad Studio 10.2: win64, win32 en android. 09-01-2018
  scrabble & anagram zoek gebruikt TWoord (index to OpLetterGesorteerdeWoorden) ipv strings & TSentence ipv stringlists

  woordenlijst
  http://woordenlijst.org/#/
  namen lijsten:
  http://www.naamkunde.net/?page_id=293
  http://www.naamkunde.net/?page_id=294

*)
// ←  →
// "My Documents", on windows: System.IOUtils.TPath.GetDocumentsPath;
// on android: System.IOUtils.TPath.GetSharedDocumentsPath;  this gives /user/public/documents on windows

unit main;

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes,
    System.Variants, System.IOUtils, System.Math, System.Character,
    System.StrUtils, System.TimeSpan, System.Diagnostics, System.Generics.Collections, System.Generics.Defaults,
    FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
    FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.ListView,
    FMX.ListView.Types, FMX.ComboEdit, FMX.Ani, FMX.DialogService, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
    FMX.Gestures, FMX.TabControl, System.Actions, FMX.ActnList, FMX.Objects,
    FMX.Platform, FMX.TextLayout, System.Messaging,
    FMX.ScrollBox, FMX.Memo, FMX.Grid.Style, FMX.SpinBox, FMX.FontGlyphs,
    FMX.Grid, FMX.VirtualKeyboard, FMX.Edit.Style, MyKeyboard, FMX.EditBox;

{$REGION 'TYPES & VARIABLE DECLARATIONS'}
type
    TFileNamen = (ned_all = 0, eng_all, ned_alf, eng_alf, ned_retro, eng_retro);
    TWorkOption = (woordzoek, scrabblezoek, anagramzoek);

    TWorkerThread = class(TThread)
    private
        FWoord: string;
        FZoekOptie: TWorkOption;
    protected
        procedure Execute; override;
    public
        procedure StopThread;
        constructor create(woord: string; zoek: TWorkOption);
    end;

    TWoordIndex = record
        str: string;
        index: integer;
    end;

    TWZmainform = class(TForm)
        OpenDialog1: TOpenDialog;
        StyleBook1: TStyleBook;
        KBpanel: TPanel;
        Layout1: TLayout;
        SettingsPanel: TPanel;
        SettingsPopupPanel: TPanel;
        TrackBar1: TTrackBar;
        Label3: TLabel;
        Layout2: TLayout;
        NedLanguage: TRadioButton;
        EngLanguage: TRadioButton;
        TabControl1: TTabControl;
        TabItem1: TTabItem;
        ListView1: TListView;
        ToolBar2: TToolBar;
        ScrabblePanel: TPanel;
        Edit1: TEdit;
        TabItem2: TTabItem;
        CustomList: TListView;
        ToolBar3: TToolBar;
        is_alf_button: TSpeedButton;
        is_retro_button: TSpeedButton;
        WoordLengteCombo: TComboBox;
        SortedLetterEdit: TEdit;
        ToolBar1: TToolBar;
        SpeedButton1: TSpeedButton;
        ActionList1: TActionList;
        PreviousTabAction1: TPreviousTabAction;
        NextTabAction1: TNextTabAction;
        GestureManager1: TGestureManager;
        ImageControl6: TImageControl;
        TextPrompt: TLabel;
        searchpanel: TPanel;
        SpeedButton2: TSpeedButton;
        BottomText: TLabel;
        Panel2: TPanel;
        Image2: TImage;
        Image1: TImage;
        Image3: TImage;
        Image5: TImage;
        kb_Animation: TFloatAnimation;
        ClearButton: TPanel;
        Image4: TImage;
        anapanel: TPanel;
        Image6: TImage;
        Label1: TLabel;
        Layout4: TLayout;
        Button1: TButton;
        SaveDialog1: TSaveDialog;
        Image7: TImage;
        BitmapListAnimation1: TBitmapListAnimation;
        AantalLabel: TLabel;
        GroupBox1: TGroupBox;
        AnaAlles: TRadioButton;
        AnaSelect: TRadioButton;
        Layout3: TLayout;
        SpinBox1: TSpinBox;
        Label4: TLabel;

        // procedure zoekanagramClick(Sender: TObject);
        // function filter(s: string): string;
        // procedure CreateLetterIndex(var list: TStringList);
        // procedure create_woordenlijst; //
        // procedure sorteerWoorden; //
        // procedure SorteerAlleWoorden(sortering: Integer);
        // procedure removelijstmetnamen;
        // procedure CreateConversionArray;
        // procedure loadcharlist; //
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure LoadAlleWoorden(Sender: TObject);
        procedure load_a_certain_length(len: integer);
        procedure ZetLanguageAndSorting(Sender: TObject);

        procedure startwork(title: string);
        procedure stopwork;
        procedure SetBottomText(Sender: TObject);
        procedure AssignToListBox1(source: TStringList);
        function change_ij(const text: string): string;
        procedure CreateConversionArray;
        procedure SetBottomInfo(aantal, procent: integer);
        procedure SizeComboBoxItems(ComboBox: TComboBox; Size: Single);
        function binsearch(ZoekWoord: string; list: TStringList): integer;
        procedure SaveListView1(path: string);

        procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: boolean);
        procedure HandleZoom(EventInfo: TGestureEventInfo);
        procedure HandlePan(Sender: TObject; EventInfo: TGestureEventInfo);
        procedure is_alf_buttonClick(Sender: TObject);
        procedure is_retro_buttonClick(Sender: TObject);
        procedure TrackBar1Change(Sender: TObject);
        procedure TrackBar1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure SettingsPopupPopup(Sender: TObject);
        procedure SettingsPopupPanelClick(Sender: TObject);
        procedure NedLanguageChange(Sender: TObject);
        procedure SettingsPanelClick(Sender: TObject);
        procedure Edit1Click(Sender: TObject);
        procedure Edit1KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
        procedure SortedLetterEditChangeTracking(Sender: TObject);
        procedure SortedLetterEditClick(Sender: TObject);
        procedure Edit1ChangeTracking(Sender: TObject);
        procedure terminatezoekactie(Sender: TObject);
        procedure finishloading(Sender: TObject);
        procedure StopThread(thread: TThread);
        procedure StopAndClearClick(Sender: TObject);
        procedure SpinBox1Change(Sender: TObject);
        procedure SwitchTab(Sender: TObject);
        procedure SaveButtonClick(Sender: TObject);

        procedure ZoekButtonClick(Sender: TObject);
        procedure PatternSearch(const Woord: string);
        procedure selecteer(const Woord: string);

        procedure ScrabbleSearch(FWoord: string);
        procedure terminatescrabblezoek(Sender: TObject);
        procedure ScrabbleClick(Sender: TObject);
        function doscrabblezoek(const zoekletters: string): TStringList;
        procedure ZetWoordLengteCombo;
        procedure WoordLengteComboChange(Sender: TObject);
        procedure maak_sol_lijst(Sender: TObject);
        function sorteer_letters(const s: string): string;

        procedure anapanelClick(Sender: TObject);
        procedure AnagramSearch(const Woord: string);
        function SubtractString(const string1, string2: string): string;
        procedure checkstring(const diff: string; const builder: string; level: integer);

        function SearchBeginning(const zoekletters: string; currentlength: integer): integer;
        function SearchLast(const zoekletters: string; currentlength: integer): integer;

        procedure ListView1Tap(Sender: TObject; const Point: TPointF);
        procedure ListView1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure ListView1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: boolean);
        procedure ListView1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);

        procedure CreateKeyBoard;
        procedure MyKeyBoardClick(Sender: TObject; var Key: Char; KeyCode: integer; var KeyType: TKeyType);
        procedure Layout1Click(Sender: TObject);
        procedure timerevent(Sender: TObject);

    private
        DocumentsPath: string;
        CommonDocuments: string;
        N_of_Lines: integer;
        FService: IFMXVirtualKeyboardService;
        KBheight: integer;
        MyKeyboard: TMyKeyBoard;
        LenSortedList_filename, AlleWoorden_filename: string;
        FZoomStartDistance: integer;
        MyLayout: TTextLayout;
        LineHeight: Single;
        EventInfo1: TGestureEventInfo;
        CustomBounds, ListViewBounds: TRectF;
        lettersorteerarray: array [0 .. (ord('z') - ord('a')) + 1] of byte; // high = IJCHARINDEX
        WildcardsFound: integer;
        OpLetterGesorteerdeWoorden: TList<TWoordIndex>; // <key, value>
        OndersteGedeelte, BovensteGedeelte: Single;
        FLastPosition: TPointF;
        workerthread: TWorkerThread;
        FDiffLength: integer;
        ItCount: Cardinal;
        animationindex: integer;
    public
        AlleWoorden, HelpText, LtrSorted: TStringList;
        LenSortedList: TStringList;
        // LetterIndex: array [0 .. 25] of array [0 .. 25] of Cardinal;
        spPanel: TPanel;
        spSpinBox: TSpinBox;
        CommonFontSize, SaveFontSize: Single;
        Stopwatch: TStopWatch;
        ResultList: TStringList;
        gehad: TDictionary<string,integer>;
        Snail: TBitmap;
        timer: TTimer;
    end;

var
    WZmainform: TWZmainform;
    conversionarray: array [0 .. 512] of Char;
    charlist: TStringList;
    StartTime, StopTime: Int64;
    reverse_length_sort: integer = 1;

const
    KB1DATA: TKeyBoardData = ['1111111111', // sets number of keys, their basic style, size and layout
    '111111111', // each digit 1-9 is a 'width unit' (def. in TKeyBoardInfo)
    '1111111111', '333'];
    KB1TYPE: TKeyBoardData = [ // keytype
        'aaaaaaaaaa', // sets FKeyType and some key properties such as color or TEffect or StaysPressed
    'aaaaaaaaa', 'aaaaaaaaaa', 'kmi']; // k=del, m=function(clear), i=hide keyboard
    KB1KEYS: TKeyBoardData = [ // keyvalue
        'qwertyuiop', // if keytype = ktNormal or ktNonSpacing, sets FKeyValue
    'asdfghjkl', // so if corresponding keytype <> 'a' or 'r', value here is ignored
    'zxcvbnmĳ*.', '___' // others are assigned in ReadKeyValues
        ];

    FileNamen: TArray<string> = [ // index: TFileNamen
        'woordlijst.txt', 'wordlist.txt', 'alfabetisch.txt', 'alf_eng.txt', 'retrograde.txt', 'retro_eng.txt'];

    IJCHARINDEX = (ord('z') - ord('a')) + 1;

{$ENDREGION}

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.LgXhdpiPh.fmx ANDROID}

{$REGION 'WORKERTHREAD'}
constructor TWorkerThread.Create(woord: string; zoek: TWorkOption);
begin
    inherited create(true);  //create suspended
    FZoekOptie := zoek;
    FWoord := woord;
end;

procedure TWorkerThread.StopThread;
begin
    Terminate;
    Waitfor;
    Free;
end;

procedure TWorkerThread.Execute;
begin
    case FZoekOptie of
        anagramzoek: WZmainform.AnagramSearch(FWoord);
        woordzoek: WZmainform.selecteer(FWoord);
        scrabblezoek: WZmainform.ScrabbleSearch(FWoord);
    end;
end;
{$ENDREGION}

{$REGION 'HULPROUTINES'}
// ****************************************************************************//
// *********************hulproutines voor setup********************************//
// ****************************************************************************//

function ArrayToString(const a: array of Char): string;
begin
    if Length(a) > 0 then SetString(Result, PChar(@a[0]), Length(a))
    else Result := '';
end;

function normalize_string(const s: string): string;
var
    i: integer;
    a: array of Char;
    c: Char;
begin
    // s := change_ij(s); //uncomment this when creating woordlijst etc.
    SetLength(a, s.Length);
    i := 0;
    for c in s do
    begin
        a[i] := conversionarray[ord(c)];
        inc(i);
    end;

    Result := ArrayToString(a);
end;

function AlfOpLenSort(list: TStringList; index1, index2: integer): integer;
var
    X, Y: integer;
begin
    X := list[index1].Length;
    Y := list[index2].Length;
    if X > Y then
    begin
        Result := reverse_length_sort;
        exit;
    end else if X < Y then
    begin
        Result := -reverse_length_sort;
        exit;
    end;
    Result := AnsiCompareText(list[index1], list[index2]);
end;

function RetrogradeSort(list: TStringList; index1, index2: integer): integer;
var
    X, Y: integer;
    cx, cy: string;
begin
    X := list[index1].Length;
    Y := list[index2].Length;
    if X > Y then
    begin
        Result := 1;
        exit;
    end else if X < Y then
    begin
        Result := -1;
        exit;
    end;
    Result := 0;
    while (X > 0) do // X = Y
    begin
        cx := normalize_string(list[index1][X]);
        cy := normalize_string(list[index2][X]);
        Result := AnsiCompareText(cx, cy);
        if Result <> 0 then exit;

        dec(X);
    end;
end;

function minmax(minval, maxval, val: Single): Single;
begin
    if val > maxval then val := maxval
    else if val < minval then val := minval;
    Result := val;
end;

{$ENDREGION}

// *********************************************************************
// ****************************WZmainform*******************************
// *********************************************************************

{$REGION 'WZmainform create load destroy resize'}

procedure TWZmainform.FormCreate(sender: TObject);
var
    myEncoding: TEncoding;
    thread: TThread;
begin
    System.ReportMemoryLeaksOnShutdown := true;
    Stopwatch := TStopWatch.Create;
    timer := TTimer.Create(Self);
    timer.Interval := 100;
    timer.Enabled := false;
    timer.OnTimer := timerevent;

    CommonFontSize := 12;

    CustomBounds := CustomList.BoundsRect;
    ListViewBounds := ListView1.BoundsRect;
{$IFDEF ANDROID}
    CommonDocuments := System.IOUtils.TPath.GetSharedDocumentsPath + System.IOUtils.TPath.DirectorySeparatorChar;
    DocumentsPath := System.IOUtils.TPath.GetDocumentsPath + System.IOUtils.TPath.DirectorySeparatorChar;
    // bij de grafische routines is er ook een TPath
{$ELSE}
    CommonDocuments := System.IOUtils.TPath.GetDocumentsPath + System.IOUtils.TPath.DirectorySeparatorChar;
    DocumentsPath := System.IOUtils.TPath.GetDocumentsPath + '\woordzoek\';
{$ENDIF}
//    ResultList := TStringList.Create;
//    ResultList.Sorted := false;
    gehad := TDictionary<string, integer>.Create;
    FDiffLength := 1;
    SpinBox1.Value := 2;

    Snail := TBitmap.Create;
    Snail.CreateFromFile(DocumentsPath+'snail.png');

    CreateKeyBoard;
    KBpanel.Height := 0;
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));

    BovensteGedeelte := ListView1.Height / 3;
    OndersteGedeelte := 2 * BovensteGedeelte;

    MyLayout := TTextLayoutManager.DefaultTextLayout.Create;
    MyLayout.WordWrap := false;
    MyLayout.text := 'Ay';
    MyLayout.Font.Size := CommonFontSize;
    LineHeight := Trunc(MyLayout.TextHeight + 1);

    myEncoding := TEncoding.UTF8;
    AlleWoorden := TStringList.Create;
    LtrSorted := TStringList.Create;
    HelpText := TStringList.Create;
    charlist := TStringList.Create;
    LenSortedList := TStringList.Create;

    AlleWoorden.Sorted := true;
    AlleWoorden.Duplicates := dupIgnore;
    AlleWoorden.CaseSensitive := false;
    AlleWoorden.WriteBOM := true;

    charlist.WriteBOM := true;
    charlist.Duplicates := dupIgnore;
    charlist.Sorted := false;
    charlist.LoadFromFile(DocumentsPath + 'conversionchars.txt');

    // loadcharlist;
    N_of_Lines := Trunc(CustomList.Height / CustomList.ItemAppearance.ItemHeight);

    CreateConversionArray;
    // create_woordenlijst; //voor preparatie woordlijst.txt of wordlist.txt

    thread := TThread.CreateAnonymousThread(
        procedure()
        begin
            LoadAlleWoorden(nil); // load AlleWoorden, taalafhankelijk
            ZetLanguageAndSorting(nil); // load op lengte gesorteerde files, taalafhankelijk
            maak_sol_lijst(nil); // gesorteerd-op-letter stringlist
            //sorteerWoorden; //moet in thread   gebruikt voor creatie alfabetisch.txt etc
        end);
    thread.OnTerminate := finishloading;
    thread.Start;
    // removelijstmetnamen;
    // CreateLetterIndex(AlleWoorden);

    HelpText.LoadFromFile(DocumentsPath + 'wzhelp.txt', myEncoding);
    AssignToListBox1(HelpText);

    Edit1.KeyboardType := TVirtualKeyboardType.Alphabet;
    Edit1.KillFocusByReturn := true;
end;

procedure TWZmainform.finishloading(Sender: TObject);
begin
    ZetWoordLengteCombo; // zet combobox items
    SetBottomText(nil);
end;

procedure TWZmainform.FormDestroy(Sender: TObject);
begin
    StopThread(workerthread);
    AlleWoorden.Free;
    HelpText.Free;
    LtrSorted.Free;
    charlist.Free;
    LenSortedList.Free;
    MyLayout.Free;
    MyKeyboard.ClearKeys;
    OpLetterGesorteerdeWoorden.Free;
    gehad.Free;
    if Assigned(ResultList) then ResultList.Free;
end;

procedure TWZmainform.FormResize(Sender: TObject);
begin
    N_of_Lines := Trunc(CustomList.Height / CustomList.ItemAppearance.ItemHeight);
    if MyLayout <> nil then
    begin
        MyLayout.Font.Size := CommonFontSize;
        LineHeight := Trunc(MyLayout.TextHeight + 1);
        CustomList.ItemAppearanceObjects.ItemObjects.text.Font.Size := CommonFontSize;
        ListView1.ItemAppearanceObjects.ItemObjects.text.Font.Size := CommonFontSize;
        ListView1.ItemAppearance.ItemHeight := round(LineHeight + 4);
        CustomList.ItemAppearance.ItemHeight := round(LineHeight + 4);
    end;
end;

procedure TWZmainform.LoadAlleWoorden(Sender: TObject);
begin
    if NedLanguage.IsChecked then
    begin
        if AlleWoorden_filename <> FileNamen[ord(ned_all)] then
        begin
            AlleWoorden_filename := FileNamen[ord(ned_all)];
            AlleWoorden.Clear;
            AlleWoorden.LoadFromFile(DocumentsPath + AlleWoorden_filename);
        end;
    end else begin
        if AlleWoorden_filename <> FileNamen[ord(eng_all)] then
        begin
            AlleWoorden_filename := FileNamen[ord(eng_all)];
            AlleWoorden.Clear;
            AlleWoorden.LoadFromFile(DocumentsPath + AlleWoorden_filename);
        end;
    end;
end;

procedure TWZmainform.load_a_certain_length(len: integer);
var
    txt: string;
    index, Start, stop: integer;
begin
    CustomList.Items.Clear;
    txt := SortedLetterEdit.text;
    if txt = '' then txt := 'a';

    Start := SearchBeginning(txt, len);
    stop := SearchLast(txt, len);
    index := Start;
    if Start = -1 then
    begin
        CustomList.Items.Add.text := '(niets gevonden)';
    end else begin
        while index <= stop do
        begin
            txt := LenSortedList[index];
            CustomList.Items.Add.text := txt;
            inc(index);
        end;
    end;
end;

procedure TWZmainform.ZetLanguageAndSorting(Sender: TObject);
var
    al_index: integer;
    file1, file2: TFileNamen;
begin
    if NedLanguage.IsChecked then
    begin
        file1 := ned_alf;
        file2 := ned_retro;
    end else begin
        file1 := eng_alf;
        file2 := eng_retro;
    end;
    al_index := -1;
    if (WoordLengteCombo.Items.Count > 0) and (WoordLengteCombo.ItemIndex >= 0) then
            al_index := StrToInt(WoordLengteCombo.Items[WoordLengteCombo.ItemIndex]);
    if al_index = -1 then al_index := 3;

    if is_retro_button.IsPressed then
    begin
        if LenSortedList_filename <> FileNamen[ord(file2)] then
        begin
            LenSortedList_filename := FileNamen[ord(file2)];
            LenSortedList.LoadFromFile(DocumentsPath + LenSortedList_filename);
            load_a_certain_length(al_index);
        end;
        MyKeyboard.setRTLmode(true);
    end else begin
        if LenSortedList_filename <> FileNamen[ord(file1)] then
        begin
            LenSortedList_filename := FileNamen[ord(file1)];
            LenSortedList.LoadFromFile(DocumentsPath + LenSortedList_filename);
            load_a_certain_length(al_index);
        end;
        MyKeyboard.setRTLmode(false);
    end;
end;


{$ENDREGION}

{$REGION 'WZmainform HULPROUTINES'}

procedure TWZmainform.timerevent(Sender: TObject);
var
    sourcerect, destrect: TRectF;
    left: single;
const
    w = 176;
    h = 48;
begin
    destrect := TRectF.Create(0,0,w,h);
    left := animationindex * w;
    sourcerect := TRectF.Create(left, 0, left+w, h);
    animationindex := (animationindex + 1) mod 12;
    if Image7.Bitmap.Canvas.BeginScene then
    begin
        Image7.Bitmap.Canvas.Clear(TAlphaColorRec.Null);
        Image7.Bitmap.Canvas.DrawBitmap(Snail, sourcerect, destrect, 1, false);
        Image7.Bitmap.Canvas.EndScene;
    end;
end;

procedure TWZmainform.startwork(title: string);
begin
    Image7.Visible := true;
{.$IFDEF MSWINDOWS}
    //BitmapListAnimation1.Start;
    timer.Enabled := true;
{.$ENDIF}
    BottomText.Text := title;
    BottomText.Visible := false;
end;

procedure TWZmainform.stopwork;
begin
    Image7.Visible := false;
    //BitmapListAnimation1.Stop;
    timer.Enabled := false;
    BottomText.Visible := true;
end;

function TWZmainform.change_ij(const text: string): string;
var // verander i+j in ij, I+J in IJ
    i, n, len: integer;
    // has_wildcards voor als het woord in de inputbuffer zit
    found: boolean;
    c1, c2: Char;
    buffer: array [0 .. 255] of Char;
begin
    if EngLanguage.IsChecked = true then Result := text
    else
    begin
        n := 0; // index to buffer
        i := low(text); // index to text, may start at 1 or 0
        len := high(text);
        Result := '';
        found := false;
        while i <= len do
        begin
            c1 := text[i];
            c2 := text[i + 1];
            if (i < len) and (c1 = 'i') and (c2 = 'j') then
            begin
                buffer[n] := 'ĳ'; // buffer: global
                i := i + 2;
                n := n + 1;
                found := true;
            end else if (i < len) and (c1 = 'I') and (c2 = 'J') then // Ĳ
            begin
                buffer[n] := 'Ĳ'; // buffer: global
                i := i + 2;
                n := n + 1;
                found := true;
            end else begin
                buffer[n] := c1;
                i := i + 1;
                n := n + 1;
            end;
        end;
        if found then
        begin
            if n > 0 then SetString(Result, buffer, n);
        end
        else Result := text;
    end;
end;

procedure TWZmainform.CreateConversionArray;
var
    i, index: integer;
    c: Char;
    hex, val: string;
begin
    // loadcharlist;
    for i := 1 to 511 do
    begin
        c := chr(i);
        hex := IntToHex(ord(c), 4);
        val := charlist.Values[hex];
        if val <> '' then
        begin
            c := chr(StrToInt(val)); // don't forget to correct ij and IJ (0133,0132) in charlist
        end;
        if isUpper(c) then c := ToLower(c);
        conversionarray[i] := c;
    end;
end;


procedure TWZmainform.SetBottomInfo(aantal, procent: integer);
begin
    if aantal >= 0 then AantalLabel.Text := IntToStr(aantal);
    //ProgressBar1.Value := procent;
end;

procedure TWZmainform.SizeComboBoxItems(ComboBox: TComboBox; Size: Single);
var
    item: TListBoxItem;
    i: integer;
begin
    for i := 0 to ComboBox.Count - 1 do
    begin
        item := ComboBox.ListItems[i];
        item.StyledSettings := item.StyledSettings - [TStyledSetting.Size];
        item.TextSettings.Font.Size := Size; // 20;
    end;
end;

function TWZmainform.binsearch(ZoekWoord: string; list: TStringList): integer;
var // return index (>=0) or -1
    hi, lo, mid, groter: integer;
begin
    hi := list.Count - 1;
    lo := 0;
    Result := -1;
    while lo <= hi do
    begin
        mid := lo + (hi - lo) div 2; // must be like this, because of rounding
        groter := AnsiCompareText(normalize_string(list.Strings[mid]), ZoekWoord);
        if groter = 0 then
        begin
            repeat
                Result := mid; // may not be the first of series of duplicates
                dec(mid);
            until AnsiCompareText(normalize_string(list.Strings[mid]), ZoekWoord) <> 0;
            exit; // result = 0 : gevonden
        end else if groter < 0 then lo := mid + 1
        else hi := mid - 1;
    end;
end;

procedure TWZmainform.SetBottomText(Sender: TObject);
begin
    if not Assigned(ListView1) then exit;

    if ListView1.Items.Count = 0 then ListView1.Items.Add.text := '(niets gevonden)';

    if TabControl1.TabIndex = 0 then
    begin
        if (ListView1.Items[0].text = 'Gebruiksaanwijzing:') or (ListView1.Items[0].text = '(niets gevonden)') then
                AantalLabel.text := '0'
        else AantalLabel.text := IntToStr(ListView1.Items.Count);
    end else begin
        if (CustomList.Items.Count = 0) or (CustomList.Items[0].text = '(niets gevonden)') then AantalLabel.text := '0'
        else AantalLabel.text := IntToStr(CustomList.Items.Count);
    end;
    //BottomText.text := BottomText.text + ' woorden';
end;

procedure TWZmainform.AssignToListBox1(source: TStringList);
var
    i: integer;
begin
    // ListView1.BeginUpdate;
    ListView1.Items.Clear;
    for i := 0 to source.Count - 1 do
    begin
        ListView1.Items.Add.text := source.Strings[i];
    end;
    // ListView1.EndUpdate;
end;

procedure TWZmainform.SaveListView1(path: string);
var
    n: integer;
begin
    ResultList := TStringList.Create;
    for n := 0 to ListView1.Items.Count-1 do
    begin
        if ListView1.EditMode then
        begin
            if ListView1.Items[n].Checked then ResultList.Add(ListView1.Items[n].Text);
        end
        else
        begin
            ResultList.Add(ListView1.Items[n].Text);
        end;
    end;
    ResultList.SaveToFile(path);
    FreeAndNil(ResultList);
end;
{$ENDREGION}

{$REGION 'EVENTS MAINFORM'}

procedure TWZmainform.FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: boolean);
begin
    case EventInfo.GestureID of
        igiZoom:
            begin
                HandleZoom(EventInfo);
                Handled := true;
            end;
    end;
end;

procedure TWZmainform.HandleZoom(EventInfo: TGestureEventInfo);
var
    deltafont, deltascale, scale, fontsize: Single;
    distance: integer;
begin
    if TInteractiveGestureFlag.gfBegin in EventInfo.Flags then
    begin
        FZoomStartDistance := EventInfo.distance;
    end else if not(TInteractiveGestureFlag.gfEnd in EventInfo.Flags) then
    begin
        distance := EventInfo.distance - FZoomStartDistance;
        scale := ListView1.scale.X;
        deltascale := distance / 1000;
        scale := minmax(1.0, 2.5, scale + deltascale);
        ListView1.scale.X := scale;
        ListView1.scale.Y := scale;
        CustomList.scale.X := scale;
        CustomList.scale.Y := scale;
        CustomList.BoundsRect := CustomBounds;
        ListView1.BoundsRect := ListViewBounds;
    end;
end;

procedure TWZmainform.HandlePan(Sender: TObject; EventInfo: TGestureEventInfo);
var
    list: TListView;
    scrollpos, maxpos: Single;
begin
    list := TListView(Sender);
    scrollpos := list.ScrollViewPos;
    if not(TInteractiveGestureFlag.gfBegin in EventInfo.Flags) then
    begin
        scrollpos := scrollpos + (EventInfo.Location.Y - FLastPosition.Y);
        if scrollpos < 0 then scrollpos := 0;
        maxpos := list.ItemCount * list.ItemAppearance.ItemHeight - list.Height;
        if scrollpos > maxpos then scrollpos := maxpos;
        // log.d(floattostr(scrollpos));
        list.ScrollViewPos := scrollpos;
    end;
    FLastPosition := EventInfo.Location;

end;

procedure TWZmainform.is_alf_buttonClick(Sender: TObject);
begin
    is_retro_button.IsPressed := not is_alf_button.IsPressed;
    ZetLanguageAndSorting(nil);
    finishloading(nil);
end;

procedure TWZmainform.is_retro_buttonClick(Sender: TObject);
begin
    is_alf_button.IsPressed := not is_retro_button.IsPressed;
    ZetLanguageAndSorting(nil);
    finishloading(nil);
end;

procedure TWZmainform.TrackBar1Change(Sender: TObject);
begin
    EventInfo1.distance := Trunc(TrackBar1.Value);
    HandleZoom(EventInfo1);
    FZoomStartDistance := EventInfo1.distance;
    // log.d('jeroen: ' + floattostr(TrackBar1.Value));
end;

procedure TWZmainform.TrackBar1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
    HandleZoom(EventInfo1);
    FZoomStartDistance := EventInfo1.distance;
    // log.d('end: ' + floattostr(EventInfo1.Distance));
end;

procedure TWZmainform.SettingsPopupPanelClick(Sender: TObject);
begin
    SettingsPopupPanel.Visible := false;
end;

procedure TWZmainform.SettingsPopupPopup(Sender: TObject);
begin
    FZoomStartDistance := EventInfo1.distance;
    TrackBar1.Value := EventInfo1.distance;
    // log.d('start: ' + floattostr(ListView1.scale.X) + ', ' + floattostr(EventInfo1.Distance));
end;

procedure TWZmainform.NedLanguageChange(Sender: TObject);
var
    thread: TThread;
begin
    //SetBottomInfo(0,0);
    thread := TThread.CreateAnonymousThread(
        procedure()
        begin
            if TabControl1.TabIndex = 1 then // customlist showing
            begin
                ZetLanguageAndSorting(nil);
            end else begin
                LoadAlleWoorden(nil); // listview1
            end;
            maak_sol_lijst(nil);
            SetBottomText(nil);
        end);
    thread.OnTerminate := finishloading;
    thread.Start;
end;

procedure TWZmainform.SettingsPanelClick(Sender: TObject);
begin
    SettingsPopupPanel.Visible := true;
end;

procedure TWZmainform.SwitchTab(Sender: TObject);
begin
    if TabControl1.TabIndex = 1 then // customlist showing
    begin
        MyKeyboard.SetTarget(SortedLetterEdit);
        MyKeyboard.disableKey($208, false);
        MyKeyboard.disableKey($209, false);
        ZetLanguageAndSorting(nil);
        finishloading(nil);
    end else begin // ListView1 showing
        MyKeyboard.setRTLmode(false);
        MyKeyboard.SetTarget(Edit1);
        MyKeyboard.disableKey($208, true);
        MyKeyboard.disableKey($209, true);
        LoadAlleWoorden(nil);
        finishloading(nil);
    end;

end;

procedure TWZmainform.terminatezoekactie(Sender: TObject);
var
    n: integer;
    thread: TThread;
begin
    thread := Sender as TThread;

    SetBottomText(nil);
    stopwork;
end;

procedure TWZmainform.Edit1ChangeTracking(Sender: TObject);
begin
    if Edit1.text = '' then TextPrompt.Visible := true
    else TextPrompt.Visible := false;
end;

procedure TWZmainform.StopThread(thread: TThread);
begin
    if Assigned(thread) then
    begin
        if thread is TWorkerThread then (thread as TWorkerThread).StopThread;
    end;
end;

procedure TWZmainform.SpinBox1Change(Sender: TObject);
begin
    FDiffLength := Trunc(SpinBox1.Value);
end;

procedure TWZmainform.StopAndClearClick(Sender: TObject);
begin
    StopThread(workerthread as TThread);
    SetBottomText(nil);
end;

procedure TWZmainform.Edit1Click(Sender: TObject);
begin
    if (FService <> nil) then
    begin
        FService.HideVirtualKeyboard;
        MyKeyboard.Visible := true;
        KBpanel.AnimateFloat('Height', KBheight, 0.25);
        MyKeyboard.SetTarget(Edit1);
    end;
    TextPrompt.Visible := false;
    // Edit1.Caret.Visible := false;
end;

procedure TWZmainform.Edit1KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
    if KeyChar = #13 then
    begin
        ZoekButtonClick(nil);
        Key := 0;
    end;
end;

procedure TWZmainform.SortedLetterEditChangeTracking(Sender: TObject);
var
    zoekletters: string;
    wLength: integer;
begin
    N_of_Lines := Trunc(CustomList.Height / CustomList.ItemAppearance.ItemHeight);
    CustomList.ScrollTo(0);
    zoekletters := normalize_string(SortedLetterEdit.text);
    CustomList.ItemIndex := 0;
    if WoordLengteCombo.ItemIndex <> -1 then wLength := StrToInt(WoordLengteCombo.Items[WoordLengteCombo.ItemIndex])
    else wLength := 4;

    load_a_certain_length(wLength);
    SetBottomText(nil);
end;

procedure TWZmainform.SortedLetterEditClick(Sender: TObject);
begin
    N_of_Lines := Trunc(CustomList.Height / CustomList.ItemAppearance.ItemHeight);
    if (FService <> nil) then
    begin
        FService.HideVirtualKeyboard;
        KBpanel.Height := KBheight;
        MyKeyboard.SetTarget(SortedLetterEdit);
        SortedLetterEdit.Caret.Visible := false;
    end;
end;

procedure TWZmainform.Layout1Click(Sender: TObject);
begin
    ListView1.EditMode := not ListView1.EditMode;
end;

procedure TWZmainform.SaveButtonClick(Sender: TObject);
VAR
    s: string;
begin
{$IFDEF ANDROID}
    s := System.IOUtils.TPath.GetSharedDocumentsPath;
{$ELSE}
    s := System.IOUtils.TPath.GetDocumentsPath;
{$ENDIF}
    SaveDialog1.InitialDir := s;
    SaveDialog1.FileName := 'puzzelhulp.txt';
    try
        if SaveDialog1.Execute then SaveListView1(SaveDialog1.FileName);
    except
        ShowMessage('fout: probeer nog eens');
    end;
end;

{$ENDREGION}

{$REGION 'EVENTS LISTVIEWs'}

procedure TWZmainform.ListView1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
    if TListView(Sender).Name = 'CustomList' then Canvas.Fill.Color := TAlphaColorRec.Yellowgreen
    else Canvas.Fill.Color := TAlphaColorRec.Navy;
    Canvas.FillRect(ARect, 0, 0, AllCorners, 0.4);
end;

procedure TWZmainform.ListView1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: boolean);
begin
    case EventInfo.GestureID of
        igiPan:
            begin
                HandlePan(Sender, EventInfo);
                Handled := true;
            end;
    end;
end;

procedure TWZmainform.ListView1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
    Point: TPointF;
begin
    Point := TPointF.Create(X, Y);
    ListView1Tap(Sender, Point);
end;

procedure TWZmainform.ListView1Tap(Sender: TObject; const Point: TPointF);
var
    pos: Single;
    LocalPoint: TPointF;
    numlines: integer;
    lv: TListView;
    iheight, usedheight: integer;
begin
    lv := TListView(Sender);
    pos := lv.ScrollViewPos;
    LocalPoint := lv.AbsoluteToLocal(Point);
    iheight := lv.ItemAppearance.ItemHeight;
    numlines := floor(lv.Size.Height / iheight);
    usedheight := numlines * iheight;
    if LocalPoint.Y < (lv.Size.Height / 3) then
    begin
        pos := max(0, pos - usedheight);
        if pos > 0 then pos := floor(pos / iheight + 1) * iheight;
    end else if LocalPoint.Y > 2 * (lv.Size.Height / 3) then
    begin
        pos := pos + usedheight;
        pos := floor(pos / iheight - 1) * iheight;
    end
    else exit;
    lv.AnimateFloat('ScrollViewPos', pos, 0.25);
end;

{$ENDREGION}

{$REGION 'WZmainform LENGTE SORTERING'}

function TWZmainform.SearchBeginning(const zoekletters: string; currentlength: integer): integer;
var // zoek laagste index met gegeven begin- of eindletters
    woord, letters: string;
    found: boolean;
    index: integer;
begin
    for index := 0 to LenSortedList.Count - 1 do
    begin
        if LenSortedList[index].Length = currentlength then break;
    end;

    if is_retro_button.IsPressed then
    begin
        // retro
        found := false;
        while index < LenSortedList.Count do
        begin
            woord := normalize_string(LenSortedList[index]);
            letters := woord.Substring(woord.Length - zoekletters.Length);
            if letters = zoekletters then
            begin
                found := true;
                break;
            end;
            inc(index);
        end;
    end else begin
        found := false;
        while index < LenSortedList.Count do
        begin
            woord := normalize_string(LenSortedList[index]);
            letters := woord.Substring(0, zoekletters.Length);
            if letters = zoekletters then
            begin
                found := true;
                break;
            end;
            inc(index);
        end;
    end;
    if found then Result := index
    else Result := -1;
end;

function TWZmainform.SearchLast(const zoekletters: string; currentlength: integer): integer;
var // zoek hoogste index met gegeven begin- of eindletters
    woord, letters: string;
    found: boolean;
    index: integer;
begin
    for index := LenSortedList.Count - 1 downto 0 do
    begin
        if LenSortedList[index].Length = currentlength then break;
    end;

    if is_retro_button.IsPressed then
    begin
        // retro
        found := false;
        while index >= 0 do
        begin
            woord := normalize_string(LenSortedList[index]);
            letters := woord.Substring(woord.Length - zoekletters.Length);
            if letters = zoekletters then
            begin
                found := true;
                break;
            end;
            dec(index);
        end;
    end else begin
        found := false;
        while index >= 0 do
        begin
            woord := normalize_string(LenSortedList[index]);
            letters := woord.Substring(0, zoekletters.Length);
            if letters = zoekletters then
            begin
                found := true;
                break;
            end;
            dec(index);
        end;
    end;
    if found then Result := index
    else Result := -1;
end;

{$ENDREGION}

{$REGION 'WZmainform ANAGRAM'}

procedure TWZmainform.anapanelClick(Sender: TObject);
var
    orig: string;
    c: char;
begin
    if Assigned(workerthread) and (workerthread.Terminated = false) then
    begin
        StopAndClearClick(nil);
        exit;
    end;
    if Edit1.text.Length < 2 then
    begin
        ShowMessage('minstens 2 letters!');
        exit;
    end;
    ListView1.Items.Clear;
    for c in Edit1.text do
    begin
        if not(c.IsLetter or (c = '.')) then
        begin
            ShowMessage('alleen letters en .');
            exit;
        end;
    end;
    orig := normalize_string(WZmainform.change_ij(Edit1.text));
    workerthread := TWorkerThread.Create(orig, anagramzoek);  //true = anagram search
    workerthread.OnTerminate := terminatezoekactie;
    workerthread.Start;
    startwork('anagrammen');
end;

procedure TWZmainform.checkstring(const diff: string; const builder: string; level: integer);
var
    i: integer;
    s, check, newdiff, newbuilder, tmp: string;
    list: TStringList;
    done: boolean;
begin
    if workerthread.Terminated = true then exit;

    list := doscrabblezoek(diff);
    if list.Count > 0 then
    begin
        for i := 0 to list.Count - 1 do
        begin
            s := normalize_string(list.Strings[i]);
            if s.Length < FDiffLength then break;

            newdiff := SubtractString(diff, s);
            if AnaSelect.IsChecked and gehad.ContainsKey(newdiff) then continue;

            newbuilder := builder + ' ' + list.Strings[i];
            if newdiff.Length = 0 then
            begin
                TThread.Synchronize(TThread.CurrentThread,
                    procedure()
                    begin
                        ListView1.Items.Add.text := newbuilder;
                        SetBottomInfo(ListView1.Items.Count, 0);
                    end);
                //ResultList.Add(newbuilder);
            end
            else if (newdiff.Length >= FDiffLength) then
            begin
                checkstring(newdiff, newbuilder, level+1);
            end;
        end;
        if AnaSelect.IsChecked and not gehad.ContainsKey(diff) then gehad.Add(diff, 0);
    end;
    list.Free;
end;

procedure TWZmainform.AnagramSearch(const Woord: string);
begin
    SetBottomInfo(0,0);
    ResultList := TStringList.Create;
    WZmainform.checkstring(Woord, '', 0);
    ResultList.SaveToFile(DocumentsPath + 'test.txt');
    FreeAndNil(ResultList);
    //AssignToListBox1(ResultList);
end;

function TWZmainform.SubtractString(const string1, string2: string): string;
var // subtract string2 from string1, return what is left
    len: integer;
    buffer1, outbuffer: array of Char;
    i: integer;

    procedure del_from_buffer(c: Char);
    var
        i1: integer;
        found: boolean;
    begin
        found := false;
        for i1 := low(buffer1) to high(buffer1)-1 do
        begin
            if c = buffer1[i1] then
            begin
                buffer1[i1] := Char(0);
                found := true;
                break;
            end;
        end;
//        if not found then
//            raise Exception.Create('anagram internal error');
    end;

begin
    try
        SetLength(buffer1, string1.Length + 1);
        StrLCopy(PChar(buffer1), PChar(string1), string1.Length);
        SetLength(outbuffer, string1.Length + 1);
        len := 0;
        for i := low(string2) to high(string2) do
        begin
            del_from_buffer(string2[i]);
        end;
        for i := low(buffer1) to high(buffer1)-1 do
        begin
            if buffer1[i] <> #0 then
            begin
                outbuffer[len] := buffer1[i];
                inc(len);
            end;
        end;
        SetString(Result, PChar(outbuffer), len);

    except on E: Exception do
        begin
//            ShowMessage(E.Message);
            Result := '';
        end;
    end;
end;

{$ENDREGION}

{$REGION 'WZmainform SCRABBLE ZOEK'}

procedure TWZmainform.ScrabbleSearch(FWoord: string);
begin
    //ResultList.Free;
    ResultList := doscrabblezoek(normalize_string(change_ij(Edit1.text)));
    //workerthread.Terminate;
end;

procedure TWZmainform.terminatescrabblezoek(Sender: TObject);
begin
    AssignToListBox1(ResultList);
    SetBottomText(nil);
    stopwork;
    FreeAndNil(ResultList);
end;

procedure TWZmainform.ScrabbleClick(Sender: TObject);
var
    c: char;
    orig: string;
begin
    if Assigned(workerthread) and (workerthread.Terminated = false) then
    begin
        StopAndClearClick(nil);
        exit;
    end;
    if Edit1.text.Length < 2 then
    begin
        ShowMessage('minstens 2 letters!');
        exit;
    end;
    ListView1.Items.Clear;
    for c in Edit1.text do
    begin
        if not(c.IsLetter or (c = '.')) then
        begin
            ShowMessage('alleen letters en .');
            exit;
        end;
    end;
    orig := normalize_string(WZmainform.change_ij(Edit1.text));
    workerthread := TWorkerThread.Create(orig, scrabblezoek);  //true = anagram search
    workerthread.OnTerminate := terminatescrabblezoek;
    workerthread.Start;
    startwork('scrabbles');
end;

function TWZmainform.doscrabblezoek(const zoekletters: string): TStringList;
var
    gesorteerd, target: string;
    n, wildcards: integer;
    zwindex, lstindex: integer;
    found: boolean;
    c: Char;
begin
    Result := TStringList.Create;
    Result.Sorted := false;
    gesorteerd := sorteer_letters(zoekletters);
    if gesorteerd = '' then
    begin
        ShowMessage('minstens 1 letter!');
        exit;
    end;
    SetLength(gesorteerd, gesorteerd.Length - WildcardsFound);
    for n := 0 to OpLetterGesorteerdeWoorden.Count - 1 do
    begin
        wildcards := WildcardsFound; // output par. van sorteer_letters
        target := OpLetterGesorteerdeWoorden[n].str;
        if gesorteerd.Length + wildcards < target.Length then continue;
        zwindex := low(gesorteerd);
        lstindex := low(target);
        found := true;
        while lstindex <= high(target) do
        begin
            if gesorteerd[zwindex] = target[lstindex] then
            begin
                inc(zwindex);
                inc(lstindex);
                continue;
            end else if ord(gesorteerd[zwindex]) < ord(target[lstindex]) then
            begin
                inc(zwindex);
                continue;
            end else if wildcards > 0 then
            begin
                dec(wildcards);
                inc(lstindex);
                continue;
            end else begin
                found := false;
                break;
            end;
        end;
        if found and (lstindex > high(target)) then // gevonden
        begin
            target := AlleWoorden[OpLetterGesorteerdeWoorden[n].index];
            if target <> '' then Result.Add(target);
        end;
    end;
    reverse_length_sort := -1;
    Result.CustomSort(AlfOpLenSort);
    reverse_length_sort := 1;
end; // remember to free Result

procedure TWZmainform.WoordLengteComboChange(Sender: TObject);
var
    al_index: integer;
begin
    if WoordLengteCombo.Items.Count = 0 then exit;
    al_index := StrToInt(WoordLengteCombo.Items[WoordLengteCombo.ItemIndex]);
    if al_index >= 0 then
    begin
        load_a_certain_length(al_index);
        SetBottomText(nil);
    end;
end;

function CompareWoordIndex(const Left, Right: TWoordIndex): integer;
begin
    Result := AnsiCompareText(Left.str, Right.str);
end;

procedure TWZmainform.maak_sol_lijst(Sender: TObject);
var
    n: integer;
    s1, s2: string;
    wrd: TWoordIndex;
    Comparison: TComparison<TWoordIndex>;
begin
    Comparison := CompareWoordIndex;
    if OpLetterGesorteerdeWoorden = nil then OpLetterGesorteerdeWoorden := TList<TWoordIndex>.Create
    else OpLetterGesorteerdeWoorden.Clear;
    for n := 0 to AlleWoorden.Count - 1 do
    begin
        s1 := AlleWoorden[n];
        s2 := sorteer_letters(normalize_string(s1));
        wrd.str := s2; // add to tarray
        wrd.index := n;
        OpLetterGesorteerdeWoorden.Add(wrd)
    end;
    OpLetterGesorteerdeWoorden.Sort(TComparer<TWoordIndex>.Construct(Comparison));
end;

function TWZmainform.sorteer_letters(const s: string): string; // sorteer letters IN een woord
var // s must be normalized
    n, arrayindex, charindex: integer;
    letter: Char;
    resultarray: array of Char;
begin
    Result := '';
    WildcardsFound := 0;
    for n := low(s) to high(s) do
    begin
        letter := s[n];
        if letter = ' ' then continue; // ignore

        if letter = '.' then inc(WildcardsFound) // wildcards (scrabble blanco) in global output par
        else
        begin
            if letter = 'ĳ' then charindex := IJCHARINDEX
            else
            begin
                charindex := ord(letter) - ord('a');
            end;
            inc(lettersorteerarray[charindex]);
        end;
    end;
    SetLength(resultarray, s.Length);
    arrayindex := 0;
    for n := 0 to high(lettersorteerarray) do
    begin
        while lettersorteerarray[n] > 0 do
        begin
            if n = IJCHARINDEX then charindex := ord('ĳ')
            else charindex := n + ord('a');
            letter := chr(charindex);
            resultarray[arrayindex] := letter;
            inc(arrayindex);
            dec(lettersorteerarray[n]); // array zero'ed here
        end;
    end;
    SetLength(resultarray, arrayindex);
    Result := ArrayToString(resultarray);
end;

procedure TWZmainform.ZetWoordLengteCombo;
var
    index, newlen, len: integer;
begin
    len := 0;
    WoordLengteCombo.Items.Clear;
    for index := 0 to LenSortedList.Count - 1 do
    begin
        newlen := LenSortedList[index].Length;
        if newlen <> len then
        begin
            WoordLengteCombo.Items.Add(IntToStr(newlen));
            len := newlen;
        end;
    end;
end;

{$ENDREGION}

{$REGION 'WZmainform PATTERN ZOEK'}

procedure TWZmainform.ZoekButtonClick(Sender: TObject);
begin
    if Assigned(workerthread) and (workerthread.Terminated = false) then
    begin
        StopAndClearClick(nil);
        exit;
    end;
    if Edit1.text = '' then
    begin
        ListView1.Items.Clear;
        AssignToListBox1(HelpText);
    end else begin
        SetBottomInfo(0,0);
        PatternSearch(normalize_string(change_ij(Edit1.text)));
    end;
end;

procedure TWZmainform.PatternSearch(const Woord: string);
begin
    workerthread := TWorkerThread.Create(Woord, woordzoek);
    workerthread.OnTerminate := terminatezoekactie;
    //workerthread.Priority := tpLower;
    workerthread.Start;
    startwork('woorden');
end;

procedure TWZmainform.selecteer(const Woord: string);
var
    n: integer;
    zoekwoordindex, lijstwoordindex: integer;
    zoekwoordlen, lijstwoordlen: integer;
    saveZWindex: integer;
    found, shifting: boolean;
    ZoekWoord, lijstwoord, origwoord: string;
    zc, lc: Char;
begin
    TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
            WZmainform.ListView1.Items.Clear;
            SetBottomInfo(0,0);
        end);
    with WZmainform do
    begin
        ZoekWoord := AnsiLowerCase(Woord);
        zoekwoordlen := high(ZoekWoord);
        for n := 0 to AlleWoorden.Count - 1 do
        begin
            if workerthread.Terminated = true then break;
//{$IFDEF MSWINDOWS}
//            Image7.Repaint;
//            Application.ProcessMessages;
//{$ENDIF}
            zoekwoordindex := low(ZoekWoord);
            // strings are 0-based in mobile platf., 1-based in desktop!
            lijstwoordindex := low(lijstwoord);
            saveZWindex := -1;
            origwoord := AlleWoorden.Strings[n];
            lijstwoord := normalize_string(origwoord);
            lijstwoordlen := high(lijstwoord);
            shifting := false;

            repeat
            begin
                zc := Char(ZoekWoord[zoekwoordindex]);
                lc := Char(lijstwoord[lijstwoordindex]);

                if (zc = lc) or (zc = '.') then
                begin
                    zoekwoordindex := zoekwoordindex + 1;
                    lijstwoordindex := lijstwoordindex + 1;
                    shifting := false;
                    continue;
                end;
                if zc = '*' then
                begin
                    shifting := true;
                    zoekwoordindex := zoekwoordindex + 1;
                    saveZWindex := zoekwoordindex;
                    continue;
                end;
                { letters ongelijk: }
                if shifting = true then
                begin
                    lijstwoordindex := lijstwoordindex + 1;
                    if lijstwoordindex > lijstwoordlen then shifting := false;
                    continue;
                end else begin
                    if saveZWindex >= 0 then
                    begin
                        zoekwoordindex := saveZWindex;
                        shifting := true;
                        continue;
                    end
                    else break; // niet gevonden - exit
                end;
            end;
            until (lijstwoordindex > lijstwoordlen) or (zoekwoordindex > zoekwoordlen);

            if (lijstwoordindex > lijstwoordlen) and (zoekwoordindex > zoekwoordlen) then found := true
            else if ((shifting or (ZoekWoord[zoekwoordlen] = '*')) and (zoekwoordindex >= zoekwoordlen)) then found := true
            else found := false;

            if found then
            begin
                TThread.Synchronize(TThread.CurrentThread,
                    procedure()
                    begin
                        Image7.Repaint;
                        Application.ProcessMessages;
                        ListView1.Items.Add.text := origwoord;
                        if ListView1.Items.Count mod 100 = 0 then SetBottomText(nil);
                    end);
            end;
        end; // for-alle woorden
    end;
end;

{$ENDREGION}

{$REGION 'WZmainform KEYBOARD'}

procedure TWZmainform.MyKeyBoardClick(Sender: TObject; var Key: Char; KeyCode: integer; var KeyType: TKeyType);
var // see also TMyKeyBoard.MyKeyClick
    s: string;
    currEdit: TEdit;
begin
    currEdit := TEdit(MyKeyboard.getCurrTarget);
    case KeyType of
        ktNormal:
            begin
                if currEdit.Name <> 'Edit1' then
                begin // just add keys in front or at back
                    s := currEdit.text;
                    if is_retro_button.IsPressed then s := Key + s
                    else s := s + Key;
                    currEdit.text := s;
                    KeyType := ktIgnoreKey;
                end;
            end;
        ktDone:
            begin
                KBpanel.AnimateFloat('Height', 0, 0.25);
                KeyType := ktIgnoreKey;
            end;
        ktDel:
            begin
                // if currEdit.Name <> 'Edit1' then
                // begin
                s := currEdit.text;
                if s = '' then exit;
                if (currEdit.Name = 'SortedLetterEdit') and is_retro_button.IsPressed then s := s.Substring(1)
                else s := s.Substring(0, s.Length - 1);
                currEdit.text := s;
                KeyType := ktIgnoreKey;
                // end
                // else Key := chr(VK_BACK);//#46; //delete
            end;
        ktFunction:
            begin
                currEdit.text := '';
            end;
    end;
end;

procedure TWZmainform.CreateKeyBoard;
var
    kbinfo: TKeyBoardInfo;
begin
    with kbinfo do
    begin
        KeyBoard := [KB1DATA, KB1TYPE, KB1KEYS];
        fontsize := 20;
        KeyHeight := 32;
        KeyWidth := 48; // width values ignored if scaled layout
        BGcolor := TAlphaColorRec.Darkblue;
        FGcolor := TAlphaColorRec.Lightblue;
        Keymargin := 4;
        Rowmargin := 4;
        KeyAlign := TAlignLayout.scale;
        RowAlign := TAlignLayout.Top;
        KeyStyle := 'speedbuttonstyle';
        // ImageList := ImageList1;
    end;

    MyKeyboard := TMyKeyBoard.Create(KBpanel, kbinfo);
    KBheight := Trunc(MyKeyboard.GetHeight);
    MyKeyboard.Align := TAlignLayout.Client;
    KBpanel.Height := KBheight;
    MyKeyboard.OnKeyClick := MyKeyBoardClick;
    MyKeyboard.SetTarget(Edit1);
    FormResize(nil);
end;

{$ENDREGION}

{$REGION 'COMPILE TIME SETUP (commented out)'}
//
//procedure TWZmainform.zoekanagramClick
//(Sender: TObject);
//
//var
//    s, ana: string;
//    X, index, minindex: integer;
//    foundindex: integer;
//    list: TStringList;
//    c: Char;
//    found: boolean;
//    item: TWoordIndex;
//    Comparison: TComparison<TWoordIndex>;
//
//begin
//    Comparison := CompareWoordIndex;
//
//    s := sorteer_letters(normalize_string(change_ij(Edit1.text)));
//    for c in s do
//    begin
//        if not c.IsLetter then
//        begin
//            ShowMessage('alleen letters!');
//            exit;
//        end;
//    end;
//
//    list := TStringList.Create;
//    list.Sorted := true;
//    list.Duplicates := dupAccept;
//    item.str := s;
//    item.index := 0;
//    found := OpLetterGesorteerdeWoorden.BinarySearch(item, index, TComparer<TWoordIndex>.Construct(Comparison));
//    minindex := index - 1;
//    if found then
//    begin
//        repeat
//            ana := AlleWoorden[OpLetterGesorteerdeWoorden[index].index];
//            list.Add(ana);
//            inc(index);
//        until (index < OpLetterGesorteerdeWoorden.Count) and (OpLetterGesorteerdeWoorden[index].str <> s);
//        while (minindex >= 0) and (OpLetterGesorteerdeWoorden[minindex].str = s) do // volgens de documentatie is dit nodig
//        begin
//            ana := AlleWoorden[OpLetterGesorteerdeWoorden[minindex].index];
//            list.Add(ana);
//            dec(minindex);
//        end;
//
//    end;
//    AssignToListBox1(list);
//    SetBottomText(nil);
//    list.Free;
//end;

// create a 2-dimensional array [index - of - letter1, i - o - letter2] of the startindex for all beginletter pairs
//(aa, ab, .. .zy) in the AlleWoorden list.Used bij find_prefix()a complication is 'ĳ' which is one letter
//    (not fitting the ord())but counts as 2 and is Sorted as i + j
//procedure TWZmainform.CreateLetterIndex
//    (var list: TStringList);
//
//var
//    letter1, letter2, newletter1, newletter2: Char;
//    index1, index2, listindex: integer;
//    s: string;
//
//begin
//    letter1 := 'a';
//    letter2 := 'a';
//    newletter2 := '?'; // dummy init.
//    index1 := 0;
//    index2 := 0;
//    for listindex := 0 to list.Count - 1 do
//    begin
//        s := normalize_string(list.Strings[listindex]);
//        newletter1 := s[low(s)];
//        if newletter1 <> letter1 then // change of first letter
//        begin
//            // count 'ĳ' as 'i'+'j'
//            if newletter1 = 'ĳ' then // change to 'ĳ'
//            begin // continue first letter like nothing happened
//                newletter2 := 'j';
//                letter1 := 'ĳ'; // but remember it
//            end else if letter1 = 'ĳ' then // change from 'ĳ'
//            begin
//                letter1 := 'i';
//                // again, continue first letter like nothing happened
//                // newletter2 will be found below
//            end else begin // normal letters
//                index1 := index1 + (ord(newletter1) - ord(letter1));
//                // skip unused letters
//                letter1 := newletter1; // remember new first letter
//                letter2 := 'a'; // reset second letter index
//                index2 := 0;
//                LetterIndex[index1, index2] := listindex;
//                // set [first-letter-index, 0]
//            end;
//        end;
//        // change of second letter:
//        if letter1 <> 'ĳ' then newletter2 := s[low(s) + 1];
//        // if letter1 = 'ĳ', newletter2 already set to 'j'
//        if newletter2 <> letter2 then // second letter change
//        begin
//            if (newletter2 = 'ĳ') or (letter2 = 'ĳ') then // change to & from
//            begin
//                letter2 := 'i'; // pretend nothing happened
//                continue; // do not write index
//            end;
//            index2 := index2 + (ord(newletter2) - ord(letter2)); // skip
//            letter2 := newletter2; // remember second letter
//            LetterIndex[index1, index2] := listindex;
//            // set [first-letter-index, second-letter-index]
//        end;
//    end;
//end;

// procedure TWZmainform.StopAndClearClick(Sender: TObject);
// var
// i, nxt: integer;
// first, equal: string;
// found: Boolean;
// anacount: integer;
// begin
// Indicator1.Enabled := true;
// Indicator1.Visible := true;
// ListView1.Items.Clear;
// i := 0;
// anacount := 0;
// while i < OpLetterGesorteerdeWoorden.Count - 1 do
// begin
// first := OpLetterGesorteerdeWoorden[i].str;
// nxt := i + 1;
// equal := OpLetterGesorteerdeWoorden[nxt].str;
// found := false;
// while (first = equal) and (nxt < OpLetterGesorteerdeWoorden.Count) do
// begin
// if nxt - i = 1 then ListView1.Items.Add.text := AlleWoorden[OpLetterGesorteerdeWoorden[i].index];
// ListView1.Items.Add.text := AlleWoorden[OpLetterGesorteerdeWoorden[nxt].index];
// inc(nxt);
// inc(anacount);
// equal := OpLetterGesorteerdeWoorden[nxt].str;
// found := true;
// end;
// if found then
// begin
// ListView1.Items.Add.text := '';
// i := nxt;
// end
// else inc(i);
// end;
// BottomText.text := IntToStr(anacount) + ' woorden';
// Indicator1.Enabled := false;
// Indicator1.Visible := false;
// end;

//procedure TWZmainform.sorteerWoorden;
//var
//    index, len, newlen: integer;
//
//begin
//    if AlleWoorden.Count = 0 then exit;
//    AlleWoorden.Sorted := false;
//    AlleWoorden.CustomSort(RetrogradeSort);
//    AlleWoorden.SaveToFile('resultretro.txt');
//    AlleWoorden.CustomSort(AlfOpLenSort);
//    AlleWoorden.SaveToFile('resultalf.txt');
//end;
//

// procedure TWZmainform.SorteerAlleWoorden(sortering: Integer);
// begin
// Gesorteerd.Clear;
// Gesorteerd.SetStrings(AlleWoorden);
// case sortering of
// 0:
// begin
// Gesorteerd.Sort;
// // .SetStrings(AlleWoorden);
// end;
// 1:
// begin
// Gesorteerd.CustomSort(AlfOpLenSort);
// end;
//
// 2:
// begin
// Gesorteerd.CustomSort(AlfOpLenSort);
// end;
// end;
// // CustomList.Lines.SetStrings(Gesorteerd);
// end;

// procedure TWZmainform.removelijstmetnamen;
// var
// temp, namen: TStringList;
// filenaam, naam: string;
// index, foundindex: integer;
// begin
// namen := TStringList.Create;
// namen.Sorted := true;
// namen.Duplicates := dupIgnore;
// namen.CaseSensitive := false;
// // filenaam := DocumentsPath + 'voornamen.txt';
// while OpenDialog1.Execute do
// begin
// namen.LoadFromFile(OpenDialog1.FileName);
// for index := 0 to namen.Count - 1 do
// begin
// naam := namen[index];
// foundindex := binsearch(naam, AlleWoorden);
// if foundindex < 0 then continue;
// while AlleWoorden[foundindex][1].isUpper and AnsiStartsText(naam, AlleWoorden[foundindex]) do
// begin
// AlleWoorden.Delete(foundindex);
// // this makes foundindex point to the next one
// end;
// end;
// end;
// filenaam := DocumentsPath + 'zondernamen.txt';
// AlleWoorden.SaveToFile(filenaam);
// namen.Free;
// end;

// procedure TWZmainform.loadcharlist;
// var
// temp: TArray<string>;
// charfile: TextFile;
// text: string;
// begin
// AssignFile(charfile, DocumentsPath + 'usedchars.txt');
// FileMode := fmOpenRead;
// ReSet(charfile);
// while not Eof(charfile) do
// begin
// ReadLn(charfile, text);
// temp := text.Split([';']);
// charlist.AddPair(temp[0], '$' + temp[4].Substring(0, 4));
// // zie usedchars.txt
// end;
// CloseFile(charfile);
// charlist.SaveToFile(DocumentsPath + 'conversionchars.txt');
// end;
// *)

// function TryGetClipboardService(out _clp: IFMXClipboardService): Boolean;
// begin
// Result := TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService);
// if Result then _clp := IFMXClipboardService(TPlatformServices.Current.GetPlatformService(IFMXClipboardService));
// end;
//
// procedure StringToClipboard(const _s: string);
// var
// clp: IFMXClipboardService;
// begin
// if TryGetClipboardService(clp) then clp.SetClipboard(_s);
// end;
//
// procedure StringFromClipboard(out _s: string);
// var
// clp: IFMXClipboardService;
// Value: TValue;
// s: string;
// begin
// if TryGetClipboardService(clp) then begin
// Value := clp.GetClipboard;
// if not Value.TryAsType(_s) then
// _s := '';
// end;
// end;

//procedure TWZmainform.create_woordenlijst; // if using this, remember to reload AlleWoorden
//var
//    filenaam: string;
//    text: string;
//    wc, ix1, ix2, l_index: integer;
//    temp: TStringList;
//    letter1, letter2: Char;
//    startindex: integer;
//begin
//    temp := TStringList.Create;
//    temp.Sorted := true;
//    temp.Duplicates := dupIgnore;
//    temp.CaseSensitive := false;
//    AlleWoorden.Clear;
//    while OpenDialog1.Execute do
//    begin
//        temp.LoadFromFile(OpenDialog1.FileName);
//        for wc := 0 to temp.Count - 1 do
//        begin
//            // voeg woordenlijsten samen en verwijder woorden met ' . - spatie cijfers
//            // text := normalize_string(temp.Strings[wc]);
//            text := normalize_string(change_ij(temp.Strings[wc]));
//
//            // letter1 := text[1];
//            // letter2 := text[2];
//            // if text.Length <> 2 then continue;
//            //
//            //
//            // // selecteer alleen woorden die met een hoofdletter beginnen
//            // if not ((letter1 = 'ĳ') or (letter2 = 'ĳ'))  then continue;
//            // (((letter1 >= 'a') and(letter1 <='z')) and ((letter2 >= 'a') and (letter2 <='z')))
//
//            AlleWoorden.Add(text);
//        end;
//    end;
//    filenaam := DocumentsPath + 'woorden.txt';
//    AlleWoorden.SaveToFile(filenaam, TEncoding.UTF8);
//    temp.Free;
//end;
{$ENDREGION}
end.
