class GraduateRecordsController < ApplicationController
  before_action :set_graduate_record, only: %i[ show update ]

  # GET /graduate_records
  def index
    @graduate_records = GraduateRecord.order(:surname, :first_name)

    respond_to do |format|
      format.html # renders index.html.erb with all 300-400 records
      format.csv  { send_data GraduateRecord.to_csv, filename: "graduate-check-in-#{Date.today}.csv" }
    end
  end

  # GET /graduate_records/:id
  def show
  end

  def update
    if @graduate_record.update(graduate_record_params)
      redirect_to graduate_records_path, notice: "Donor record saved for #{@graduate_record.display_name}."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    def set_graduate_record
      @graduate_record = GraduateRecord.find(params[:id])
    end

    def graduate_record_params
      params.require(:graduate_record).permit(:waiver_completed, :notes)
    end
end