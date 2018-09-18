class MainController < ApplicationController
  before_action :require_user!

  def index
    @kairanCount = Kairanshosai.where(対象者: session[:user], 状態: 0).size
    @dengonCount = Dengon.where(社員番号: session[:user], 確認: false).size
  end
  def search
    vars = request.query_parameters
    @search = vars['search'] || ''
    @searchs = PgSearch::Document.where('content LIKE ?', '%' + @search + '%').select(:searchable_type).distinct
    @paths = Path.all.where(model_name_field: (@searchs.map(&:searchable_type))).where.not(title_jp: (t 'title.time_line_view'))
    @masters = Path.where('title_jp LIKE ?', '%' + @search + '%')
                  .or(Path.where('title_en LIKE ?', '%' + @search + '%'))
                  .or(Path.where('model_name_field LIKE ?', '%' + @search + '%'))
    @masters = @masters.where.not(model_name_field: (@paths.map(&:model_name_field)))
    @event = Event.all.where(id: (PgSearch::Document.where('content LIKE ?', '%' + @search + '%')
                  .where(searchable_type: 'Event')).map(&:searchable_id))
                  .where('Date(開始) >= ?', (Date.today - 1.month).to_s(:db))
    @kintai = Kintai.all.where(id: (PgSearch::Document.where('content LIKE ?', '%' + @search + '%').where(searchable_type: 'Kintai')).map(&:searchable_id)).where(社員番号: session[:user])
    @kairan = Kairan.all.where(id: (PgSearch::Document.where('content LIKE ?', '%' + @search + '%')
      .where(searchable_type: 'Kairan')).map(&:searchable_id))
      .where(id: Kairanshosai.where(対象者: session[:user]).map(&:回覧コード))
    if @event.first.nil?
      @paths = @paths.where.not(title_jp: (t 'title.event')).where.not(model_name_field: ['Event'])
    end
    if @kintai.first.nil?
      @paths = @paths.where.not(model_name_field: ['Kintai'])
    end
    if @kairan.first.nil?
      @paths = @paths.where.not(model_name_field: ['Kairan'])
    end
    respond_to do |format|
      format.html
      if I18n.locale.to_s == 'ja'
        format.json { render json: @masters.map(&:title_jp) + @paths.map(&:title_jp) }
      else
        format.json { render json: @masters.map(&:title_en) + @paths.map(&:title_en) }
      end
    end
  end
  def ajax
    case params[:id]
    when 'check_title'
      title = params[:title]
      @masters = Path.where(title_jp: title)
                    .or(Path.where(title_en: title))
      @masters.update_all(updated_at: Time.now)
      data = 'Success'
      respond_to do |format|
        format.json { render json: data }
      end
    when 'get_source'
      @all_paths = Path.all.order(updated_at: :desc).limit(5)
      if I18n.locale.to_s == 'ja'
        data = { source: @all_paths.map(&:title_jp) }
      else
        data = { source: @all_paths.map(&:title_en) }
      end
      respond_to do |format|
        format.json { render json: data }
      end
    end
  end
end
