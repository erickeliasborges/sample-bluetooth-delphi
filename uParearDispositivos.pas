unit uParearDispositivos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, uChatManager,
  System.Bluetooth, FMX.Controls.Presentation;

type
  TfrmParearDispositivos = class(TForm)
    lbNovosDispositivos: TListBox;
    btnProcurarDispositivos: TButton;
    btnParear: TButton;
    btnSair: TButton;
    procedure btnSairClick(Sender: TObject);
    procedure btnProcurarDispositivosClick(Sender: TObject);
    procedure btnParearClick(Sender: TObject);
  private
    procedure AoFinalizarProcura(const Sender: TObject; const AListaDispositivos: TBluetoothDeviceList);
  public
    ChatManager: TChatManager;
  end;

var
  frmParearDispositivos: TfrmParearDispositivos;

implementation

{$R *.fmx}

procedure TfrmParearDispositivos.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmParearDispositivos.btnProcurarDispositivosClick(Sender: TObject);
begin
  ChatManager.OnDiscoveryEnd := AoFinalizarProcura;
  ChatManager.DiscoverDevices;
end;

procedure TfrmParearDispositivos.btnParearClick(Sender: TObject);
begin
  if lbNovosDispositivos.Selected <> nil then
    ChatManager.PairTo(lbNovosDispositivos.Selected.Text);
end;

procedure TfrmParearDispositivos.AoFinalizarProcura(const Sender: TObject; const AListaDispositivos: TBluetoothDeviceList);
begin
  TThread.Synchronize(nil, procedure
  var
    I: Integer;
  begin
    lbNovosDispositivos.Items.Clear;
    for I := 0 to AListaDispositivos.Count - 1 do
      if AListaDispositivos[I].IsPaired then
        lbNovosDispositivos.Items.Add(AListaDispositivos[I].DeviceName + ' (Pareado)')
      else
        lbNovosDispositivos.Items.Add(AListaDispositivos[I].DeviceName);
  end);
end;

end.
