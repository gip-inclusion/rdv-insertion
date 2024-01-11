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

    def each_element(&)
      raise NoMethodError
    end

    def preload_associations
      raise NoMethodError
    end

    def resource_human_name
      raise NoMethodError
    end
  end
end
