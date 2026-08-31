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

  # PATCH/PUT /graduate_records/:id
  def update
    if @graduate_record.update(graduate_record_params)
      respond_to do |format|
        format.html { redirect_to graduate_records_path, notice: "Donor record saved." }
        format.turbo_stream # Allows inline row updates without full page reloads
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@graduate_record, partial: "graduate_record", locals: { record: @graduate_record }), status: :unprocessable_entity }
      end
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