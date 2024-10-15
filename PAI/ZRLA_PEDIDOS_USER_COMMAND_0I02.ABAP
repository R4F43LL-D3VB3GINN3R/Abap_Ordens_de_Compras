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

  "verifica se os campos foram preenchidos
  if in_nome_cliente is initial and in_clienteantigo is initial or in_valor_total is initial.
    message 'Preencha os campos obrigatórios' type 'S' display like 'E'.
    return.
  elseif in_nome_cliente is not initial and in_clienteantigo is not initial.
    message 'Escolha entre um cliente antigo ou um novo' type 'S' display like 'E'.
    return.
  endif.

  "cria uma instancia de pedido para ambos os casos
  data: ol_criacao_pedido type ref to zcl_pedidos.
  create object ol_criacao_pedido.

  if in_clienteantigo is not initial.

    "insere apenas um novo pedido relacionado ao cliente existente
    ol_criacao_pedido->insert_pedido(
      exporting
        id_cliente = in_clienteantigo
        nome       = in_nome_cliente
        valor      = in_valor_total
      importing
        e_result = result
    ).

  else.

    data: ol_criacao_cliente type ref to zcl_clientes.
    create object ol_criacao_cliente.

    "insere um novo pedido juntamente com um novo cliente
    ol_criacao_pedido->insert_pedido(
      exporting
        nome     = in_nome_cliente
        valor    = in_valor_total
      importing
        e_result = result
    ).

  endif.

  if result-rc eq 0.
      message result-mensagem type 'S'.
  else.
      message result-mensagem type 'S' display like 'E'.
  endif.

endform.
