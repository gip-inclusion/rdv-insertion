module Notifications
  module RdvConcern
    extend ActiveSupport::Concern

    def lieu
      @rdv_solidarites_rdv.lieu
    end

    def motif
      @rdv_solidarites_rdv.motif
    end

    def rdv_presential?
      @rdv_solidarites_rdv.presential?
    end

    def formatted_start_date
      @rdv_solidarites_rdv.formatted_start_date
    end

    def formatted_start_time
      @rdv_solidarites_rdv.formatted_start_time
    end

    def event
      self.class.name.demodulize.underscore
    end
  end
end
