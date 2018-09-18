class ShozaisController < ApplicationController
  before_action :require_user!
  before_action :set_shozai, only: [:show, :edit, :update]
  load_and_authorize_resource except: [:export_csv, :destroy]

  respond_to :js

  def index
    @shozais = Shozai.all
    @shozai = Shozai.new
    respond_with(@shozais)
  end

  def show
    respond_with(@shozai)
  end

  def new
    @shozai = Shozai.new
    respond_with(@shozai)
  end

  def edit
  end

  def create
    @shozai = Shozai.new(shozai_params)
    flash[:notice] = t 'app.flash.new_success' if @shozai.save
    respond_with(@shozai, location: shozais_url)
  end

  def update
    flash[:notice] = t 'app.flash.update_success' if @shozai.update(shozai_params_for_update)
    respond_with(@shozai, location: shozais_url)
  end

  def destroy
    if params[:ids]
      Shozai.where(id: params[:ids]).destroy_all
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @shozai = Shozai.find_by_id(params[:id])
      @shozai.destroy if @shozai
      render 'share/destroy', locals: { obj: @shozai }
    end
  end
  def ajax
    case params[:focus_field]
    when 'shozai_削除する'
      params[:shozais].each { |shozai_code|
        shozai = Shozai.find(shozai_code)
        shozai.destroy if shozai
      }
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
    end
  end
  def import
    super(Shozai, shozais_path)
  end

  def export_csv
    @shozais = Shozai.all

    respond_to do |format|
      format.html
      format.csv { send_data @shozais.to_csv, filename: '所在マスタ.csv' }
    end
  end

  private
    def set_shozai
      @shozai = Shozai.find(params[:id])
    end

    def shozai_params
      params.require(:shozai).permit(:所在コード, :所在名, :background_color, :text_color)
    end

    def shozai_params_for_update
      params.require(:shozai).permit(:所在名, :background_color, :text_color)
    end
end
