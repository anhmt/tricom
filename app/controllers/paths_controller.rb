class PathsController < ApplicationController
  before_action :set_path, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: :export_csv

  def new
    @path = Path.new
    respond_with(@path)
  end

  def index
    @paths = Path.all
  end

  def show
    respond_with(@path)
  end

  def create
    @path = Path.new(path_params)
    @path.save
    respond_with(@path)
  end

  def update
    @path.update(path_params)
    respond_with(@path)
  end

  def destroy
    @path.destroy
    respond_with(@path)
  end

  def import
    super(Path, paths_path)
  end

  def export_csv
    @paths = Path.all
    respond_to do |format|
      format.html
      format.csv { send_data @paths.to_csv, filename: 'Path.csv' }
    end
  end

  private
    def set_path
      @path = Path.find(params[:id])
    end

    def path_params
      params.require(:path).permit :title_jp, :title_en, :model_name_field, :path_url
    end
end
