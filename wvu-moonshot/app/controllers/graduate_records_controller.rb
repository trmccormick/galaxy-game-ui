class GraduateRecordsController < ApplicationController
  before_action :set_graduate_record, only: %i[ show update ]

  # GET /graduate_records
  # Check-in landing page: type a surname, get matches, pick a donor.
  def index
    @query = params[:q].to_s
    @graduate_records = @query.present? ? GraduateRecord.search_by_surname(@query) : []
  end

  # GET /graduate_records/:id
  # Prepopulated donor record/form for confirmation.
  def show
  end

  # PATCH/PUT /graduate_records/:id
  # Record the waiver status and corrections/notes. Everything stays
  # associated with the donor's CRM identifier for post-event reconciliation.
  def update
    if @graduate_record.update(graduate_record_params)
      redirect_to @graduate_record, notice: "Donor record saved."
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
