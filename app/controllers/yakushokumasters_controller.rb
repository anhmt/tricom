class YakushokumastersController < ApplicationController
  before_action :require_user!
  skip_before_action :verify_authenticity_token
  respond_to :js

  def index
    @yakushokumasters = Yakushokumaster.all
  end

  def create
    @yakushokumaster = Yakushokumaster.new(yakushokumaster_params)
    flash[:notice] = t 'app.flash.new_success' if @yakushokumaster.save
    respond_with @yakushokumaster, location: yakushokumasters_path
  end

  def update
    @yakushokumaster = Yakushokumaster.find(yakushokumaster_params[:役職コード])    
    flash[:notice] = t 'app.flash.update_success' if @yakushokumaster.update(yakushokumaster_params)
    respond_with @yakushokumaster, location: yakushokumasters_path
  end

  def destroy
    if params[:ids]
      Yakushokumaster.where(id: params[:ids]).destroy_all
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @yakushokumaster = Yakushokumaster.find_by_id(params[:id])
      @yakushokumaster.destroy if @yakushokumaster
      respond_with @yakushokumaster, location: yakushokumasters_url
    end
  end

  def import
    if params[:file].nil?
      flash[:alert] = t 'app.flash.file_nil'
      redirect_to yakushokumasters_path
    elsif File.extname(params[:file].original_filename) != '.csv'
      flash[:danger] = t 'app.flash.file_format_invalid'
      redirect_to yakushokumasters_path
    else
      begin
        Yakushokumaster.transaction do
          Yakushokumaster.delete_all
          Yakushokumaster.reset_pk_sequence
          Yakushokumaster.import(params[:file])
          notice = t 'app.flash.import_csv'
          redirect_to :back, notice: notice
        end
      rescue => err
        flash[:danger] = err.to_s
        redirect_to yakushokumasters_path
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def yakushokumaster_params
    params.require(:yakushokumaster).permit(:役職コード, :役職名)
  end

end
