*----------------------------------------------------------------------*
***INCLUDE ZRLA_PEDIDOS_USER_COMMAND_0I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

  case okcode100.

    when 'BACK'.
     leave program.

    when 'FCT_BUSCAR'.

      create object ol_pedidos. "cria um objeto da classe de pedidos.

      perform get_data.              "consulta a base de dados
      perform build_catalog.         "construcao do catálogo de campos
      perform build_container.       "contrói o container
      perform display_alv_container. "exibe o alv no container

    when 'FCT_NOVO_PEDIDO'.
      call screen '200'. "chama a tela de cadastro de pedidos

    when 'FCT_DETALHES'.
      perform get_lines_alv.

  endcase.

endmodule.

form get_data.

  "limpa a tabela de pedidos de clientes
  refresh it_pedidos_clientes.

  "se nenhum id for selecionado
  if in_id is initial.

    "invoca o método sem passar o id do pedido opcional
    it_pedidos_clientes = zcl_pedidos=>load_pedidos_clientes(
*                              id_pedido =
                          ). "carrega toda a tabela

    sort it_pedidos_clientes by id_pedido ascending.

    if it_pedidos_clientes is initial.
      message | Não houveram dados retornados da tabela | type 'S' display like 'E'.
    else.
      message | { lines( it_pedidos_clientes ) } Registos retornados. | type 'S'.
    endif.

  "se um id for escolhido
  else.

    "invoca o método passando o parametro opcional
    it_pedidos_clientes = zcl_pedidos=>load_pedidos_clientes(
                              id_pedido = in_id
                          ). "carrega a tabela com uma linha

  endif.

endform.

form build_catalog.

  refresh it_fieldcat.

  "metodo para construir um catalogo de campos
  zcl_pedidos=>build_catalog_pedidos(
    importing
      fieldcatalog = it_fieldcat "recebe o catálogo
  ).

endform.

form build_container.

  container100 = 'CONTAINER1'. "atribui o container

  "se o container ainda nao foi criado...
  if ol_alvgrid is initial.

    "cria o container
    create object ol_container
      exporting
        container_name              = container100
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6.

    "cria o alvgrid
    create object ol_alvgrid
      exporting
        i_parent          = ol_container
      exceptions
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5.

  endif.

endform.

form display_alv_container.

  if ol_alvgrid is not initial.

    ls_layout-box_fname = 'CHECKBOX'. " Habilita checkbox para seleção de linha
    ls_layout-sel_mode  = 'A'.        " Habilita a seleção de múltiplas linhas

    "metodo para receber o container com alv
    call method ol_alvgrid->set_table_for_first_display
      exporting
        is_layout       = ls_layout
      changing
        it_outtab       = it_pedidos_clientes
        it_fieldcatalog = it_fieldcat
      exceptions
        others          = 1.

    "atualiza o alv
    call method ol_alvgrid->refresh_table_display
      exceptions
        others = 1.

  endif.

endform.

form get_lines_alv.

  if ol_alvgrid is not initial.

    refresh lt_rows.

    "metodo para pegar os campos selecionados na alv
    call method ol_alvgrid->get_selected_rows
      importing
        et_index_rows = lt_rows.

    if lines( lt_rows ) gt 1 or lines( lt_rows ) eq 0.
      message 'Escolha um pedido por vês para realizar alterações' type 'I'.
      return.
    else.
      call screen '300'. "chama a tela de edição de pedidos
    endif.

  else.

    message 'Carregue a lista de pedidos' type 'I'.

  endif.

endform.
