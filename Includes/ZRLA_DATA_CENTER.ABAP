*&---------------------------------------------------------------------*
*& Include          ZRLA_DATA_CENTER
*&---------------------------------------------------------------------*

"--------------------------------------------------------------------------------
"SCREENS

"variaveis de sistema
data: okcode100 type sy-ucomm,
      okcode200 type sy-ucomm,
      okcode300 type sy-ucomm.

"100
data: in_id type zpedidos-id_pedido. "campo id"

"tabela interna e estrutura - escopo do fieldcatalog
data: it_pedidos_clientes type zpedidos_clientes_tt,
      ls_pedidos_clientes type zpedidos_clientes_st.

"200
data: in_nome_cliente type zclientes-nome_cliente, "campo nome do cliente
      in_valor_total  type zpedidos-valor_total.   "campo valor total do pedido

"300
data: in_nome_cliente2 type zclientes-nome_cliente, "campo nome do cliente
      in_valor_total2  type zpedidos-valor_total,   "campo valor total do pedido
      in_status2       type zstatuspedido.          "status do pedido

"-------------------------------------------------------------------------------
"BASE DE DADOS --

"tabelas internas e estruturas

"pedidos
data: it_pedidos type table of zpedidos.
data: ls_pedidos type zpedidos.

"clientes
data: it_clientes type table of zclientes.
data: ls_clientes type zclientes.

"-------------------------------------------------------------------------------
"ALV CONTAINER --

"itens do alv container
data: container100 type scrfname. "custom control

data: ol_alvgrid   type ref to cl_gui_alv_grid ,         "objeto alv
      ol_container type ref to cl_gui_custom_container , "objeto do container
      ls_layout    type lvc_s_layo ,                     "layout alv
      it_fieldcat  type lvc_t_fcat ,                     "catalogo de campos
      ls_fieldcat  type lvc_s_fcat.                       "estrutura do catalogo de campos

data ol_event_handler type ref to zcl_event_handler. "instancia da classe de eventos

"linhas selecionaveis
data: lt_rows type lvc_t_row,       "tabela para campos de multiselecao na alv
      ls_rows like line of lt_rows. "linha de multiselecao

"-------------------------------------------------------------------------------
"INSTANCIAS DE CLASSES Z --

data ol_pedidos type ref to zcl_pedidos.

"-------------------------------------------------------------------------------
"OUTROS

data: result type zapr_result. "estrutura para retorno de operacoes
