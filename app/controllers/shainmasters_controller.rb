class ShainmastersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :require_user!
  before_action :set_reference, only: [:new, :edit, :create, :update]
  load_and_authorize_resource except: [:export_csv, :destroy]
  respond_to :js

  def index
    @shainmasters = Shainmaster.includes(:shozokumaster, :yakushokumaster, :rorumaster, :user)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @shainmaster.shozokumaster = Shozokumaster.find_by 所属コード:
      shainmaster_params[:所属コード]
    @shainmaster.yakushokumaster = Yakushokumaster.find_by 役職コード:
      shainmaster_params[:役職コード]
    @shainmaster.rorumaster = Rorumaster.find_by ロールコード:
      shainmaster_params[:デフォルトロール]
    flash[:notice] = t 'app.flash.new_success' if @shainmaster.save
    respond_with @shainmaster, location: shainmasters_path
  end

  def update
    @shainmaster.shozokumaster = Shozokumaster.find_by 所属コード:
      shainmaster_params[:所属コード]
    @shainmaster.yakushokumaster = Yakushokumaster.find_by 役職コード:
      shainmaster_params[:役職コード]
    @shainmaster.rorumaster = Rorumaster.find_by ロールコード:
      shainmaster_params[:デフォルトロール]
    flash[:notice] = t 'app.flash.update_success' if
      @shainmaster.update_attributes shainmaster_params_for_update
    respond_with @shainmaster, location: shainmasters_path
  end

  def destroy
    if params[:ids]
      params[:ids].each do |shainId|
        shain = Shainmaster.find_by_id(shainId)
        shain.destroy if shain && current_user != shain.user
      end
      data = { destroy_success: 'success' }
      respond_to do |format|
        format.json { render json: data }
      end
    else
      @shainmaster = Shainmaster.find_by(id: params[:id])
      @shainmaster.destroy if @shainmaster && current_user != @shainmaster.user
      render 'share/destroy', locals: { obj: @shainmaster }
    end
  end

  def import
    super(Shainmaster, shainmasters_path)
  end

  def export_csv
    @shainmasters = Shainmaster.all
    respond_to do |format|
      format.csv { send_data @shainmasters.to_csv, filename: '社員マスタ.csv' }
    end
  end

  private
    def shainmaster_params
      params.require(:shainmaster).permit :序列, :社員番号, :連携用社員番号, :氏名,
        :所属コード, :直間区分, :役職コード, :内線電話番号, :有給残数, :区分, :タイムライン区分, :デフォルトロール, :残業区分
    end

    def shainmaster_params_for_update
      params.require(:shainmaster).permit :序列, :連携用社員番号, :氏名, :所属コード,
        :直間区分, :役職コード, :内線電話番号, :有給残数, :区分, :タイムライン区分, :デフォルトロール, :残業区分
    end

    def set_reference
      @shozokus = Shozokumaster.all
      @yakushokus = Yakushokumaster.all
    end
end
