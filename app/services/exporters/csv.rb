require "csv"

module Exporters
  class Csv < BaseService
    def call
      preload_associations
      result.filename = filename
      result.csv = generate_csv
    end

    def generate_csv
      csv = CSV.generate(write_headers: true, col_sep: ";", headers:, encoding: "utf-8") do |row|
        each_element do |element|
          row << csv_row(element)
        end
      end
      # We add a BOM at the beginning of the file to enable a correct parsing of accented characters in Excel
      "\uFEFF#{csv}"
    end

    def department_level?
      @structure.instance_of?(Department)
    end

    def department_id
      department_level? ? @structure.id : @structure.department_id
    end

    def filename
      if @structure.present?
        "Export_#{resource_human_name}_#{@motif_category.present? ? "#{@motif_category.short_name}_" : ''}" \
          "#{@structure.class.model_name.human.downcase}_" \
          "#{@structure.name.parameterize(separator: '_')}.csv"
      else
        "Export_#{resource_human_name}_#{Time.zone.now.to_i}.csv"
      end
    end
  end
end
