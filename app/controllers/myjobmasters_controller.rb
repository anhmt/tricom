class MyjobmastersController < ApplicationController
  before_action :require_user!
  before_action :set_myjobmaster, only: [:show, :edit, :update]
  before_action :set_refer, only: [:new, :edit, :create, :update]
  load_and_authorize_resource except: [:export_csv, :destroy]
  respond_to :js

  include MyjobmastersHelper

  # GET /jobmasters
  # GET /jobmasters.json
  def index
    @myjobmasters = Myjobmaster.all.order('updated_at desc')
  end

  # GET /jobmasters/1
  # GET /jobmasters/1.json
  def show
  end

  # GET /jobmasters/new
  def new

    @myjobmaster = Myjobmaster.new
  end

  # GET /jobmasters/1/edit
  def edit
  end

  # POST /jobmasters
  # POST /jobmasters.json
  def create
    # max_job = Jobmaster.pluck(:job番号).map {|i| i.to_i}.max + 1
    # max_job = 100001 if max_job < 100001
    # jobmaster_params[:job番号] = max_job
    @myjobmaster = Myjobmaster.new(myjobmaster_params)
    flash[:notice] = t 'app.flash.new_success' if @myjobmaster.save
    respond_with @myjobmaster, location: myjobmasters_url
  end

  # PATCH/PUT /jobmasters/1
  # PATCH/PUT /jobmasters/1.json
  def update
    flash[:notice] = t 'app.flash.update_success' if @myjobmaster.update(myjobmaster_params)
    respond_with @myjobmaster, location: myjobmasters_url
  end

  # DELETE /jobmasters/1
  # DELETE /jobmasters/1.json
  def destroy
    if params[:ids]
      begin
        params[:ids].each { |id| Myjobmaster.find(id).try(:destroy) }
      rescue
      end
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data}
      end
    else
      begin
        @myjobmaster = Myjobmaster.find(params[:id])
        @myjobmaster.destroy if @myjobmaster
        render 'share/destroy', locals: { obj: @myjobmaster, obj_id: @myjobmaster.id.try(:join, '-') }
      rescue
      end
    end
  end

  def ajax
    case params[:focus_field]
      when 'myjobmaster_ユーザ番号'
        kaisha_name = Kaishamaster.find(params[:kaisha_code]).try :name
        data = {kaisha_name: kaisha_name}
        respond_to do |format|
          format.json { render json: data}
        end
      when 'myjob_削除する'
        myjobIds = params[:myjobs]
        myjobIds.each{ |myjobId|
          Myjobmaster.find(myjobId).destroy          
        }        
        data = {destroy_success: 'success'}
        respond_to do |format|
          format.json { render json: data}
        end
      else
    end
  end

  def import
    super(Myjobmaster, myjobmasters_path)
  end

  def export_csv
    @myjobs = Myjobmaster.all

    respond_to do |format|
      format.html
      format.csv { send_data @myjobs.to_csv, filename: 'myjobマスタ.csv' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_myjobmaster
      @myjobmaster = Myjobmaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def myjobmaster_params
      params.require(:myjobmaster).permit(:社員番号,:job番号, :job名, :開始日, :終了日, :ユーザ番号, :ユーザ名, :入力社員番号, :分類コード, :分類名, :関連Job番号, :備考)
    end

  def set_refer
    @kaishamasters = Kaishamaster.all
    @jobs = Jobmaster.includes(:bunrui)
    @shains = Shainmaster.all
    @bunruis = Bunrui.all
  end
end
