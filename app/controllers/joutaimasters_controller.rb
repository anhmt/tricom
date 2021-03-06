class JoutaimastersController < ApplicationController
  before_action :require_user!
  skip_before_action :verify_authenticity_token
  before_action :set_joutaimaster, only: [:show, :edit, :update]
  load_and_authorize_resource except: [:export_csv, :destroy]

  def index
    @joutaimasters = Joutaimaster.all
  end

  def show
  end

  def new
    @joutaimaster = Joutaimaster.new
  end

  def edit
  end

  def create
    @joutaimaster = Joutaimaster.new(joutaimaster_params)
    respond_to do |format|
      if  @joutaimaster.save
        format.html { respond_with @joutaimaster, location: joutaimasters_url, notice: (t 'app.flash.new_success') }
        format.json { render :show, status: :created, location: @joutaimaster }
      else
        format.html { render :new }
        format.js { render json: @joutaimaster.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @joutaimaster.update joutaimaster_params_for_update
        format.html { respond_with @joutaimaster, location: joutaimasters_url, notice: (t 'app.flash.update_success') }
        format.json { render :show, status: :ok, location: @joutaimaster }
      else
        format.html { render :edit }
        format.js { render json: @joutaimaster.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if params[:ids]
      Joutaimaster.where(id: params[:ids]).destroy_all
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @joutaimaster = Joutaimaster.find_by_id(params[:id])
      @joutaimaster.destroy if @joutaimaster
      render 'share/destroy', locals: { obj: @joutaimaster }
    end
  end

  def create_joutai
    @joutai = Joutaimaster.new(joutaimaster_params)
    respond_to do |format|
      if  @joutai.save
        format.js { render 'create_joutai' }
      else
        format.js { render json: @joutai.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_joutai
    @joutai = Joutaimaster.find(joutaimaster_params[:状態コード])
    respond_to do |format|
      if  @joutai.update(joutaimaster_params)
        format.js { render 'update_joutai' }
      else
        format.js { render json: @joutai.errors, status: :unprocessable_entity }
      end
    end
  end

  def ajax
    case params[:focus_field]
    when 'joutaimaster_削除する'
      params[:joutais].each { |joutai_code|
        joutai = Joutaimaster.find(joutai_code)
        joutai.destroy if joutai
      }
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    when 'get_joutai_selected'
      joutai = Joutaimaster.find(params[:joutai_id])
      data = { joutai: joutai }
      respond_to do |format|
        format.json { render json: data }
      end
    end
  end

  def import
    super(Joutaimaster, joutaimasters_path)
  end

  def export_csv
    @joutaimasters = Joutaimaster.all

    respond_to do |format|
      format.html
      format.csv { send_data @joutaimasters.to_csv, filename: '状態マスタ.csv' }
    end
  end

  private

    def joutaimaster_params
      params.require(:joutaimaster).permit(:状態コード, :状態名, :状態区分, :勤怠状態名, :マーク, :色, :text_color, :WEB使用区分, :勤怠使用区分, :残業計算外区分)
    end

    def joutaimaster_params_for_update
      params.require(:joutaimaster).permit(:状態名, :状態区分, :勤怠状態名, :マーク, :色, :text_color, :WEB使用区分, :勤怠使用区分, :残業計算外区分)
    end

    def set_joutaimaster
      @joutaimaster = Joutaimaster.find(params[:id])
    end
end
