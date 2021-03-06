jQuery ->
  create_datatable
    table_id: '#yuukyuu_kyuuka_rireki'
    new_path: 'yuukyuu_kyuuka_rirekis/new'
    edit_path: 'yuukyuu_kyuuka_rirekis/id/edit'
    delete_path: '/yuukyuu_kyuuka_rirekis/id'
    invisible_columns: [0]
    no_search_columns: [0]
    no_sort_columns: [6, 7]
    page_length: 100
    search_params: queryParameters().search
    order_columns: [1, 'asc']
    get_id_from_row_data: (data)->
      return data[0]

  $(document).on 'change', '#yuukyuu_kyuuka_rireki_filter input', (event) ->
    console.log($(this).val())
    jQuery.ajax
      url: '/yuukyuu_kyuuka_rirekis/ajax'
      data:
        focus_field: 'set_search_month'
        yuukyuu_kyuuka_rirekis_search_month: $(this).val()
      type: "POST"
