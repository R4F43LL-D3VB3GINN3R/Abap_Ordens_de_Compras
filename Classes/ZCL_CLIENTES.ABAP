class ZCL_CLIENTES definition
  public
  final
  create public .

public section.

  data IT_CLIENTES type table of ZCLIENTES .
  data LS_CLIENTES type ZCLIENTES .

  methods construtor
    importing
      !ID type ZCLIENTES-ID_CLIENTE
    exporting
      !E_RESULT type ZAPR_RESULT .
  class-methods load_clientes
      returning
        value(clientes) type zclientes_tt .
  class-methods build_catalog_clientes
      exporting
        !fieldcatalog type lvc_t_fcat .
protected section.
private section.
  class-methods get_next
      returning
        value(id) type zclientes-id_cliente .
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
* | Instance Private Method ZCL_CLIENTES->GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    select max( id_cliente )
      from zclientes
      into id.

    add 1 to id.

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
