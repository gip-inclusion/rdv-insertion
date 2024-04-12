require "stringio"

module Exporters
  class CreateUsersCsvExportJob < ApplicationJob
    EXPORT_KIND = :users_csv

    attr_reader :user_ids, :structure, :agent, :request_params

    def perform(user_ids, structure_type, structure_id, agent_id, request_params)
      @user_ids = user_ids
      @structure = structure_type.constantize.find(structure_id)
      @agent = Agent.find(agent_id)
      @request_params = request_params.deep_symbolize_keys

      create_export
      send_email
    end

    private

    def create_export
      ActiveRecord::Base.transaction do
        @export = CsvExport.create!(agent:, structure:, kind: EXPORT_KIND)
        @export.file.attach(io: StringIO.new(generate_csv.csv), filename: generate_csv.filename,
                            content_type: "text/csv")
      end
    end

    def send_email
      CsvExportMailer.notify_csv_export(agent.email, @export, request_params).deliver_now
    end

    def generate_csv
      @generate_csv ||=
        GenerateUsersCsv.call(user_ids:, structure:, motif_category_id: request_params[:motif_category_id], agent:)
    end
  end
end
