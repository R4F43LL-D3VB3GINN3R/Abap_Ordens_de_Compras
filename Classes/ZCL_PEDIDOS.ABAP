class zcl_pedidos definition
  public
  final
  create public .

  public section.

    data:
      it_pedidos type table of zpedidos .
    data ls_pedido type zpedidos .

    methods construtor
      importing
        !id       type zpedidos-id_pedido optional
      exporting
        !e_result type zapr_result .
    class-methods load_pedidos
      returning
        value(pedidos) type zpedidos_tt .
    class-methods build_catalog_pedidos
      exporting
        !fieldcatalog type lvc_t_fcat .
    methods insert_pedido
      importing
        !nome     type zclientes-nome_cliente
        !valor    type zpedidos-valor_total
      exporting
        !e_result type zapr_result .
    class-methods edit_pedido
      importing
        !nome      type zclientes-nome_cliente
        !valor     type zpedidos-valor_total
        !status    type zpedidos-status
        !indexline type sy-index
      exporting
        !e_result  type zapr_result .
    class-methods load_pedidos_clientes
      importing
        id_pedido               type zpedidos-id_pedido optional
      returning
        value(pedidos_clientes) type zpedidos_clientes_tt .
  protected section.
  private section.

    class-methods get_next
      returning
        value(id) type zpedidos-id_pedido .
    class-methods get_id
      importing
        !indexline type sy-index
      returning
        value(id)  type zpedidos-id_pedido .
    class-methods get_data_pedido
      importing
        !indexline  type sy-index
      returning
        value(data) type zpedidos-data_inicio .
ENDCLASS.



CLASS ZCL_PEDIDOS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_PEDIDOS=>BUILD_CATALOG_PEDIDOS
* +-------------------------------------------------------------------------------------------------+
* | [<---] FIELDCATALOG                   TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method build_catalog_pedidos.

    "limpa o fieldcatalog
    clear fieldcatalog.

    "estrutura do alv
    data: ls_fieldcat type lvc_s_fcat. "estrutura do fieldcatalog

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'ID_PEDIDO'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  3.
    ls_fieldcat-coltext   = 'ID'.
    ls_fieldcat-seltext   = 'ID'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'NOME_CLIENTE'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  25.
    ls_fieldcat-coltext   = 'Nome do Cliente'.
    ls_fieldcat-seltext   = 'Preço'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'VALOR_TOTAL'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  15.
    ls_fieldcat-coltext   = 'Preço Total'.
    ls_fieldcat-seltext   = 'Preço Total'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'DATA_INICIO'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  15.
    ls_fieldcat-coltext   = 'Data'.
    ls_fieldcat-seltext   = 'Data'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'STATUS'.
    ls_fieldcat-inttype   = 'C'.
    ls_fieldcat-outputlen =  15.
    ls_fieldcat-coltext   = 'Status'.
    ls_fieldcat-seltext   = 'Status'.
    ls_fieldcat-just      = 'C'.
    append ls_fieldcat to fieldcatalog.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDOS->CONSTRUTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID                             TYPE        ZPEDIDOS-ID_PEDIDO(optional)
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method construtor.

    "envia uma estrutura preenchida com os dados do pedido
    "o parametro é opcional e se o id nao for achado, ele envia um estrutura vazia

    if id is not initial.

      select single *
        from zpedidos
        into @me->ls_pedido
        where id_pedido eq @id.

      if sy-subrc ne 0.
        e_result-rc = sy-subrc.
        e_result-mensagem = 'Não foi possível encontrar um Pedido'.
      endif.

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_PEDIDOS=>EDIT_PEDIDO
* +-------------------------------------------------------------------------------------------------+
* | [--->] NOME                           TYPE        ZCLIENTES-NOME_CLIENTE
* | [--->] VALOR                          TYPE        ZPEDIDOS-VALOR_TOTAL
* | [--->] STATUS                         TYPE        ZPEDIDOS-STATUS
* | [--->] INDEXLINE                      TYPE        SY-INDEX
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method edit_pedido.

*    data: id_pedido4 type zpedidos-id_pedido.     "id do pedido
*    data: data_pedido4 type zpedidos-data_inicio. "data do pedido
*    data: ls_pedido4 type zpedidos.               "estrutura do pedido
*
*    id_pedido4   = zcl_pedidos=>get_id( indexline = indexline ).          "recebe o id do pedido
*    data_pedido4 = zcl_pedidos=>get_data_pedido( indexline = indexline ). "recebe a data do pedido
*
*    preenche a estrutura
*    ls_pedido4-id_pedido    = id_pedido4.
*    ls_pedido4-nome_cliente = nome.
*    ls_pedido4-valor_total  = valor.
*    ls_pedido4-status       = status.
*    ls_pedido4-data_inicio  = data_pedido4.
*
*    modify zpedidos from ls_pedido4. "altera o pedido na base de dados
*
*    if sy-subrc eq 0.
*      e_result-rc = sy-subrc.
*      e_result-mensagem = | Informações do pedido alteradas com sucesso  |.
*    else.
*      e_result-rc = sy-subrc.
*      e_result-mensagem = | Não foi possível realizar as alterações  |.
*    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_PEDIDOS=>GET_DATA_PEDIDO
* +-------------------------------------------------------------------------------------------------+
* | [--->] INDEXLINE                      TYPE        SY-INDEX
* | [<-()] DATA                           TYPE        ZPEDIDOS-DATA_INICIO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_data_pedido.

    data: it_pedidos5 type table of zpedidos.

    it_pedidos5 = zcl_pedidos=>load_pedidos( ).

    read table it_pedidos5 into data(ls_data) index indexline.

    data = ls_data-data_inicio.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_PEDIDOS=>GET_ID
* +-------------------------------------------------------------------------------------------------+
* | [--->] INDEXLINE                      TYPE        SY-INDEX
* | [<-()] ID                             TYPE        ZPEDIDOS-ID_PEDIDO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_id.

    data: it_pedidos3 type table of zpedidos.

    it_pedidos3 = zcl_pedidos=>load_pedidos( ).

    read table it_pedidos3 into data(ls_data) index indexline.

    id = ls_data-id_pedido.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_PEDIDOS=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID                             TYPE        ZPEDIDOS-ID_PEDIDO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    select max( id_pedido )
      from zpedidos
      into id.

    add 1 to id.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDOS->INSERT_PEDIDO
* +-------------------------------------------------------------------------------------------------+
* | [--->] NOME                           TYPE        ZCLIENTES-NOME_CLIENTE
* | [--->] VALOR                          TYPE        ZPEDIDOS-VALOR_TOTAL
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method insert_pedido.

    data: id_pedido  type zpedidos-id_pedido,
          ls_pedido2 type zpedidos.

    data: ol_cliente type ref to zcl_clientes.

    id_pedido = zcl_pedidos=>get_next( ). "método de auto incremento

    "o cliente é criado no momento da criacao do pedido
    "tem de se criar o cliente antes do pedido

    create object ol_cliente.

    "metodo para cadastrar novos clientes.
    ol_cliente->insert_cliente(
      exporting
        nome_cliente = nome
      importing
        e_result     = e_result
    ).

    if sy-subrc ne 0.
      return.
    endif.

    "preenche a estrutura com os dados
    ls_pedido2-id_pedido    = id_pedido.
    ls_pedido2-id_cliente   = ol_cliente->ls_clientes-id_cliente. "recebe o id do cliente cadastrado
    ls_pedido2-valor_total  = valor.
    ls_pedido2-data_inicio  = sy-datum.
    ls_pedido2-status       = 'PENDENTE'.

    insert zpedidos from ls_pedido2. "insere o novo pedido na tabela

    if sy-subrc eq 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = 'Novo pedido inserido com sucesso'.

      me->ls_pedido = ls_pedido2. "passa os dados do pedido para o atributo
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = 'Não foi possível inserir um novo pedido'.
    endif.

    free ol_cliente.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_PEDIDOS=>LOAD_PEDIDOS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] PEDIDOS                        TYPE        ZPEDIDOS_TT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method load_pedidos.

    "retorna os dados da base de dados de pedidos
    select *
      from zpedidos
      into table pedidos.

    sort pedidos by id_pedido.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_PEDIDOS=>LOAD_PEDIDOS_CLIENTES
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_PEDIDO                      TYPE        ZPEDIDOS-ID_PEDIDO(optional)
* | [<-()] PEDIDOS_CLIENTES               TYPE        ZPEDIDOS_CLIENTES_TT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method load_pedidos_clientes.

    if id_pedido is initial.

      "retorna a tabela com todos os dados
      select p~id_pedido,
             c~nome_cliente,
             p~valor_total,
             p~data_inicio,
             p~status
        from zpedidos as p
        inner join zclientes as c
        on p~id_cliente eq c~id_cliente
        into table @pedidos_clientes.

     else.

        "retorna a tabela com uma linha
        select p~id_pedido,
               c~nome_cliente,
               p~valor_total,
               p~data_inicio,
               p~status
          from zpedidos as p
          inner join zclientes as c
          on p~id_cliente eq c~id_cliente
          into table @pedidos_clientes
          where id_pedido eq @id_pedido.

      endif.

  endmethod.
ENDCLASS.
