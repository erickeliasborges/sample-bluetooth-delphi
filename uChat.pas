unit uChat;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox, FMX.StdCtrls, FMX.Edit,
  FMX.Layouts, FMX.Memo, System.Bluetooth, uChatManager, FMX.Controls.Presentation, uParearDispositivos,
  FMX.ScrollBox, FMX.Memo.Types;

type
  TfrmChat = class(TForm)
    memChat: TMemo;
    edNovaMensagem: TEdit;
    panSeleciDispositivo: TPanel;
    cbDispositivos: TComboBox;
    btnAtualizar: TButton;
    panEnviar: TPanel;
    btnProcurar: TButton;
    PnMain: TPanel;
    btnEnviar: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure cbDispositivosChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edNovaMensagemKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure btnProcurarClick(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
  private
    FChatManager: TChatManager;
    FUltimoNome: string;
    procedure AtualizarDispositivos;
    procedure ValidacoesAoEnviarOuReceberMensagemPeloBluetooth(const Sender: TObject; const AMensagem, ANomeDispositivo: string);
    procedure ValidarBluetoothLigado;
    procedure SetMensagemNoChat(const AMensagem, ANomeDispositivo: string);
  public
    { Public declarations }
  end;

var
  frmChat: TfrmChat;

implementation

{$R *.fmx}

procedure TfrmChat.btnEnviarClick(Sender: TObject);
begin
  if cbDispositivos.Selected <> nil then
  begin
    FChatManager.SendText(edNovaMensagem.Text);
    edNovaMensagem.Text := '';
  end;
end;

procedure TfrmChat.btnProcurarClick(Sender: TObject);
begin
  FrmParearDispositivos := TfrmParearDispositivos.Create(nil);
  FrmParearDispositivos.ChatManager := FChatManager;
  FrmParearDispositivos.Show;
end;

procedure TfrmChat.cbDispositivosChange(Sender: TObject);
begin
  FChatManager.SelectedDevice := cbDispositivos.Selected.Index;
end;

procedure TfrmChat.edNovaMensagemKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn then
    btnEnviarClick(btnEnviar);
end;

procedure TfrmChat.ValidarBluetoothLigado;
begin
  if (FChatManager.HasBluetoothDevice) then
    Exit;

  ShowMessage('Voc� n�o possui um adaptador bluetooth ou o mesmo n�o est� ligado.');
  Application.Terminate;
end;

procedure TfrmChat.FormCreate(Sender: TObject);
begin
  FChatManager := TChatManager.Create;
  ValidarBluetoothLigado();
  FChatManager.OnTextReceived := ValidacoesAoEnviarOuReceberMensagemPeloBluetooth;
  FChatManager.OnTextSent := ValidacoesAoEnviarOuReceberMensagemPeloBluetooth;
end;

procedure TfrmChat.ValidacoesAoEnviarOuReceberMensagemPeloBluetooth(const Sender: TObject; const AMensagem, ANomeDispositivo: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      SetMensagemNoChat(AMensagem, ANomeDispositivo)
    end);
end;

procedure TfrmChat.SetMensagemNoChat(const AMensagem, ANomeDispositivo: string);
var
  LDispositivoDiferenteEnviandoMensagem: Boolean;
begin
  LDispositivoDiferenteEnviandoMensagem := (FUltimoNome <> ANomeDispositivo);
  if (LDispositivoDiferenteEnviandoMensagem) then
  begin
    memChat.Lines.Add(' ' + ANomeDispositivo + ' :');
    FUltimoNome := ANomeDispositivo;
  end;

  memChat.Lines.Add('     ' + AMensagem);
  memChat.GoToTextEnd;
end;

procedure TfrmChat.FormShow(Sender: TObject);
begin
  AtualizarDispositivos();
end;

procedure TfrmChat.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  PnMain.align := TAlignLayout.Client;
end;

procedure TfrmChat.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  PnMain.align := TAlignLayout.Top;
  PnMain.Height := ClientHeight - Bounds.height {$IFDEF ANDROID} + 20 {$ENDIF};
  memChat.GoToTextEnd;
end;

procedure TfrmChat.btnAtualizarClick(Sender: TObject);
begin
  AtualizarDispositivos();
end;

procedure TfrmChat.AtualizarDispositivos;
var
  I: Integer;
begin
  cbDispositivos.Clear;
  if FChatManager.KnownDevices <> nil then
    for I := 0 to FChatManager.KnownDevices.Count - 1 do
      cbDispositivos.Items.Add(FChatManager.KnownDevices.Items[I].DeviceName);
end;

end.
