class AddPronounToDepartments < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def change
    add_column :departments, :pronoun, :string
    all_departments = Department.all

    ardennes = all_departments.find { |d| d.name == "Ardennes" }
    ardennes.update!(pronoun: "les") if ardennes.present?

    drome = all_departments.find { |d| d.name == "Drôme" }
    drome.update!(pronoun: "la") if drome.present?

    yonne = all_departments.find { |d| d.name == "Yonne" }
    yonne.update!(pronoun: "l'") if yonne.present?

    aveyron = all_departments.find { |d| d.name == "Aveyron" }
    aveyron&.update!(pronoun: "l'") if aveyron.present?

    bdr = all_departments.find { |d| d.name == "Bouches-du-Rhône" }
    bdr&.update!(pronoun: "les") if bdr.present?

    finistere = all_departments.find { |d| d.name == "Finistère" }
    finistere&.update!(pronoun: "le") if finistere.present?
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
