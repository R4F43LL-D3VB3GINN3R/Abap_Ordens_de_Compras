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
      perform insert_pedido.               "insere o pedido / cliente / produtos na base de dados
      perform display_alv_container_itens. "refresh alv container

    when 'FCT_ADICIONAR'.
      perform add_item_container.          "adiciona item ao container
      perform build_catalog_itens.         "controi o catalogo de campos de itens
      perform build_container_itens.       "criacao do container de itens

  endcase.

endmodule.

form remove_item. "remove itens do carrinho

  "metodo para pegar os campos selecionados na alv
    call method ol_alvgrid2->get_selected_rows
      importing
        et_index_rows = lt_rows2.

    "nao esquecer de ordenar desta forma antes de excluir linhas de tabela por index
    sort lt_rows2 by index descending.

    ol_item->remove_item_catalog(
      exporting
        it_lines    = lt_rows2
      importing
        itens_table = it_fieldcat_itens
        result      = result
    ).

    if result-rc eq 0.
      message result-mensagem type 'S'.
    else.
      message result-mensagem type 'S' display like 'E'.
    endif.

    refresh: lt_rows2.

    perform display_alv_container_itens. "refresh alv container

endform.

form add_item_container.

  "verificacao de campos
  if in_produto2    is initial or
     in_quantidade2 is initial or
     in_preco2      is initial.
    message 'Insira os dados referente as informações do produto' type 'I'.
    return.
  endif.

  "verifica se a classe está instanciada
  if ol_item is initial.
    "objeto de referencia a classe de itens
    create object ol_item.
  endif.

  "metodo para adiciona o produto ao catalogo
  ol_item->add_item_catalog(
    exporting
      descricao   = in_produto2
      quantidade  = in_quantidade2
      preco       = in_preco2
    importing
      itens_table = it_fieldcat_itens
      valor_total = in_valor_total
      result      = result
  ).

  "se o objeto foi inserido...
  if sy-subrc eq 0.
    perform display_alv_container_itens.  "recarrega o container
    message result-mensagem type 'S'.
  else.
    message result-mensagem type 'S' display like 'E'.
  endif.

endform.

form build_catalog_itens.

  refresh it_fieldcat2.

  "metodo para construir um catalogo de campos
  zcl_itens=>build_catalog_itens(
    importing
      fieldcatalog = it_fieldcat2 "recebe o catálogo
  ).

endform.

form build_container_itens.

  container200 = 'CONTAINER2'. "atribui o container

  "se o container ainda nao foi criado...
  if ol_alvgrid2 is initial.

    "cria o container
    create object ol_container2
      exporting
        container_name              = container200
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6.

    "cria o alvgrid
    create object ol_alvgrid2
      exporting
        i_parent          = ol_container2
      exceptions
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5.

    create object ol_event_handler2.

    "métodos para inserir botoes na toolbar.
    set handler ol_event_handler2->handle_toolbar for ol_alvgrid2.

    "fica a escuta de um clique de botao
    set handler ol_event_handler2->handle_user_command for ol_alvgrid2.

  endif.

endform.

form display_alv_container_itens.

  if ol_alvgrid2 is not initial.

    "constrói o layout
    ls_layout2-box_fname = 'CHECKBOX'. " Habilita checkbox para seleção de linha
    ls_layout2-sel_mode  = 'A'.        " Habilita a seleção de múltiplas linhas
    ls_layout2-zebra     = 'X'.        " Habilita modo de visualização Zebra

    "metodo para receber o container com alv
    call method ol_alvgrid2->set_table_for_first_display
      exporting
        is_layout       = ls_layout2
      changing
        it_outtab       = it_fieldcat_itens
        it_fieldcatalog = it_fieldcat2
      exceptions
        others          = 1.

    "atualiza o alv
    call method ol_alvgrid2->refresh_table_display
      exceptions
        others = 1.

  endif.

endform.

form insert_pedido.

  "verifica se os campos foram preenchidos
  if in_nome_cliente is initial and in_clienteantigo is initial or in_valor_total is initial.
    message 'Preencha os campos obrigatórios' type 'S' display like 'E'.
    return.
  elseif in_nome_cliente is not initial and in_clienteantigo is not initial.
    message 'Escolha entre um cliente antigo ou um novo' type 'S' display like 'E'.
    return.
 "verifica se os produtos foram enviados
  elseif it_fieldcat_itens is initial.
    message 'Escolha o(s) produtos da compra' type 'I'.
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
        produtos   = it_fieldcat_itens
      importing
        e_result = result
    ).

  else.

    "cria uma instancia do cliente para inseri-lo
    data: ol_criacao_cliente type ref to zcl_clientes.
    create object ol_criacao_cliente.

    "insere um novo pedido juntamente com um novo cliente
    ol_criacao_pedido->insert_pedido(
      exporting
        nome       = in_nome_cliente
        valor      = in_valor_total
        produtos   = it_fieldcat_itens
      importing
        e_result = result
    ).

  endif.

  if result-rc eq 0.
    message result-mensagem type 'S'.
  else.
    message result-mensagem type 'S' display like 'E'.
  endif.

    "limpa os objetos
  free ol_criacao_pedido.
  free ol_criacao_cliente.
  free ol_item.

  "limpa campos e tabela de itens
  refresh it_fieldcat_itens.
  clear: in_clienteantigo, in_nome_cliente, in_produto2, in_preco2, in_quantidade2, in_valor_total.

endform.
