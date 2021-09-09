module Notifications
  module RdvConcern
    extend ActiveSupport::Concern

    def rdv_presential?
      @motif[:location_type] == "public_office"
    end

    def formatted_start_date
      @starts_at.to_datetime.strftime("%d/%m/%Y")
    end

    def formatted_start_time
      @starts_at.to_datetime.strftime('%H:%M')
    end

    def department
      @applicant.department
    end

    def event
      self.class.name.demodulize.underscore
    end
  end
end
