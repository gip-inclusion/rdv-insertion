# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_06_26_165441) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_roles", force: :cascade do |t|
    t.integer "access_level", default: 0, null: false
    t.bigint "agent_id", null: false
    t.bigint "organisation_id", null: false
    t.bigint "rdv_solidarites_agent_role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_webhook_update_received_at"
    t.index ["access_level"], name: "index_agent_roles_on_access_level"
    t.index ["agent_id", "organisation_id"], name: "index_agent_roles_on_agent_id_and_organisation_id", unique: true
    t.index ["agent_id"], name: "index_agent_roles_on_agent_id"
    t.index ["organisation_id"], name: "index_agent_roles_on_organisation_id"
    t.index ["rdv_solidarites_agent_role_id"], name: "index_agent_roles_on_rdv_solidarites_agent_role_id", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rdv_solidarites_agent_id"
    t.string "first_name"
    t.string "last_name"
    t.boolean "has_logged_in", default: false
    t.datetime "last_webhook_update_received_at"
    t.boolean "super_admin", default: false
    t.index ["email"], name: "index_agents_on_email", unique: true
    t.index ["rdv_solidarites_agent_id"], name: "index_agents_on_rdv_solidarites_agent_id", unique: true
  end

  create_table "applicants", force: :cascade do |t|
    t.string "uid"
    t.bigint "rdv_solidarites_user_id"
    t.string "affiliation_number"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "department_internal_id"
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "phone_number"
    t.string "email"
    t.integer "title"
    t.date "birth_date"
    t.date "rights_opening_date"
    t.string "birth_name"
    t.datetime "deleted_at"
    t.datetime "last_webhook_update_received_at"
    t.string "nir"
    t.string "pole_emploi_id"
    t.bigint "carnet_de_bord_carnet_id"
    t.index ["department_internal_id"], name: "index_applicants_on_department_internal_id"
    t.index ["email"], name: "index_applicants_on_email"
    t.index ["nir"], name: "index_applicants_on_nir"
    t.index ["phone_number"], name: "index_applicants_on_phone_number"
    t.index ["rdv_solidarites_user_id"], name: "index_applicants_on_rdv_solidarites_user_id", unique: true
    t.index ["uid"], name: "index_applicants_on_uid"
  end

  create_table "applicants_organisations", id: false, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "applicant_id", null: false
    t.index ["organisation_id", "applicant_id"], name: "index_applicants_orgas_on_orga_id_and_applicant_id", unique: true
  end

  create_table "archives", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.bigint "applicant_id", null: false
    t.string "archiving_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_archives_on_applicant_id"
    t.index ["department_id"], name: "index_archives_on_department_id"
  end

  create_table "configurations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_formats", default: ["sms", "email", "postal"], null: false, array: true
    t.boolean "convene_applicant", default: true
    t.integer "number_of_days_before_action_required", default: 10
    t.boolean "invite_to_applicant_organisations_only", default: true
    t.boolean "rdv_with_referents", default: false
    t.bigint "motif_category_id"
    t.bigint "file_configuration_id"
    t.bigint "organisation_id"
    t.index ["file_configuration_id"], name: "index_configurations_on_file_configuration_id"
    t.index ["motif_category_id"], name: "index_configurations_on_motif_category_id"
    t.index ["organisation_id"], name: "index_configurations_on_organisation_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.string "capital"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "region"
    t.string "pronoun"
    t.string "email"
    t.string "phone_number"
    t.boolean "display_in_stats", default: true
    t.bigint "carnet_de_bord_deploiement_id"
  end

  create_table "file_configurations", force: :cascade do |t|
    t.string "sheet_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title_column"
    t.string "first_name_column"
    t.string "last_name_column"
    t.string "role_column"
    t.string "email_column"
    t.string "phone_number_column"
    t.string "birth_date_column"
    t.string "birth_name_column"
    t.string "address_first_field_column"
    t.string "address_second_field_column"
    t.string "address_third_field_column"
    t.string "address_fourth_field_column"
    t.string "address_fifth_field_column"
    t.string "affiliation_number_column"
    t.string "pole_emploi_id_column"
    t.string "nir_column"
    t.string "department_internal_id_column"
    t.string "rights_opening_date_column"
    t.string "organisation_search_terms_column"
    t.string "referent_email_column"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "format"
    t.string "link"
    t.string "rdv_solidarites_token"
    t.datetime "sent_at", precision: nil
    t.bigint "applicant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "clicked", default: false
    t.string "help_phone_number"
    t.bigint "department_id"
    t.bigint "rdv_solidarites_lieu_id"
    t.bigint "rdv_context_id"
    t.datetime "valid_until"
    t.boolean "reminder", default: false
    t.string "uuid"
    t.boolean "rdv_with_referents", default: false
    t.index ["applicant_id"], name: "index_invitations_on_applicant_id"
    t.index ["department_id"], name: "index_invitations_on_department_id"
    t.index ["rdv_context_id"], name: "index_invitations_on_rdv_context_id"
    t.index ["uuid"], name: "index_invitations_on_uuid", unique: true
  end

  create_table "invitations_organisations", id: false, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "invitation_id", null: false
    t.index ["organisation_id", "invitation_id"], name: "index_invitations_orgas_on_orga_id_and_invitation_id", unique: true
  end

  create_table "lieux", force: :cascade do |t|
    t.bigint "rdv_solidarites_lieu_id"
    t.string "name"
    t.string "address"
    t.string "phone_number"
    t.datetime "last_webhook_update_received_at"
    t.bigint "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_lieux_on_organisation_id"
  end

  create_table "messages_configurations", force: :cascade do |t|
    t.string "direction_names", array: true
    t.string "sender_city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "letter_sender_name"
    t.string "signature_lines", array: true
    t.string "help_address"
    t.boolean "display_europe_logos", default: false
    t.string "sms_sender_name"
    t.boolean "display_department_logo", default: true
    t.bigint "organisation_id"
    t.boolean "display_pole_emploi_logo", default: false
    t.index ["organisation_id"], name: "index_messages_configurations_on_organisation_id"
  end

  create_table "motif_categories", force: :cascade do |t|
    t.string "short_name"
    t.string "name"
    t.bigint "rdv_solidarites_motif_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "template_id"
    t.boolean "participation_optional", default: false
    t.index ["rdv_solidarites_motif_category_id"], name: "index_motif_categories_on_rdv_solidarites_motif_category_id", unique: true
    t.index ["short_name"], name: "index_motif_categories_on_short_name", unique: true
    t.index ["template_id"], name: "index_motif_categories_on_template_id"
  end

  create_table "motifs", force: :cascade do |t|
    t.bigint "rdv_solidarites_motif_id"
    t.string "name"
    t.boolean "reservable_online"
    t.datetime "deleted_at"
    t.bigint "rdv_solidarites_service_id"
    t.boolean "collectif"
    t.integer "location_type"
    t.datetime "last_webhook_update_received_at"
    t.bigint "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "follow_up", default: false
    t.bigint "motif_category_id"
    t.text "instruction_for_rdv", default: ""
    t.index ["motif_category_id"], name: "index_motifs_on_motif_category_id"
    t.index ["organisation_id"], name: "index_motifs_on_organisation_id"
    t.index ["rdv_solidarites_motif_id"], name: "index_motifs_on_rdv_solidarites_motif_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "event"
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rdv_solidarites_rdv_id"
    t.integer "format"
    t.bigint "participation_id"
    t.index ["participation_id"], name: "index_notifications_on_participation_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "email"
    t.bigint "rdv_solidarites_organisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.datetime "last_webhook_update_received_at"
    t.string "slug"
    t.boolean "independent_from_cd", default: false
    t.string "logo_filename"
    t.index ["department_id"], name: "index_organisations_on_department_id"
    t.index ["rdv_solidarites_organisation_id"], name: "index_organisations_on_rdv_solidarites_organisation_id", unique: true
  end

  create_table "organisations_webhook_endpoints", id: false, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "webhook_endpoint_id", null: false
    t.index ["organisation_id", "webhook_endpoint_id"], name: "index_webhook_orgas_on_orga_id_and_webhook_id", unique: true
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.bigint "rdv_id", null: false
    t.integer "status", default: 0
    t.bigint "rdv_solidarites_participation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rdv_context_id"
    t.string "created_by", null: false
    t.boolean "convocable", default: false, null: false
    t.index ["applicant_id", "rdv_id"], name: "index_participations_on_applicant_id_and_rdv_id", unique: true
    t.index ["rdv_context_id"], name: "index_participations_on_rdv_context_id"
    t.index ["status"], name: "index_participations_on_status"
  end

  create_table "rdv_contexts", force: :cascade do |t|
    t.integer "status"
    t.bigint "applicant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "motif_category_id"
    t.datetime "closed_at"
    t.index ["applicant_id"], name: "index_rdv_contexts_on_applicant_id"
    t.index ["motif_category_id"], name: "index_rdv_contexts_on_motif_category_id"
    t.index ["status"], name: "index_rdv_contexts_on_status"
  end

  create_table "rdvs", force: :cascade do |t|
    t.bigint "rdv_solidarites_rdv_id"
    t.datetime "starts_at", precision: nil
    t.integer "duration_in_min"
    t.datetime "cancelled_at", precision: nil
    t.string "uuid"
    t.string "address"
    t.integer "created_by"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organisation_id"
    t.text "context"
    t.datetime "last_webhook_update_received_at"
    t.bigint "motif_id"
    t.bigint "lieu_id"
    t.integer "users_count", default: 0
    t.integer "max_participants_count"
    t.index ["created_by"], name: "index_rdvs_on_created_by"
    t.index ["lieu_id"], name: "index_rdvs_on_lieu_id"
    t.index ["motif_id"], name: "index_rdvs_on_motif_id"
    t.index ["organisation_id"], name: "index_rdvs_on_organisation_id"
    t.index ["rdv_solidarites_rdv_id"], name: "index_rdvs_on_rdv_solidarites_rdv_id", unique: true
    t.index ["status"], name: "index_rdvs_on_status"
  end

  create_table "referent_assignations", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.bigint "agent_id", null: false
    t.index ["applicant_id", "agent_id"], name: "index_referent_assignations_on_applicant_id_and_agent_id", unique: true
  end

  create_table "stats", force: :cascade do |t|
    t.integer "applicants_count"
    t.json "applicants_count_grouped_by_month"
    t.integer "rdvs_count"
    t.json "rdvs_count_grouped_by_month"
    t.integer "sent_invitations_count"
    t.json "sent_invitations_count_grouped_by_month"
    t.float "percentage_of_no_show"
    t.json "percentage_of_no_show_grouped_by_month"
    t.float "average_time_between_invitation_and_rdv_in_days"
    t.json "average_time_between_invitation_and_rdv_in_days_by_month"
    t.float "average_time_between_rdv_creation_and_start_in_days"
    t.json "average_time_between_rdv_creation_and_start_in_days_by_month"
    t.float "rate_of_applicants_with_rdv_seen_in_less_than_30_days"
    t.json "rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month"
    t.integer "agents_count"
    t.string "department_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "rate_of_autonomous_applicants"
    t.json "rate_of_autonomous_applicants_grouped_by_month"
    t.index ["department_number"], name: "index_stats_on_department_number", unique: true
  end

  create_table "templates", force: :cascade do |t|
    t.integer "model"
    t.string "rdv_title"
    t.string "rdv_title_by_phone"
    t.string "rdv_purpose"
    t.string "applicant_designation"
    t.string "rdv_subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "custom_sentence"
    t.boolean "display_mandatory_warning", default: false
    t.text "punishable_warning", default: "", null: false
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.string "url"
    t.string "secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webhook_receipts", force: :cascade do |t|
    t.bigint "rdv_solidarites_rdv_id"
    t.datetime "rdvs_webhook_timestamp"
    t.datetime "sent_at"
    t.bigint "webhook_endpoint_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rdv_solidarites_rdv_id"], name: "index_webhook_receipts_on_rdv_solidarites_rdv_id", unique: true
    t.index ["webhook_endpoint_id"], name: "index_webhook_receipts_on_webhook_endpoint_id"
  end

  add_foreign_key "agent_roles", "agents"
  add_foreign_key "agent_roles", "organisations"
  add_foreign_key "archives", "applicants"
  add_foreign_key "archives", "departments"
  add_foreign_key "configurations", "file_configurations"
  add_foreign_key "configurations", "motif_categories"
  add_foreign_key "configurations", "organisations"
  add_foreign_key "invitations", "applicants"
  add_foreign_key "invitations", "departments"
  add_foreign_key "invitations", "rdv_contexts"
  add_foreign_key "lieux", "organisations"
  add_foreign_key "messages_configurations", "organisations"
  add_foreign_key "motif_categories", "templates"
  add_foreign_key "motifs", "motif_categories"
  add_foreign_key "motifs", "organisations"
  add_foreign_key "notifications", "participations"
  add_foreign_key "organisations", "departments"
  add_foreign_key "participations", "rdv_contexts"
  add_foreign_key "rdv_contexts", "applicants"
  add_foreign_key "rdv_contexts", "motif_categories"
  add_foreign_key "rdvs", "lieux"
  add_foreign_key "rdvs", "motifs"
  add_foreign_key "rdvs", "organisations"
  add_foreign_key "webhook_receipts", "webhook_endpoints"
end
