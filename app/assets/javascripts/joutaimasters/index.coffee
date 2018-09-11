jQuery ->
  create_datatable
    table_id: '#joutaimaster'
    new_path: 'joutaimasters/new'
    edit_path: 'joutaimasters/id/edit'
    delete_path: '/joutaimasters/id'
    no_sort_columns: [10, 11]
    search_params: queryParameters().search
    get_id_from_row_data: (data)->
      return data[0]
