module DatesFilterings
  class InvitationDatesFilteringsController < ApplicationController
    def new
      render turbo_stream: turbo_stream.replace("remote_modal", partial: "new")
    end
  end
end
