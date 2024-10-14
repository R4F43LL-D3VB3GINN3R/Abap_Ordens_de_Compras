*----------------------------------------------------------------------*
***INCLUDE ZRLA_PEDIDOS_USER_COMMAND_0I03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0300 input.

  case okcode300.

    when 'BACK'.
       call screen '100'.

    when 'FCT_SUBMETER'.
      perform edit_pedido. "edita os dados de um pedido na base de dados

  endcase.

endmodule.

form edit_pedido.

  data: new_index type sy-index.

  "recebe a linha selecionada do alv
  read table lt_rows into data(ls_rows) index 1.
    new_index = ls_rows-index.

  if new_index is not initial.

    "método para alterar os dados do pedido
    ol_pedidos->edit_pedido(
      exporting
        nome      = in_nome_cliente2
        valor     = in_valor_total2
        status    = in_status2
        indexline = new_index
      importing
        e_result  = result
    ).

    if sy-subrc eq 0.
      message result-mensagem type 'S'.
    else.
      message result-mensagem type 'S' display like 'E'.
    endif.

  endif.

  "limpa os campos
  clear: in_nome_cliente2, in_valor_total2, in_status2.

  "limpa a tabela e a estrutura
  refresh: it_pedidos.
  clear:   ls_pedidos.

  it_pedidos = zcl_pedidos=>load_pedidos( ). "recarrega a tabela com as alteracoes da base ded ados

  sort it_pedidos by id_pedido ascending. "ordena por id

  perform fill_fields. "preenche novamente os campos com os dados atualizados

endform.
