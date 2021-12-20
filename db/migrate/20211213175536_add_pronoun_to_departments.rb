class AddPronounToDepartments < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def change
    add_column :departments, :pronoun, :string
    all_departments = Department.all

    ardennes = all_departments.find { |d| d.name == "Ardennes" }
    ardennes.update!(pronoun: "les")

    drome = all_departments.find { |d| d.name == "Drôme" }
    drome.update!(pronoun: "la")

    yonne = all_departments.find { |d| d.name == "Yonne" }
    yonne.update!(pronoun: "l'")

    aveyron = all_departments.find { |d| d.name == "Aveyron" }
    aveyron&.update!(pronoun: "l'")

    bdr = all_departments.find { |d| d.name == "Bouches-du-Rhône" }
    bdr&.update!(pronoun: "les")

    finistere = all_departments.find { |d| d.name == "Finistère" }
    finistere&.update!(pronoun: "le")
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
