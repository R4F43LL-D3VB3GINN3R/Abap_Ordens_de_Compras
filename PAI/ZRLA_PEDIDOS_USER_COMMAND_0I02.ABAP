*----------------------------------------------------------------------*
***INCLUDE ZRLA_PEDIDOS_USER_COMMAND_0I02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0200 input.

  case okcode200.

    when 'BACK'.
       call screen '100'.

    when 'FCT_INSERIR'.
      perform insert_pedido.

  endcase.

endmodule.

form insert_pedido.

  if in_nome_cliente is initial or in_valor_total is initial.
    message 'Preencha os campos obrigatórios' type 'S' display like 'E'.
    return.
  endif.

  "insere um novo pedido
  zcl_pedidos=>insert_pedido(
    exporting
      nome     = in_nome_cliente
      valor    = in_valor_total
    importing
      e_result = result
  ).

  if result-rc eq 0.
    message result-mensagem type 'S'.
  else.
    message result-mensagem type 'S' display like 'E'.
  endif.

endform.
