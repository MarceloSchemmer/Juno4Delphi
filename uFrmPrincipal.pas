unit uFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, System.JSON, FMX.WebBrowser, FMX.Edit,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,ShellApi,
  Winapi.Windows;

type
  TFrmPrincipal = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    lblResposta: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Edit3: TEdit;
    Button6: TButton;
    NetHTTPClient1: TNetHTTPClient;
    Button7: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);

  private
    procedure ParseJSONResposta(sDados:String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  uJuno;

{$R *.fmx}

procedure TFrmPrincipal.Button1Click(Sender: TObject);
var
 Boletofacil : TJuno;
begin
  Boletofacil := TJuno.Create();
  Boletofacil.Description  := 'teste';
//  Boletofacil.amount       := 10.00;                       //-> Não usa amount em boleto parcelado
  Boletofacil.payerName    := 'TESTE';                       //-> nome comprador
  Boletofacil.payerCpfCnpj := '05677097950';                 //-> cpf/cnpj comprador
  Boletofacil.totalAmount  := 10.00;                         //-> valor total das parcelas
  Boletofacil.installments := 2;                             //-> quantidade de parcelamento
  Boletofacil.paymentTypes := 'BOLETO,CREDIT_CARD';          //-> tipo de pagamento boleto / cartao /boleto e cartao
  Boletofacil.notifyPayer  := True;                          //-> notificar pagador via e-mail
  Boletofacil.payerEmail   := 'marceloschemmer1@gmail.com';  //-> e-mail pagador
  ParseJSONResposta(Boletofacil.CriarCobranca());
end;

procedure TFrmPrincipal.Button2Click(Sender: TObject);
var
 Boletofacil : TJuno;
begin
  Boletofacil := TJuno.Create();
  Boletofacil.Description  := 'teste';
  Boletofacil.amount       := 10.00;                         //-> valor total
  Boletofacil.payerName    := 'TESTE';                       //-> nome comprador
  Boletofacil.payerCpfCnpj := '05677097950';                 //-> cpf/cnpj comprador
  Boletofacil.reference    := '123456789';
  ParseJSONResposta(Boletofacil.CriarCobranca());
end;

procedure TFrmPrincipal.Button3Click(Sender: TObject);
var
 Boletofacil : TJuno;
begin
  Boletofacil := TJuno.Create();
  Boletofacil.Description    := 'teste';
  Boletofacil.amount         := 10.00;                         //-> valor total
  Boletofacil.payerName      := 'TESTE';                       //-> nome comprador
  Boletofacil.payerCpfCnpj   := '05677097950';                 //-> cpf/cnpj comprador
  Boletofacil.reference      := '123456789';                   //-> Código de referência da cobrança
  Boletofacil.discountAmount := 5.00;                          //-> Valor do desconto.
  Boletofacil.discountDays   := 1;                             //-> dias do desconto.
  ParseJSONResposta(Boletofacil.CriarCobranca());
end;

procedure TFrmPrincipal.Button5Click(Sender: TObject);
var
 Boletofacil : TJuno;
begin
  Boletofacil      := TJuno.Create();
  Boletofacil.code := '173595197';
  ParseJSONResposta(Boletofacil.CriarCobranca());
end;

procedure TFrmPrincipal.Button6Click(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      LResponse: TMemoryStream;
    begin
      LResponse := TMemoryStream.Create;
      NetHTTPClient1.Get(Edit3.Text, LResponse);
      TThread.Synchronize(Nil,
        procedure
        begin
          try
           LResponse.SaveToFile('./teste.PDF');

          finally
            LResponse.DisposeOf;
          end;
        end);
    end).Start;
end;

procedure TFrmPrincipal.Button7Click(Sender: TObject);
begin
ShellExecute(0, 'print', PChar(IncludeTrailingPathDelimiter(ExtractFilePath('.\')) + 'teste.PDF'), nil, nil, SW_HIDE);
end;

procedure TFrmPrincipal.ParseJSONResposta(sDados: String);
VAR
 JSONObject      : TJSONObject;
 PairData        : TJSONPair;
 JSONArrayData   : TJSONArray;
 JSONObjectData  : TJSONObject;
begin
  JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(sDados),0) as TJSONObject;

  if JSONObject.GetValue<boolean>('success') = true then
  begin
    lblResposta.Text := 'Sucesso!';
  end
  else
  begin
    lblResposta.Text := 'Erro!';
    Exit;
  end;

  PairData       :=  JSONObject.Get('data');

  JSONObjectData :=  PairData.JsonValue as TJSONObject;

  JSONArrayData  :=  JSONObjectData.GetValue('charges') as TJSONArray;

  Edit1.Text     := JSONArrayData.Get(0).GetValue<string>('checkoutUrl');
  Edit2.Text     := JSONArrayData.Get(0).GetValue<string>('link');
  Edit3.Text     := JSONArrayData.Get(0).GetValue<string>('installmentLink');

end;

end.
