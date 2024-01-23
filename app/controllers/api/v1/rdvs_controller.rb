module Api
  module V1
    class RdvsController < ApplicationController
      def show
        @rdv = Rdv.find_by!(uuid: params[:uuid])
        authorize @rdv
        render json: { rdv: @rdv }, status: :ok
      end
    end
  end
end
