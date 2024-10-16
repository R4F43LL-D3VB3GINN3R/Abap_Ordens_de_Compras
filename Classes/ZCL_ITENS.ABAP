class zcl_itens definition
  public
  final
  create public .

  public section.

    data it_itens type zitens_tt .
    data ls_itens type zitens_st .
    "catalogo de campos
    data it_fieldcat_itens type zfieldcat_itens_tt .
    data ls_fieldcat_itens type zfieldcat_itens_st .

    methods construtor
      importing
        !id       type zitens-id_item
      exporting
        !e_result type zapr_result .
    class-methods load_itens
      returning
        value(itens) type zitens_tt .
    class-methods build_catalog_itens
      exporting
        !fieldcatalog type lvc_t_fcat .
    class-methods get_next
      returning
        value(id) type zitens-id_item .
    methods add_item_catalog
      importing
        !descricao   type zitens-descricao
        !quantidade  type i
        !preco       type zitens-preco
      exporting
        !itens_table type zfieldcat_itens_tt
        !valor_total type currency
        !result      type zapr_result .
    methods insert_item
      importing
        !id_pedido   type zitens-id_pedido
        !itens_table type zfieldcat_itens_tt
      exporting
        !result      type zapr_result .
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
      result-mensagem = 'Novo item adicionado: ' && descricao && ' - Total: €' && me->ls_fieldcat_itens-preco.
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

    "inserimos a tabela da classe diretamente a ba  se de dados
    insert zitens from table me->it_itens.

    if sy-subrc ne 0.
      result-rc = sy-subrc.
      result-mensagem = 'Erro ao inserir itens na base de dados'.
    else.
      result-rc = sy-subrc.
      result-mensagem = 'Itens inseridos com sucesso.'.
    endif.

    refresh me->it_itens.
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
ENDCLASS.
