unit UPedidoItem;

interface

uses
  System.StrUtils,
  System.Math,
  System.Generics.Collections,

  model.Pedido,
  model.PedidoItem,
  dao.PedidoItem,
  dao.Produto,
  interfaces.Produto,
  interfaces.PedidoItem,

  System.SysUtils, System.Classes, System.Actions, System.UITypes, System.Types,
  UPadraoCadastro, FMX.Forms, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.DateTimeCtrls,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Controls, FMX.Types;

type
  TFrmPedidoItem = class(TFrmPadraoCadastro, IObservadorProduto)
    LayoutProduto: TLayout;
    recCliente: TRectangle;
    lytProduto: TLayout;
    LabelProduto: TLabel;
    imgProduto: TImage;
    lblProduto: TLabel;
    iconProduto: TImage;
    lineCliente: TLine;
    lytQuantidade: TLayout;
    lineQuantidade: TLine;
    LabelQuantidade: TLabel;
    imgQuantidade: TImage;
    lblQuantidade: TLabel;
    imgQuantidadeMais: TImage;
    imgQuantidadeMenos: TImage;
    lytValorUnit: TLayout;
    lineValorUnit: TLine;
    LabelValorUnit: TLabel;
    imgValorUnit: TImage;
    lblValorUnit: TLabel;
    procedure DoBuscarProduto(Sender: TObject);
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarItemPedido(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgProdutoClick(Sender: TObject);
    procedure imgQuantidadeMaisClick(Sender: TObject);
    procedure imgQuantidadeMenosClick(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TPedidoItemDao;
    FObservers : TList<IObservadorPedidoItem>;

    procedure AtualizarProduto;
    procedure ControleEdicao(const aEditar : Boolean);

    class var aInstance : TFrmPedidoItem;
  public
    { Public declarations }
    property Dao : TPedidoItemDao read aDao;

    procedure AdicionarObservador(Observer : IObservadorPedidoItem);
    procedure RemoverObservador(Observer : IObservadorPedidoItem);
    procedure RemoverTodosObservadores;
    procedure Notificar;

    class function GetInstance : TFrmPedidoItem;
  end;

  procedure NovoItemPedido(aPedido : TPedido; Observer : IObservadorPedidoItem);
  procedure EditarItemPedido(aPedido : TPedido; Observer : IObservadorPedidoItem);

//var
//  FrmPedidoItem: TFrmPedidoItem;
//
implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem
  , UProduto;

procedure NovoItemPedido(aPedido : TPedido; Observer : IObservadorPedidoItem);
var
  aForm : TFrmPedidoItem;
begin
  aForm := TFrmPedidoItem.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab := tbsCadastro;

    Model.ID     := GUID_NULL;
    Model.Codigo := 0;
    Model.Pedido := aPedido;

    Model.Quantidade    := 1;
    Model.ValorUnitario := 0.0;
    Model.ValorTotal    := 0.0;
    Model.ValorTotalDesconto := 0.0;
    Model.ValorLiquido  := 0.0;

    Model.Produto.ID        := GUID_NULL;
    Model.Produto.Codigo    := 0;
    Model.Produto.Descricao := EmptyStr;
    Model.Produto.Valor     := 0.0;

    labelTituloCadastro.Text      := 'INSERIR ITEM';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO num�rico do registro

    lblProduto.Text    := 'Informe aqui o produto para o pedido';

    lblQuantidade.TagString := ',0.###';
    lblQuantidade.Text      := FormatFloat(lblQuantidade.TagString, Model.Quantidade);
    lblValorUnit.TagString  := ',0.00';
    lblValorUnit.Text       := FormatFloat(lblValorUnit.TagString, Model.ValorUnitario);
    lblDescricao.TagString  := ',0.00';
    lblDescricao.Text       := FormatFloat(lblDescricao.TagString, Model.ValorLiquido);

    lblProduto.TagFloat    := 0; // Flags: 0 - Sem edi��o; 1 - Dado editado
    lblQuantidade.TagFloat := 0;
    lblValorUnit.TagFloat  := 0;
    lblDescricao.TagFloat  := 0;

    lytExcluir.Visible := False;
  end;

  aForm.Show;
end;

procedure EditarItemPedido(aPedido : TPedido; Observer : IObservadorPedidoItem);
begin
  ;
end;

{ TFrmPedidoItem }

procedure TFrmPedidoItem.AdicionarObservador(Observer: IObservadorPedidoItem);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmPedidoItem.AtualizarProduto;
var
  daoProduto : TProdutoDao;
begin
  daoProduto := TProdutoDao.GetInstance;

  lblProduto.Text       := FormatFloat('###00000', daoProduto.Model.Codigo) + ' - ' + daoProduto.Model.Descricao;
  lblProduto.TagString  := GUIDToString(daoProduto.Model.ID);
  lblProduto.TagFloat   := 1;

  lblValorUnit.Text     := FormatFloat(lblValorUnit.TagString, daoProduto.Model.Valor);
  lblValorUnit.TagFloat := 1;

  Dao.Model.Produto       := daoProduto.Model;
  Dao.Model.ValorUnitario := daoProduto.Model.Valor;

  lblDescricao.Text     := FormatFloat(lblDescricao.TagString,  dao.Model.ValorLiquido);
  lblDescricao.TagFloat := IfThen(dao.Model.ValorLiquido <= 0.0, 0, 1);
end;

procedure TFrmPedidoItem.ControleEdicao(const aEditar: Boolean);
begin
  imageSalvarCadastro.Visible := aEditar;
  imageSalvarEdicao.Visible   := aEditar;
end;

procedure TFrmPedidoItem.DoBuscarProduto(Sender: TObject);
begin
  if Dao.Model.Pedido.Tipo = TTipoPedido.tpOrcamento then
    SelecionarProduto(Self);
end;

procedure TFrmPedidoItem.DoEditarCampo(Sender: TObject);
begin
  ;
end;

procedure TFrmPedidoItem.DoSalvarItemPedido(Sender: TObject);
var
  ins : Boolean;
  inf : Extended;
begin
  try
    inf :=
      lblProduto.TagFloat    +
      lblQuantidade.TagFloat +
      lblValorUnit.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    if (lblProduto.TagFloat = 0) or (Trim(lblProduto.Text) = EmptyStr) then
      ExibirMsgAlerta('Selecione um produto para o pedido!')
    else
    begin
      dao.Model.ID     := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo := Round( labelTituloCadastro.TagFloat );

      dao.Model.Produto.ID := StringToGUID( IfThen(lblProduto.TagFloat  = 0, GUIDToString(GUID_NULL), lblProduto.TagString) );  // Postar dados na classe caso ele tenha sido editado
      dao.Model.Quantidade := StrToCurr(lblQuantidade.Text);

      if (lblValorUnit.TagFloat = 0) then
        dao.Model.ValorUnitario := 0.0
      else
        dao.Model.ValorUnitario := StrToCurr(lblValorUnit.Text.Replace('.', '').Replace(',', '')) / 100;

      ins := (dao.Model.ID = GUID_NULL);

      if ins then
        dao.Insert()
      else
        dao.Update();

      Self.Notificar;
      Self.Close;
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o pedido.' + #13 + E.Message);
  end;
end;

procedure TFrmPedidoItem.FormActivate(Sender: TObject);
begin
  inherited;
  ControleEdicao( (Dao.Model.Pedido.Tipo = TTipoPedido.tpOrcamento) );
end;

procedure TFrmPedidoItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  RemoverTodosObservadores;
end;

procedure TFrmPedidoItem.FormCreate(Sender: TObject);
begin
  inherited;
  lytExcluir.Visible := False;

//  lblDuplicar.Margins.Bottom := 0;
//  lblDuplicar.Margins.Top    := 60;
  lblExcluir.Margins.Bottom  := 0;
  lblExcluir.Margins.Top     := 60;
//
//  img_produto_sem_foto.Visible := False;
//  img_item_mais.Visible  := False;
//  img_item_menos.Visible := False;
end;

class function TFrmPedidoItem.GetInstance: TFrmPedidoItem;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmPedidoItem, aInstance);
    Application.RealCreateForms;
  end;

  if not Assigned(aInstance.FObservers) then
    aInstance.FObservers := TList<IObservadorPedidoItem>.Create;

  aInstance.aDao := TPedidoItemDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmPedidoItem.imgProdutoClick(Sender: TObject);
var
  daoProduto : TProdutoDao;
begin
  if (lblProduto.TagFloat = 1) then
  begin
    daoProduto := TProdutoDao.GetInstance;
    daoProduto.Load(lblProduto.TagString);
    daoProduto.Model := daoProduto.Lista[0];
    ExibirCadastroProduto(Self, False);
  end;
end;

procedure TFrmPedidoItem.imgQuantidadeMaisClick(Sender: TObject);
begin
  dao.IncrementarQuantidade();
  lblQuantidade.Text := FormatFloat(lblQuantidade.TagString, dao.Model.Quantidade);
  lblDescricao.Text  := FormatFloat(lblDescricao.TagString,  dao.Model.ValorLiquido);
end;

procedure TFrmPedidoItem.imgQuantidadeMenosClick(Sender: TObject);
begin
  dao.DecrementarQuantidade();
  lblQuantidade.Text := FormatFloat(lblQuantidade.TagString, dao.Model.Quantidade);
  lblDescricao.Text  := FormatFloat(lblDescricao.TagString,  dao.Model.ValorLiquido);
end;

procedure TFrmPedidoItem.Notificar;
var
  Observer : IObservadorPedidoItem;
begin
  for Observer in FObservers do
    Observer.AtualizarPedidoItem;
end;

procedure TFrmPedidoItem.RemoverObservador(Observer: IObservadorPedidoItem);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmPedidoItem.RemoverTodosObservadores;
var
  I : Integer;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);
end;

end.
