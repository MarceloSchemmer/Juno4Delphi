{
  ********************************************************************************************
                             [Integração Boleto fácil (Juno) api v1.0]
       - Versão 1.0
       - Desenvolvimento 17/01/2021
       - Autor Marcelo Schemmer
  ********************************************************************************************
}
unit uJuno;

interface

uses
  System.SysUtils,REST.Client,REST.Types,System.JSON, FMX.Dialogs;

type
  TJuno = class

    private
    FbillingAddressStreet: String;
    FdiscountAmount: Currency;
    FnotificationUrl: String;
    FbillingAddressState: String;
    FpayerPhone: String;
    FpayerCpfCnpj: String;
    Finterest: Currency;
    FcreditCardStore: Boolean;
    FreferralToken: String;
    FsplitRecipient: String;
    FbillingAddressComplement: String;
    FbillingAddressNumber: String;
    FdiscountDays: Integer;
    Famount: Currency;
    FcreditCardHash: String;
    Fdescription: String;
    FpayerSecondaryEmail: String;
    FbillingAddressNeighborhood: String;
    FbillingAddressPostcode: String;
    FbillingAddressCity: String;
    FpaymentTypes: String;
    FfeeSchemaToken: String;
    FresponseType: String;
    FpayerBirthDate: String;
    Finstallments: Integer;
    FpayerName: String;
    FDueDate: String;
    Freference: String;
    FnotifyPayer: Boolean;
    FpaymentAdvance: Boolean;
    FcreditCardId: String;
    Ffine: Currency;
    FpayerEmail: String;
    FmaxOverdueDays: Integer;
    FtotalAmount: Currency;
    Fcode: String;
    const sToken   : string = 'DC7F26BEE79C727FCB73831AEE958957D7F2B05E2E28671051364058409930A0'; //-> Token privado
    const sUrlBase : string = 'https://www.boletobancario.com/boletofacil/integration/api/v1/';   //-> url base de envio
    public
    property description                : String   read Fdescription                write Fdescription;                //->
    property reference                  : String   read Freference                  write Freference;                  //->
    property amount                     : Currency read Famount                     write Famount;                     //->
    property totalAmount                : Currency read FtotalAmount                write FtotalAmount;                //->
    property dueDate                    : String   read FDueDate                    write FDueDate;                    //->
    property installments               : Integer  read Finstallments               write Finstallments;               //->
    property maxOverdueDays             : Integer  read FmaxOverdueDays             write FmaxOverdueDays;             //->
    property fine                       : Currency read Ffine                       write Ffine;                       //->
    property Interest                   : Currency read Finterest                   write Finterest;                   //->
    property discountAmount             : Currency read FdiscountAmount             write FdiscountAmount;             //->
    property discountDays               : Integer  read FdiscountDays               write FdiscountDays;               //->
    property payerName                  : String   read FpayerName                  write FpayerName;                  //->
    property payerCpfCnpj               : String   read FpayerCpfCnpj               write FpayerCpfCnpj;               //->
    property payerEmail                 : String   read FpayerEmail                 write FpayerEmail;                 //->
    property payerSecondaryEmail        : String   read FpayerSecondaryEmail        write FpayerSecondaryEmail;        //->
    property payerPhone                 : String   read FpayerPhone                 write FpayerPhone;                 //->
    property payerBirthDate             : String   read FpayerBirthDate             write FpayerBirthDate;             //->
    property billingAddressStreet       : String   read FbillingAddressStreet       write FbillingAddressStreet;       //->
    property billingAddressNumber       : String   read FbillingAddressNumber       write FbillingAddressNumber;       //->
    property billingAddressComplement   : String   read FbillingAddressComplement   write FbillingAddressComplement;   //->
    property billingAddressNeighborhood : String   read FbillingAddressNeighborhood write FbillingAddressNeighborhood; //->
    property billingAddressCity         : String   read FbillingAddressCity         write FbillingAddressCity;         //->
    property billingAddressState        : String   read FbillingAddressState        write FbillingAddressState;        //->
    property billingAddressPostcode     : String   read FbillingAddressPostcode     write FbillingAddressPostcode;     //->
    property notifyPayer                : Boolean  read FnotifyPayer                write FnotifyPayer;                //->
    property notificationUrl            : String   read FnotificationUrl            write FnotificationUrl;            //->
    property responseType               : String   read FresponseType               write FresponseType;               //->
    property feeSchemaToken             : String   read FfeeSchemaToken             write FfeeSchemaToken;             //->
    property splitRecipient             : String   read FsplitRecipient             write FsplitRecipient;             //->
    property referralToken              : String   read FreferralToken              write FreferralToken;              //->
    property paymentTypes               : String   read FpaymentTypes               write FpaymentTypes;               //->
    property creditCardHash             : String   read FcreditCardHash             write FcreditCardHash;             //->
    property creditCardStore            : Boolean  read FcreditCardStore            write FcreditCardStore;            //->
    property creditCardId               : String   read FcreditCardId               write FcreditCardId;               //->
    property paymentAdvance             : Boolean  read FpaymentAdvance             write FpaymentAdvance;             //->
    property code                       : String   read Fcode                       write Fcode;                       //->


    function CriarCobranca():String;
    function CancelarCobranca():String;
    function RequestDados(sEndpoint,sJSONDados:String):String;
  end;

implementation

{ TJuno }

function TJuno.CancelarCobranca: String;
var
 JSONArray  : TJSONArray;
 JSONObject : TJSONObject;
begin
 if code = Trim('') then
 begin
   Result := 'Não foi passado os dados mínimos para o cancelamento';
   Exit;
 end;

 JSONArray := TJSONArray.Create;
 JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('token' ,TJSONString.Create(sToken))));
 JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('code'  ,TJSONString.Create(code))));

 //Criando objeto para o envio...
 JSONObject := TJSONObject.Create;
 JSONObject.AddPair('Dados',JSONArray);
 Result := RequestDados('cancel-charge',JSONObject.ToString);
end;

function TJuno.CriarCobranca(): String;
var
 JSONArray  : TJSONArray;
 JSONObject : TJSONObject;
 sResponse  : String;
begin
  try
    //Validação dos dados mínimos...
    if
     (Description  = Trim('')) or
     (payerName    = Trim('')) or
     (payerCpfCnpj = Trim(''))
    then
    begin
      Result := 'Não foi passado os dados mínimos para a cobrança';
      Exit;
    end;

    JSONArray := TJSONArray.Create;
    JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('token'       , TJSONString.Create(sToken))));
    JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('description' , TJSONString.Create(description))));
    JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('payerName'   , TJSONString.Create(payerName))));
    JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('payerCpfCnpj', TJSONString.Create(payerCpfCnpj))));

    if amount <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('amount'      , TJSONNumber.Create(amount))));

    if reference <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('reference', TJSONString.Create(reference))));

    if totalAmount <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('totalAmount', TJSONNumber.Create(totalAmount))));

    if dueDate <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('dueDate', TJSONString.Create(dueDate))));

    if installments <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('installments', TJSONNumber.Create(installments))));

    if maxOverdueDays <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('maxOverdueDays', TJSONNumber.Create(maxOverdueDays))));

    if fine <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('fine', TJSONNumber.Create(fine))));

    if interest <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('interest', TJSONNumber.Create(interest))));

    if discountAmount <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('discountAmount', TJSONNumber.Create(discountAmount))));

    if discountDays <> 0 then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('discountDays', TJSONNumber.Create(discountDays))));

    if payerEmail <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('payerEmail', TJSONString.Create(payerEmail))));

    if payerSecondaryEmail <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('payerSecondaryEmail', TJSONString.Create(payerSecondaryEmail))));

    if payerPhone <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('payerPhone', TJSONString.Create(payerPhone))));

    if payerBirthDate <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('payerBirthDate', TJSONString.Create(payerBirthDate))));

    if billingAddressStreet <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressStreet', TJSONString.Create(billingAddressStreet))));

    if billingAddressNumber <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressNumber', TJSONString.Create(billingAddressNumber))));

    if billingAddressComplement <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressComplement', TJSONString.Create(billingAddressComplement))));

    if billingAddressNeighborhood <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressNeighborhood', TJSONString.Create(billingAddressNeighborhood))));

    if billingAddressCity <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressCity', TJSONString.Create(billingAddressCity))));

    if billingAddressState <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressState', TJSONString.Create(billingAddressState))));

    if billingAddressPostcode <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressPostcode', TJSONString.Create(billingAddressPostcode))));

    if notifyPayer <> False then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('billingAddressPostcode',TJSONTrue.Create)));

    if notificationUrl <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('notificationUrl',TJSONString.Create(notificationUrl))));

    if feeSchemaToken <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('feeSchemaToken',TJSONString.Create(feeSchemaToken))));

    if splitRecipient <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('splitRecipient',TJSONString.Create(splitRecipient))));

    if referralToken <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('referralToken',TJSONString.Create(referralToken))));

    if paymentTypes <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('paymentTypes',TJSONString.Create(paymentTypes))));

    if creditCardHash <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('creditCardHash',TJSONString.Create(creditCardHash))));

    if creditCardStore <> False then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('creditCardStore',TJSONTrue.Create)));

    if creditCardId <> Trim('') then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('creditCardId',TJSONString.Create(creditCardId))));

    if paymentAdvance <> False then
       JSONArray.AddElement(TJSONObject.Create.AddPair(TJSONPair.Create('paymentAdvance',TJSONTrue.Create)));

    //Criando objeto para o envio...
    JSONObject := TJSONObject.Create;
    JSONObject.AddPair('Dados',JSONArray);

    Result := RequestDados('issue-charge',JSONObject.ToString);

  except on E: Exception do
    begin
      Result  := 'Erro ao montar requisição '+E.Message;
    end;
  end;
end;

function TJuno.RequestDados(sEndpoint, sJSONDados: String): String;
var
  JSONObject   : TJSONObject;
  JSONObjectR  : TJSONObject;
  JSONArray    : TJSONArray;
  JSONValue    : TJSONValue;
  x            : Integer;
  RestClient   : TRESTClient;
  Request_Sinc : TRestRequest;
  RESTResponse : TRESTResponse;
begin
  try
    RestClient                      := TRESTClient.Create(sUrlBase+sEndpoint);
    Request_Sinc                    := TRESTRequest.Create(RestClient);
    Request_Sinc.AutoCreateParams   := true;
    Request_Sinc.Client             := RestClient;
    Request_Sinc.HandleRedirects    := true;

    //Obtendo dados de envio...
    JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(sJSONDados), 0) as TJSONObject;
    JSONValue  := JSONObject.Get('Dados').JsonValue;
    JSONArray  := JSONValue as TJSONArray;

    //Adicionando parametros...
    for x := 0 to JSONArray.Count -1 do
    begin
      JSONObjectr := JSONArray.Get(x) as TJsonObject;
      Request_Sinc.AddParameter(JSONObjectr.Pairs[0].JsonString.Value,JSONObjectr.Pairs[0].JsonValue.Value);
    end;

    Request_Sinc.Method             := TRESTRequestMethod.rmGET;
    Request_Sinc.SynchronizedEvents := false;
    Request_Sinc.Timeout            := 30000;
    RESTResponse                    := TRESTResponse.Create(nil);
    Request_Sinc.Response           := RESTResponse;
    Request_Sinc.Execute;

     if RESTResponse.StatusCode = 200 then
      begin
       Result    := RESTResponse.Content;
      end
      else
      begin
       Result    := RESTResponse.Content;      //-> TRATAR ERRO SE NECESSÁRIO
      end;

  except on E: Exception do
   begin
     Result := E.Message;
   end;
  end;
end;

end.
