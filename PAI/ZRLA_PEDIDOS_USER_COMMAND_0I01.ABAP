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

    when 'FCT_BUSCAR'.

      create object ol_pedidos. "cria um objeto da classe de pedidos.

      perform get_data.              "consulta a base de dados
      perform build_catalog.         "construcao do catálogo de campos
      perform build_container.       "contrói o container
      perform display_alv_container. "exibe o alv no container

  endcase.

endmodule.

form get_data.

  clear it_pedidos.

  if in_id is initial.
    it_pedidos = zcl_pedidos=>load_pedidos( ).
  else.
    ol_pedidos->construtor(
        id = in_id
    ).

    ls_pedidos = ol_pedidos->ls_pedido.
    append ls_pedidos to it_pedidos.
  endif.

endform.

form build_catalog.

  refresh it_fieldcat.

  zcl_pedidos=>build_catalog_pedidos(
    importing
      fieldcatalog = it_fieldcat
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

  "metodo para receber o container com alv
  call method ol_alvgrid->set_table_for_first_display
    exporting
      is_layout       = ls_layout
    changing
      it_outtab       = it_pedidos
      it_fieldcatalog = it_fieldcat
    exceptions
      others          = 1.

  "atualiza o alv
  call method ol_alvgrid->refresh_table_display
    exceptions
      others = 1.

endform.
