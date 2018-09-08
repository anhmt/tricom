class KairanyokenmstsController < ApplicationController
  before_action :require_user!
  respond_to :html,:js

  def index
    @kairanyokenmsts = Kairanyokenmst.all
    respond_with(@kairanyokenmsts)
  end

  def create
    @kairanyokenmst = Kairanyokenmst.new(kairanyokenmst_params)
    flash[:notice] = t 'app.flash.new_success' if @kairanyokenmst.save
    respond_with(@kairanyokenmst, location: kairanyokenmsts_url)
  end

  def update
    @kairanyokenmst = Kairanyokenmst.find_by(id: kairanyokenmst_params[:id])
    flash[:nitice] = t 'app.flash.update_success' if @kairanyokenmst.update(kairanyokenmst_params)
    respond_with(@kairanyokenmst, location: kairanyokenmsts_url)
  end

  def destroy
    if params[:ids]
      Kairanyokenmst.where(id: params[:ids]).destroy_all
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @kairanyokenmst = Kairanyokenmst.find_by_id(params[:id])
      @kairanyokenmst.destroy if @kairanyokenmst
      respond_with(@kairanyokenmst, location: kairanyokenmsts_url)
    end
  end

  def import
    super(Kairanyokenmst, kairanyokenmsts_path)
  end

  def export_csv
    @kairanyokens = Kairanyokenmst.all
    respond_to do |format|
      format.csv { send_data @kairanyokens.to_csv, filename: '回覧用件マスタ.csv' }
    end
  end

  private

  def kairanyokenmst_params
    params.require(:kairanyokenmst).permit(:名称, :備考, :優先さ, :id)
  end

end
