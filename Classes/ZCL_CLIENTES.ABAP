class zcl_clientes definition
  public
  final
  create public .

  public section.

    data:
      it_clientes type table of zclientes_tt,
      ls_clientes type zclientes.

    methods construtor
      importing
        !id       type zclientes-id_cliente
      exporting
        !e_result type zapr_result .
    class-methods load_clientes
      returning
        value(clientes) type zclientes_tt .
    class-methods build_catalog_clientes
      exporting
        !fieldcatalog type lvc_t_fcat .
    class-methods get_next
      returning
        value(id) type zclientes-id_cliente .
    methods insert_cliente
      importing
        !nome_cliente type zclientes-nome_cliente
      exporting
        !e_result     type zapr_result .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_CLIENTES IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CLIENTES=>BUILD_CATALOG_CLIENTES
* +-------------------------------------------------------------------------------------------------+
* | [<---] FIELDCATALOG                   TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method build_catalog_clientes.

    "limpa o fieldcatalog
    clear fieldcatalog.

    "estrutura do alv
    data: ls_fieldcat type lvc_s_fcat. "estrutura do fieldcatalog

    clear ls_fieldcat.
    ls_fieldcat-fieldname = 'ID_CLIENTE'.
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
    ls_fieldcat-fieldname = 'DATA_INSCRICAO'.
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
* | Instance Public Method ZCL_CLIENTES->CONSTRUTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID                             TYPE        ZCLIENTES-ID_CLIENTE
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method construtor.

    "envia uma estrutura preenchida com os dados do cliente
    "o parametro é opcional e se o id nao for achado, ele envia um estrutura vazia

    if id is not initial.

      select single *
        from zclientes
        into @me->ls_clientes
        where id_cliente eq @id.

      if sy-subrc ne 0.
        e_result-rc = sy-subrc.
        e_result-mensagem = 'Não foi possível encontrar um Cliente'.
      endif.

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CLIENTES=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID                             TYPE        ZCLIENTES-ID_CLIENTE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    select max( id_cliente )
      from zclientes
      into id.

    add 1 to id.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CLIENTES->INSERT_CLIENTE
* +-------------------------------------------------------------------------------------------------+
* | [--->] NOME_CLIENTE                   TYPE        ZCLIENTES-NOME_CLIENTE
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method insert_cliente.

    data: ls_cliente type zclientes. "dados do cliente

    ls_cliente-id_cliente     = zcl_clientes=>get_next( ). "auto incremento da chave do cliente
    ls_cliente-nome_cliente   = nome_cliente.
    ls_cliente-data_inscricao = sy-datum.
    ls_cliente-status         = 'ATIVO'.

    "verifica se faltam dados do cliente
    if ls_cliente-id_cliente     is initial or
       ls_cliente-nome_cliente   is initial or
       ls_cliente-data_inscricao is initial or
       ls_cliente-status         is initial.

      e_result-rc       = 1.
      e_result-mensagem = 'Dados ausentes na inscrição de um novo cliente'.

    else. "se estiver tudo ok com os dados...

      insert zclientes from ls_cliente. "insere na tabela

      "se inserir na base de dados...
      if sy-subrc eq 0.
        e_result-rc = sy-subrc.
        e_result-mensagem = 'Cliente Cadastrado'.

        me->ls_clientes = ls_cliente.

      else.
        e_result-rc = sy-subrc.
        e_result-mensagem = 'Não foi possível cadastrar o cliente'.
        return.
      endif.

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CLIENTES=>LOAD_CLIENTES
* +-------------------------------------------------------------------------------------------------+
* | [<-()] CLIENTES                       TYPE        ZCLIENTES_TT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method load_clientes.

    "retorna os dados da base de dados de clientes
    select *
      from zclientes
      into table clientes.

    sort clientes by id_cliente.

  endmethod.
ENDCLASS.
