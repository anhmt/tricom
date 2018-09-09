jQuery ->
  create_datatable
    table_id: '#kairanyokenmst'
    new_modal_id: '#kairanyokenmst-new-modal'
    edit_modal_id: '#kairanyokenmst-edit-modal'
    delete_path: '/kairanyokenmsts/id'
    invisible_columns: [0]
    no_search_columns: [0]
    no_sort_columns: [4]
    search_params: queryParameters().search
    get_id_from_row_data: (data)->
      return data[0]

  $('#kairanyokenmst-new-modal').on 'show', ()->
    $(this).modal('show')
    $('#kairanyokenmst_名称').val('')
    $('#kairanyokenmst_備考').val('')
    $('#kairanyokenmst_優先さ').val('')
    $('.form-group.has-error').each ()->
      $('.help-block', $(this)).html('')
      $(this).removeClass('has-error')

  $('#kairanyokenmst-edit-modal').on 'show', (e, selected_row_data)->
    $(this).modal('show')
    $('#kairanyokenmst_id').val(selected_row_data[0])
    $('#kairanyokenmst_名称').val(selected_row_data[1])
    $('#kairanyokenmst_備考').val(selected_row_data[2])
    $('#kairanyokenmst_優先さ').val(selected_row_data[3])
    $('.form-group.has-error').each ()->
      $('.help-block', $(this)).html('')
      $(this).removeClass('has-error')
