*----------------------------------------------------------------------*
***INCLUDE ZRLA_PEDIDOS_STATUS_0300O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0300 output.

 SET PF-STATUS 'ZSTATUS_PEDIDOS'.
 SET TITLEBAR 'xxx'.

 perform fill_fields. "preenche os campos com o valor da linha selecionada

endmodule.

form fill_fields.

  data: new_index2 type sy-index.

  "recebe a linha selecionada do alv
  read table lt_rows into data(ls_rows) index 1.
    new_index2 = ls_rows-index. "recebe o numero da linha selecionada

  "procura a linha referente ao pedido na base de dados
  read table it_pedidos_clientes into ls_pedidos_clientes index new_index2.

    "preenche os campos com os valores da linha
    in_nome_cliente2 = ls_pedidos_clientes-nome_cliente.
    in_valor_total2  = ls_pedidos_clientes-valor_total.
    in_status2       = ls_pedidos_clientes-status.

endform.
