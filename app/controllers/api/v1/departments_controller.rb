module Api
  module V1
    class DepartmentsController < ApplicationController
      def show
        @department = Department
                      .includes(organisations: [:motif_categories, :lieux, { motifs: :motif_category }])
                      .find_by!(number: params[:department_number])
        authorize @department
        render json: { department: @department }, status: :ok
      end
    end
  end
end
