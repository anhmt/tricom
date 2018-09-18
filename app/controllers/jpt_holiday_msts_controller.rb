class JptHolidayMstsController < ApplicationController
  before_action :require_user!
  load_and_authorize_resource except: [:export_csv, :update, :destroy]
  respond_to :js, :html

  def index
    @jpt_holiday_msts = JptHolidayMst.all
    respond_with(@jpt_holiday_msts)
  end

  def create
    @jpt_holiday_mst = JptHolidayMst.new(jpt_holiday_mst_params)
    flash[:notice] = t 'app.flash.new_success' if @jpt_holiday_mst.save
    puts @jpt_holiday_mst.errors.full_messages
    respond_with(@jpt_holiday_mst, location: jpt_holiday_msts_path)
  end

  def update
    @jpt_holiday_mst = JptHolidayMst.find_by(id: jpt_holiday_mst_params[:id])
    flash[:notice] = t 'app.flash.update_success' if @jpt_holiday_mst.update(jpt_holiday_mst_params)
    respond_with(@jpt_holiday_mst, location: jpt_holiday_msts_path)
  end

  def destroy
    if params[:ids]
      JptHolidayMst.where(id: params[:ids]).destroy_all
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @jpt_holiday_mst = JptHolidayMst.find_by_id(params[:id])
      @jpt_holiday_mst.destroy if @jpt_holiday_mst
      respond_with(@jpt_holiday_mst, location: jpt_holiday_msts_path)
    end
  end

  def import
    super(JptHolidayMst, jpt_holiday_msts_path)
  end

  def export_csv
    @jpt_holidays = JptHolidayMst.all
    respond_to do |format|
      format.csv { send_data @jpt_holidays.to_csv, filename: 'ジュピター休日.csv' }
    end
  end

  private

    def set_jpt_holiday_mst
      @jpt_holiday_mst = JptHolidayMst.find_by id: params[:id]
    end

    def jpt_holiday_mst_params
      params.require(:jpt_holiday_mst).permit(:id, :event_date, :title, :description)
    end
end
