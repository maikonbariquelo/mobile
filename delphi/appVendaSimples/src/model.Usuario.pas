unit model.Usuario;

interface

uses
  UConstantes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TUsuario = class(TObject)
    strict private
      aID      : TGUID;
      aNome    ,
      aEmail   ,
      aSenha   ,
      aCpf     ,
      aCelular ,
      aTokenID : String;
      aAtivo   : Boolean;

      procedure SetNome(Value : String);
      procedure SetEmail(Value : String);
      procedure SetSenha(Value : String);
      procedure SetCpf(Value : String);
      procedure SetCelular(Value : String);
      procedure SetTokenID(Value : String);

      constructor Create();
      class var aInstance : TUsuario;
  private
    FID: TGUID;
    procedure SetID(const Value: TGUID);
    public
      property ID      : TGUID   read FID      write SetID;
      property Nome    : String  read aNome    write SetNome;
      property Email   : String  read aEmail   write SetEmail;
      property Senha   : String  read aSenha   write SetSenha;
      property Cpf     : String  read aCpf     write SetCpf;
      property Celular : String  read aCelular write SetCelular;
      property TokenID : String  read aTokenID write SetTokenID;
      property Ativo   : Boolean read aAtivo   write aAtivo;

      procedure NewID;

      function ToString : String; override;

      class function GetInstance : TUsuario;
  end;

implementation

{ TUsuario }

class function TUsuario.GetInstance: TUsuario;
begin
  if not Assigned(aInstance) then
    aInstance := TUsuario.Create;

  Result := aInstance;
end;

procedure TUsuario.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

constructor TUsuario.Create;
begin
  inherited Create;
  aID      := GUID_NULL;
  aNome    := EmptyStr;
  aEmail   := EmptyStr;
  aSenha   := EmptyStr;
  aCpf     := EmptyStr;
  aCelular := EmptyStr;
  aTokenID := EmptyStr;
  aAtivo   := False;
end;

procedure TUsuario.SetCelular(Value: String);
begin
  aCelular := Trim(Value);
end;

procedure TUsuario.SetCpf(Value: String);
begin
  aCpf := Trim(Value);
end;

procedure TUsuario.SetEmail(Value: String);
begin
  aEmail := AnsiLowerCase(Trim(Value));
end;

procedure TUsuario.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TUsuario.SetNome(Value: String);
begin
  aNome := Trim(Value);
end;

procedure TUsuario.SetSenha(Value: String);
begin
  aSenha := Trim(Value);
end;

procedure TUsuario.SetTokenID(Value: String);
begin
  aTokenID := Trim(Value);
end;

function TUsuario.ToString: String;
begin
  Result := aNome + ' <' + aEmail + '>';
end;

end.
