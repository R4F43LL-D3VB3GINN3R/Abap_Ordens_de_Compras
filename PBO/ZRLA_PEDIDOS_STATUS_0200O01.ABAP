*----------------------------------------------------------------------*
***INCLUDE ZRLA_PEDIDOS_STATUS_0200O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0200 output.

 SET PF-STATUS 'ZSTATUS_PEDIDOS'.
 SET TITLEBAR 'xxx'.

 perform fill_dropdown_clientes.

endmodule.

form fill_dropdown_clientes.

"tabela usada guardar os dados da dropdown
*  data: it_list type vrm_values,
*        ls_list like line of it_list.

  types: begin of wa_ddown,
         id_cliente   type zclientes-id_cliente,
         nome_cliente type zclientes-nome_cliente,
       end of wa_ddown.

  "tabela e estrutura da estrutura types
  data: it_ddown type table of wa_ddown with key id_cliente,
        ls_ddown type wa_ddown.

  "preenche os campos da tabela interna com id e nome
  select * from zclientes
    into corresponding fields of table it_ddown.

  if sy-subrc eq 0.

    sort it_ddown by id_cliente. "ordena por id

    data: id_char type char10. "id em char

    "passa os dados da tabela para a tabela da dropdown
    loop at it_ddown into ls_ddown.
      clear ls_list.
      id_char = ls_ddown-id_cliente.
      ls_list-key = id_char.
      ls_list-text = ls_ddown-nome_cliente.
      append ls_list to it_list.
      clear ls_ddown.
    endloop.

    "chama a funcao que preenche a dropdown
    call function 'VRM_SET_VALUES'
      exporting
        id     = 'IN_CLIENTEANTIGO'
        values = it_list.

  endif.


endform.
