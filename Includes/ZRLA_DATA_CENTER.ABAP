*&---------------------------------------------------------------------*
*& Include          ZRLA_DATA_CENTER
*&---------------------------------------------------------------------*

"--------------------------------------------------------------------------------
"SCREEN 100

"variaveis de sistema
data: okcode100 type sy-ucomm.

"campos de entrada
data: in_id type int4. "campo id"

"-------------------------------------------------------------------------------
"BASE DE DADOS --

"tabelas internas e estruturas
data: it_pedidos type table of zpedidos.
data: ls_pedidos type zpedidos.

"-------------------------------------------------------------------------------
"ALV CONTAINER --

"itens do alv container
data: container100 type scrfname. "custom control

data ol_alvgrid type ref to cl_gui_alv_grid .           "objeto alv
data ol_container type ref to cl_gui_custom_container . "objeto do container
data ls_layout type lvc_s_layo .                        "layout alv
data it_fieldcat type lvc_t_fcat .                      "catalogo de campos

"-------------------------------------------------------------------------------
"INSTANCIAS DE CLASSES Z --

"pedidos
data ol_pedidos type ref to zcl_pedidos.

"---------------------------------------------------------------------------------
