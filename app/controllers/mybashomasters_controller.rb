class MybashomastersController < ApplicationController
  before_action :require_user!
  skip_before_action :verify_authenticity_token
  before_action :set_kaishamst, only: [:new, :create, :show, :edit, :update]
  before_action :set_mybashomaster, only: [:show, :edit, :update]
  load_and_authorize_resource except: [:export_csv, :destroy]
  respond_to :js

  def index
    @mybashomasters = Mybashomaster.all.order('updated_at desc')
  end


  def show
  end

  def new
    @mybashomaster = Mybashomaster.new
  end

  def edit

  end

  def create
    @mybashomaster = Mybashomaster.new(mybashomaster_params)
    flash[:notice] = t 'app.flash.new_success' if @mybashomaster.save
    respond_with @mybashomaster, location: mybashomasters_url

  end

  def update
    flash[:notice] = t 'app.flash.update_success' if @mybashomaster.update mybashomaster_params
    respond_with @mybashomaster, location: mybashomasters_url
  end

  def destroy
    if params[:ids]
      begin
        params[:ids].each { |id| Mybashomaster.find(id).try(:destroy) }
      rescue
      end
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data}
      end
    else
      begin
        @mybashomaster = Mybashomaster.find(params[:id])
        @mybashomaster.destroy if @mybashomaster
        render 'share/destroy', locals: { obj: @mybashomaster, obj_id: @mybashomaster.id.try(:join, '-') }
      rescue
      end
    end
  end

  def ajax
    case params[:focus_field]
      when 'mybashomaster_会社コード'
        kaisha_name = Kaishamaster.find_by(code: params[:kaisha_code]).try :name
        data = {kaisha_name: kaisha_name}
        respond_to do |format|
          format.json { render json: data}
        end
      when 'mybasho_削除する'
        mybashoIds = params[:mybashos]
        mybashoIds.each{ |mybashoId|
          Mybashomaster.find(mybashoId).destroy          
        }        
        data = {destroy_success: 'success'}
        respond_to do |format|
          format.json { render json: data}
        end
      else      
    end
  end

  def import
    super(Mybashomaster, mybashomasters_path)
  end

  def export_csv
    @mybashomasters = Mybashomaster.all

    respond_to do |format|
      format.html
      format.csv { send_data @mybashomasters.to_csv, filename: 'MY場所マスタ.csv' }
    end
  end

  private

  def mybashomaster_params
    params.require(:mybashomaster).permit(:社員番号, :場所コード, :場所名, :場所名カナ, :SUB, :場所区分,:会社コード, :更新日)
  end

  def set_mybashomaster
    @mybashomaster = Mybashomaster.find(params[:id])
  end

  def set_kaishamst
    @kaishamasters = Kaishamaster.all
  end

end
