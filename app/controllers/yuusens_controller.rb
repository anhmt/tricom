class YuusensController < ApplicationController
  before_action :require_user!
  before_action :set_yuusen, only: [:show, :edit, :update]
  load_and_authorize_resource except: [:export_csv, :destroy]
  respond_to :html, :js

  def index
    @yuusens = Yuusen.all
    respond_with(@yuusens)
  end

  def show
    respond_with(@yuusen)
  end

  def new
    @yuusen = Yuusen.new
    respond_with(@yuusen)
  end

  def edit
  end

  def create
    @yuusen = Yuusen.new(yuusen_params)
    flash[:notice] = t 'app.flash.new_success' if @yuusen.save
    respond_with(@yuusen, location: yuusens_path)
  end

  def update
    flash[:nitice] = t 'app.flash.update_success' if @yuusen.update(yuusen_params)
    respond_with(@yuusen, location: yuusens_path)
  end

  def destroy
    if params[:ids]
      Yuusen.where(id: params[:ids]).destroy_all
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @yuusen = Yuusen.find_by_id(params[:id])
      @yuusen.destroy if @yuusen
      render 'share/destroy', locals: { obj: @yuusen, obj_id: params[:id] }
    end
  end

  def import
    super(Yuusen, yuusens_path)
  end

  def ajax
    case params[:focus_field]
    when 'yuusen_削除する'
      yuusenIds = params[:yuusens]
      yuusenIds.each { |yuusenId|
        Yuusen.find_by(優先さ: yuusenId).destroy
      }
      data = { destroy_success: 'success' }
      respond_to do |format|
      format.json { render json: data }
    end
    end
  end

  def export_csv
    @yuusens = Yuusen.all

    respond_to do |format|
      format.csv { send_data @yuusens.to_csv, filename: '優先.csv' }
    end
  end

  private
    def set_yuusen
      @yuusen = Yuusen.find(params[:id])
    end

    def yuusen_params
      params.require(:yuusen).permit(:優先さ, :備考, :色)
    end
end
