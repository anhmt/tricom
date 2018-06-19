class KouteimastersController < ApplicationController
  before_action :require_user!
  skip_before_action :verify_authenticity_token
  before_action :set_kouteimaster, only: [:show, :edit, :update]
  before_action :set_shozoku, only: [:new, :edit, :create, :update]
  before_action :set_param, only: :index
  respond_to :js
  load_and_authorize_resource except: [:export_csv, :destroy]

  # GET /kouteimasters
  # GET /kouteimasters.json
  def index
    @kouteimasters = Kouteimaster.includes(:shozokumaster)
  end

  # GET /kouteimasters/1
  # GET /kouteimasters/1.json
  def show
  end

  # GET /kouteimasters/new
  def new
    @kouteimaster = Kouteimaster.new
  end

  # GET /kouteimasters/1/edit
  def edit

  end

  # POST /kouteimasters
  # POST /kouteimasters.json
  def create
    @kouteimaster = Kouteimaster.new kouteimaster_params
    flash[:notice] = t 'app.flash.new_success' if @kouteimaster.save
    respond_with @kouteimaster
  end


  # PATCH/PUT /kouteimasters/1
  # PATCH/PUT /kouteimasters/1.json
  def update
    flash[:notice] = t 'app.flash.update_success' if @kouteimaster.update kouteimaster_params
    respond_with @kouteimaster
  end
  def create_koutei
    @kouteimaster = Kouteimaster.new(kouteimaster_params)
    @kouteimaster.save
  end

  def update_koutei
    koutei=kouteimaster_params
    @kouteimaster = Kouteimaster.find("#{koutei[:工程コード]},#{koutei[:所属コード]}")
    @kouteimaster.update(koutei)
  end
  # DELETE /kouteimasters/1
  # DELETE /kouteimasters/1.json
  def destroy
    if params[:ids]
      Kouteimaster.find(params[:ids]).each { |koutei| koutei.destroy }
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @kouteimaster = Kouteimaster.find(params[:id])
      @kouteimaster.destroy if @kouteimaster
      respond_with @kouteimaster, location: kouteimasters_url
    end
  rescue
  end

  def ajax
    case params[:id]
      when 'kouteimaster_所属コード'
        shozoku = Shozokumaster.find_by 所属コード: params[:kouteimaster_shozoku_code]
        shozoku_name = shozoku.try(:所属名)
        data = {shozoku_name: shozoku_name}
        respond_to do |format|
          format.json { render json: data}
        end
      else
    end
  end
  def multi_delete
    case params[:focus_field]
      when 'koutei_削除する'
        params[:kouteis].each{ |kouteiId|
          koutei=Kouteimaster.find(kouteiId)
          koutei.destroy if koutei
        }
        data = {destroy_success: 'success'}
        respond_to do |format|
          format.json { render json: data}
        end
    end
  end

  def import
    if params[:file].nil?
      flash[:alert] = t 'app.flash.file_nil'
      redirect_to kouteimasters_path
    elsif File.extname(params[:file].original_filename) != '.csv'
      flash[:danger] = t 'app.flash.file_format_invalid'
      redirect_to kouteimasters_path
    else
      begin
        Kouteimaster.transaction do
          Kouteimaster.delete_all
          Kouteimaster.reset_pk_sequence
          Kouteimaster.import(params[:file])
          notice = t 'app.flash.import_csv'
          redirect_to :back, notice: notice
        end
      rescue => err
        flash[:danger] = err.to_s
        redirect_to kouteimasters_path
      end
    end
  end

  def export_csv
    @kouteimasters = Kouteimaster.all

    respond_to do |format|
      format.html
      format.csv { send_data @kouteimasters.to_csv, filename: '工程マスタ.csv' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_kouteimaster

    @kouteimaster = Kouteimaster.find(params[:id])
  end

  def set_shozoku
    @shozokus = Shozokumaster.all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def kouteimaster_params
    params.require(:kouteimaster).permit(:所属コード, :工程コード, :工程名)
  end

  def param_valid
      params[:kouteimaster][:所属コード].in?(Shozokumaster.pluck(:所属コード))
  end
  def set_param
      @kouteimaster=Kouteimaster.new
  end
end
