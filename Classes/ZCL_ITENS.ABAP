class ZCL_ITENS definition
  public
  final
  create public .

public section.

  data IT_ITENS type ZITENS_TT .
  data LS_ITENS type ZITENS_ST .
    "catalogo de campos
  data IT_FIELDCAT_ITENS type ZFIELDCAT_ITENS_TT .
  data LS_FIELDCAT_ITENS type ZFIELDCAT_ITENS_ST .

  methods CONSTRUTOR
    importing
      !ID type ZITENS-ID_ITEM
    exporting
      !E_RESULT type ZAPR_RESULT .
  class-methods LOAD_ITENS
    returning
      value(ITENS) type ZITENS_TT .
  class-methods BUILD_CATALOG_ITENS
    exporting
      !FIELDCATALOG type LVC_T_FCAT .
  class-methods GET_NEXT
    returning
      value(ID) type ZITENS-ID_ITEM .
  methods ADD_ITEM_CATALOG
    importing
      !DESCRICAO type ZITENS-DESCRICAO
      !QUANTIDADE type I
      !PRECO type ZITENS-PRECO
    exporting
      !ITENS_TABLE type ZFIELDCAT_ITENS_TT
      !VALOR_TOTAL type CURRENCY
      !RESULT type ZAPR_RESULT .
  methods REMOVE_ITEM_CATALOG
    importing
      !IT_LINES type LVC_T_ROW
    exporting
      !ITENS_TABLE type ZFIELDCAT_ITENS_TT
      !RESULT type ZAPR_RESULT .
  methods INSERT_ITEM
    importing
      !ID_PEDIDO type ZITENS-ID_PEDIDO
      !ITENS_TABLE type ZFIELDCAT_ITENS_TT
    exporting
      !RESULT type ZAPR_RESULT .
  protected section.
  private section.

    methods get_valor_total
      returning
        value(total) type currency .
ENDCLASS.



CLASS ZCL_ITENS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ITENS->ADD_ITEM_CATALOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] DESCRICAO                      TYPE        ZITENS-DESCRICAO
* | [--->] QUANTIDADE                     TYPE        I
* | [--->] PRECO                          TYPE        ZITENS-PRECO
* | [<---] ITENS_TABLE                    TYPE        ZFIELDCAT_ITENS_TT
* | [<---] VALOR_TOTAL                    TYPE        CURRENCY
* | [<---] RESULT                         TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method add_item_catalog.

    if descricao   is initial or
       preco       is initial or
       itens_table is initial.

      result-rc = sy-subrc.
      result-mensagem = | Erro: Informações do item ausentes |.
    endif.

    clear me->ls_fieldcat_itens.

    "qualcula o preco baseado na quantidade de produtos comprados
    me->ls_fieldcat_itens-descricao  = descricao.
    me->ls_fieldcat_itens-preco      = quantidade * preco.
    me->ls_fieldcat_itens-quantidade = quantidade.

    "insere a estrutura no atributo da tabela
    append me->ls_fieldcat_itens to me->it_fieldcat_itens.

    "passa a tabela para o parametro de exportacao
    itens_table = me->it_fieldcat_itens.

    valor_total = me->get_valor_total( ). "recebe o valor total da compra

    if sy-subrc eq 0.
      result-rc = sy-subrc.
      result-mensagem = 'Novo item adicionado:' && ' ' && descricao && ' - Total: ' && ' ' && '€' && me->ls_fieldcat_itens-preco.
    else.
      result-rc = sy-subrc.
      result-mensagem = | Não foi possível adicionar o item ao carrinho |.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ITENS=>BUILD_CATALOG_ITENS
* +-------------------------------------------------------------------------------------------------+
* | [<---] FIELDCATALOG                   TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method build_catalog_itens.

    "limpa o fieldcatalog
    clear fieldcatalog.

    "estrutura do alv
    data: ls_fieldcat type lvc_s_fcat. "estrutura do fieldcatalog

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'DESCRICAO'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  30.
    ls_fieldcat-coltext   = 'Descrição'.
    ls_fieldcat-seltext   = 'Descrição'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'QUANTIDADE'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  10.
    ls_fieldcat-coltext   = 'Quantidade'.
    ls_fieldcat-seltext   = 'Quantidade'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'PRECO'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  10.
    ls_fieldcat-coltext   = 'Valor Total'.
    ls_fieldcat-seltext   = 'Valor Total'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ITENS->CONSTRUTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID                             TYPE        ZITENS-ID_ITEM
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method construtor.

    "envia uma estrutura preenchida com os dados do item
    "o parametro é opcional e se o id nao for achado, ele envia um estrutura vazia

    if id is not initial.

      select single *
        from zitens
        into @me->ls_itens
        where id_item eq @id.

      if sy-subrc ne 0.
        e_result-rc = sy-subrc.
        e_result-mensagem = 'Não foi possível encontrar um Cliente'.
      endif.

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ITENS=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID                             TYPE        ZITENS-ID_ITEM
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    select max( id_item )
       from zitens
       into id.

    add 1 to id.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ITENS->GET_VALOR_TOTAL
* +-------------------------------------------------------------------------------------------------+
* | [<-()] TOTAL                          TYPE        CURRENCY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_valor_total.

    "busca o valor de cada preco na tabela atributo de classe
    loop at me->it_fieldcat_itens into me->ls_fieldcat_itens.
      total = total + me->ls_fieldcat_itens-preco. "incrementa o valor do preço
    endloop.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ITENS->INSERT_ITEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_PEDIDO                      TYPE        ZITENS-ID_PEDIDO
* | [--->] ITENS_TABLE                    TYPE        ZFIELDCAT_ITENS_TT
* | [<---] RESULT                         TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method insert_item.

    "recebe por norma o id default auto incrementado
    data: id_item type zitens-id_item.
    id_item = zcl_itens=>get_next( ).

    "iteramos sobre o atributo tabela que já foi preenchido pelo método add_item_catalog
    loop at itens_table into me->ls_fieldcat_itens.

      "a partir desta tabela preenchemos a estrutura da classe
      me->ls_itens-id_item   = id_item.
      me->ls_itens-id_pedido = id_pedido.
      me->ls_itens-descricao = me->ls_fieldcat_itens-descricao.
      me->ls_itens-preco     = me->ls_fieldcat_itens-preco.

      add 1 to id_item. "incrementa o id auto incrementado

      "passamos a estrutura para a tabela interna da classe
      append me->ls_itens to me->it_itens.
      clear me->ls_itens.

    endloop.

    "inserimos a tabela da classe diretamente a base de dados
    insert zitens from table me->it_itens.

    if sy-subrc ne 0.
      result-rc = sy-subrc.
      result-mensagem = 'Erro ao inserir itens na base de dados'.
    else.
      result-rc = sy-subrc.
      result-mensagem = 'Itens inseridos com sucesso.'.
    endif.

    "limpa atributos de classe e dados
    refresh me->it_itens.
    refresh me->it_fieldcat_itens.
    clear id_item.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ITENS=>LOAD_ITENS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ITENS                          TYPE        ZITENS_TT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method load_itens.

    "retorna os dados da base de dados de clientes
    select *
      from zitens
      into table itens.

    sort itens by id_item.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ITENS->REMOVE_ITEM_CATALOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_LINES                       TYPE        LVC_T_ROW
* | [<---] ITENS_TABLE                    TYPE        ZFIELDCAT_ITENS_TT
* | [<---] RESULT                         TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method remove_item_catalog.

    "itera sobre a tabela de entrada e retorna a tabela com as linhas removidas
    loop at it_lines into data(ls_lines).
      read table itens_table into data(ls_table) index ls_lines-index.
        delete itens_table index sy-tabix.
        delete me->it_fieldcat_itens index sy-tabix.
    endloop.

    if sy-subrc eq 0.
      result-rc = sy-subrc.
      result-mensagem = | { lines( it_lines ) } itens removidos |.
    else.
      result-rc = sy-subrc.
      result-mensagem = | Não foi possível remover os itens |.
    endif.

  endmethod.
ENDCLASS.
