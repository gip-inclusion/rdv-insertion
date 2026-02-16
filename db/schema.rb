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

ActiveRecord::Schema[8.1].define(version: 2026_02_11_105902) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "address_geocodings", force: :cascade do |t|
    t.string "city"
    t.string "city_code"
    t.datetime "created_at", null: false
    t.string "department_number"
    t.string "house_number"
    t.float "latitude"
    t.float "longitude"
    t.string "post_code"
    t.string "street"
    t.string "street_ban_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_address_geocodings_on_user_id", unique: true
  end

  create_table "agent_roles", force: :cascade do |t|
    t.string "access_level", default: "basic", null: false
    t.bigint "agent_id", null: false
    t.boolean "authorized_to_export_csv", default: false
    t.datetime "created_at", null: false
    t.datetime "last_webhook_update_received_at"
    t.bigint "organisation_id", null: false
    t.bigint "rdv_solidarites_agent_role_id"
    t.datetime "updated_at", null: false
    t.index ["access_level"], name: "index_agent_roles_on_access_level"
    t.index ["agent_id", "organisation_id"], name: "index_agent_roles_on_agent_id_and_organisation_id", unique: true
    t.index ["agent_id"], name: "index_agent_roles_on_agent_id"
    t.index ["organisation_id"], name: "index_agent_roles_on_organisation_id"
    t.index ["rdv_solidarites_agent_role_id"], name: "index_agent_roles_on_rdv_solidarites_agent_role_id", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.datetime "cgu_accepted_at"
    t.datetime "created_at", null: false
    t.string "crisp_token"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.datetime "last_webhook_update_received_at"
    t.bigint "rdv_solidarites_agent_id"
    t.boolean "super_admin", default: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_agents_on_email", unique: true
    t.index ["rdv_solidarites_agent_id"], name: "index_agents_on_rdv_solidarites_agent_id", unique: true
  end

  create_table "agents_rdvs", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.bigint "rdv_id", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "rdv_id"], name: "index_agents_rdvs_on_agent_id_and_rdv_id", unique: true
  end

  create_table "api_calls", force: :cascade do |t|
    t.string "action_name", null: false
    t.bigint "agent_id"
    t.string "controller_name", null: false
    t.datetime "created_at", null: false
    t.string "host"
    t.string "http_method", null: false
    t.string "path", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_api_calls_on_agent_id"
    t.index ["created_at"], name: "index_api_calls_on_created_at"
  end

  create_table "archives", force: :cascade do |t|
    t.string "archiving_reason"
    t.datetime "created_at", null: false
    t.bigint "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organisation_id"], name: "index_archives_on_organisation_id"
    t.index ["user_id"], name: "index_archives_on_user_id"
  end

  create_table "blocked_invitations_counters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number_of_invitations_affected"
    t.bigint "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_blocked_invitations_counters_on_organisation_id"
  end

  create_table "blocked_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_blocked_users_on_created_at", order: :desc
    t.index ["user_id"], name: "index_blocked_users_on_user_id"
  end

  create_table "category_configurations", force: :cascade do |t|
    t.boolean "convene_user", default: true
    t.datetime "created_at", null: false
    t.integer "department_position", default: 0
    t.string "email_to_notify_no_available_slots"
    t.string "email_to_notify_rdv_changes"
    t.bigint "file_configuration_id"
    t.string "invitation_formats", default: ["sms", "email", "postal"], null: false, array: true
    t.boolean "invite_to_user_organisations_only", default: true
    t.bigint "motif_category_id"
    t.integer "number_of_days_before_invitations_expire", default: 10
    t.bigint "organisation_id"
    t.string "phone_number"
    t.integer "position", default: 0
    t.boolean "rdv_with_referents", default: false
    t.string "template_rdv_purpose_override"
    t.string "template_rdv_title_by_phone_override"
    t.string "template_rdv_title_override"
    t.string "template_user_designation_override"
    t.datetime "updated_at", null: false
    t.index ["file_configuration_id"], name: "index_category_configurations_on_file_configuration_id"
    t.index ["motif_category_id"], name: "index_category_configurations_on_motif_category_id"
    t.index ["organisation_id"], name: "index_category_configurations_on_organisation_id"
  end

  create_table "cookies_consents", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.boolean "support_accepted", default: false
    t.boolean "tracking_accepted", default: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_cookies_consents_on_agent_id"
  end

  create_table "creneau_availabilities", force: :cascade do |t|
    t.bigint "category_configuration_id", null: false
    t.datetime "created_at", null: false
    t.integer "number_of_creneaux_available"
    t.integer "number_of_pending_invitations"
    t.datetime "updated_at", null: false
    t.index ["category_configuration_id"], name: "index_creneau_availabilities_on_category_configuration_id"
    t.index ["created_at"], name: "index_creneau_availabilities_on_created_at"
  end

  create_table "csv_exports", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.string "kind"
    t.datetime "purged_at"
    t.json "request_params"
    t.bigint "structure_id", null: false
    t.string "structure_type", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_csv_exports_on_agent_id"
    t.index ["structure_type", "structure_id"], name: "index_csv_exports_on_structure"
  end

  create_table "departments", force: :cascade do |t|
    t.string "capital"
    t.datetime "created_at", null: false
    t.boolean "disable_ft_webhooks", default: false
    t.boolean "display_in_stats", default: true
    t.string "email"
    t.string "name"
    t.string "number"
    t.boolean "parcours_enabled", default: true
    t.string "phone_number"
    t.string "pronoun"
    t.string "region"
    t.datetime "updated_at", null: false
  end

  create_table "dpa_agreements", force: :cascade do |t|
    t.string "agent_email"
    t.string "agent_full_name"
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.bigint "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_dpa_agreements_on_agent_id"
    t.index ["organisation_id"], name: "index_dpa_agreements_on_organisation_id"
  end

  create_table "file_configurations", force: :cascade do |t|
    t.string "address_fifth_field_column"
    t.string "address_first_field_column"
    t.string "address_fourth_field_column"
    t.string "address_second_field_column"
    t.string "address_third_field_column"
    t.string "affiliation_number_column"
    t.string "birth_date_column"
    t.string "birth_name_column"
    t.datetime "created_at", null: false
    t.bigint "created_by_agent_id"
    t.string "department_internal_id_column"
    t.string "email_column"
    t.string "first_name_column"
    t.string "france_travail_id_column"
    t.string "last_name_column"
    t.string "nir_column"
    t.string "organisation_search_terms_column"
    t.string "phone_number_column"
    t.string "referent_email_column"
    t.string "rights_opening_date_column"
    t.string "role_column"
    t.string "sheet_name"
    t.string "tags_column"
    t.string "title_column"
    t.datetime "updated_at", null: false
    t.index ["created_by_agent_id"], name: "index_file_configurations_on_created_by_agent_id"
  end

  create_table "follow_ups", force: :cascade do |t|
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.bigint "motif_category_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["motif_category_id"], name: "index_follow_ups_on_motif_category_id"
    t.index ["status"], name: "index_follow_ups_on_status"
    t.index ["user_id"], name: "index_follow_ups_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.boolean "clicked", default: false
    t.datetime "created_at", null: false
    t.string "delivery_status"
    t.bigint "department_id"
    t.datetime "expires_at"
    t.bigint "follow_up_id"
    t.string "format"
    t.string "help_phone_number"
    t.datetime "last_brevo_webhook_received_at"
    t.string "link"
    t.bigint "rdv_solidarites_lieu_id"
    t.string "rdv_solidarites_token"
    t.boolean "rdv_with_referents", default: false
    t.string "sms_provider"
    t.string "trigger", default: "manual", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "uuid"
    t.index ["department_id"], name: "index_invitations_on_department_id"
    t.index ["expires_at"], name: "index_invitations_on_expires_at"
    t.index ["follow_up_id"], name: "index_invitations_on_follow_up_id"
    t.index ["trigger"], name: "index_invitations_on_trigger"
    t.index ["user_id"], name: "index_invitations_on_user_id"
    t.index ["uuid"], name: "index_invitations_on_uuid", unique: true
  end

  create_table "invitations_organisations", id: false, force: :cascade do |t|
    t.bigint "invitation_id", null: false
    t.bigint "organisation_id", null: false
    t.index ["organisation_id", "invitation_id"], name: "index_invitations_orgas_on_orga_id_and_invitation_id", unique: true
  end

  create_table "lieux", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "last_webhook_update_received_at"
    t.string "name"
    t.bigint "organisation_id", null: false
    t.string "phone_number"
    t.bigint "rdv_solidarites_lieu_id"
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_lieux_on_organisation_id"
  end

  create_table "messages_configurations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction_names", array: true
    t.string "help_address"
    t.string "letter_sender_name"
    t.string "logos_to_display", default: ["department"], array: true
    t.bigint "organisation_id"
    t.string "sender_city"
    t.string "signature_lines", array: true
    t.string "sms_sender_name"
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_messages_configurations_on_organisation_id"
  end

  create_table "motif_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "motif_category_type", default: "Autre", null: false
    t.string "name"
    t.bigint "rdv_solidarites_motif_category_id"
    t.string "short_name"
    t.bigint "template_id"
    t.datetime "updated_at", null: false
    t.index ["rdv_solidarites_motif_category_id"], name: "index_motif_categories_on_rdv_solidarites_motif_category_id", unique: true
    t.index ["short_name"], name: "index_motif_categories_on_short_name", unique: true
    t.index ["template_id"], name: "index_motif_categories_on_template_id"
  end

  create_table "motifs", force: :cascade do |t|
    t.string "bookable_by"
    t.boolean "collectif"
    t.datetime "created_at", null: false
    t.integer "default_duration_in_min"
    t.datetime "deleted_at"
    t.boolean "follow_up", default: false
    t.text "instruction_for_rdv", default: ""
    t.datetime "last_webhook_update_received_at"
    t.string "location_type"
    t.bigint "motif_category_id"
    t.string "name"
    t.bigint "organisation_id", null: false
    t.bigint "rdv_solidarites_motif_id"
    t.bigint "rdv_solidarites_service_id"
    t.datetime "updated_at", null: false
    t.index ["motif_category_id"], name: "index_motifs_on_motif_category_id"
    t.index ["organisation_id"], name: "index_motifs_on_organisation_id"
    t.index ["rdv_solidarites_motif_id"], name: "index_motifs_on_rdv_solidarites_motif_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "delivery_status"
    t.string "event"
    t.string "format"
    t.datetime "last_brevo_webhook_received_at"
    t.bigint "participation_id"
    t.bigint "rdv_solidarites_rdv_id"
    t.string "sms_provider"
    t.datetime "updated_at", null: false
    t.index ["participation_id"], name: "index_notifications_on_participation_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.integer "data_retention_duration_in_months", default: 24, null: false
    t.bigint "department_id"
    t.boolean "display_in_stats", default: true
    t.string "email"
    t.datetime "last_webhook_update_received_at"
    t.string "name"
    t.string "organisation_type"
    t.string "phone_number"
    t.bigint "rdv_solidarites_organisation_id"
    t.string "safir_code"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["archived_at"], name: "index_organisations_on_archived_at"
    t.index ["department_id"], name: "index_organisations_on_department_id"
    t.index ["rdv_solidarites_organisation_id"], name: "index_organisations_on_rdv_solidarites_organisation_id", unique: true
  end

  create_table "orientation_types", force: :cascade do |t|
    t.string "casf_category"
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_orientation_types_on_department_id"
  end

  create_table "orientations", force: :cascade do |t|
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.date "ends_at"
    t.bigint "organisation_id", null: false
    t.bigint "orientation_type_id"
    t.date "starts_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["agent_id"], name: "index_orientations_on_agent_id"
    t.index ["organisation_id"], name: "index_orientations_on_organisation_id"
    t.index ["orientation_type_id"], name: "index_orientations_on_orientation_type_id"
    t.index ["starts_at", "ends_at"], name: "index_orientations_on_starts_at_and_ends_at"
    t.index ["user_id"], name: "index_orientations_on_user_id"
  end

  create_table "parcours_documents", force: :cascade do |t|
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.bigint "department_id", null: false
    t.datetime "document_date"
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["agent_id"], name: "index_parcours_documents_on_agent_id"
    t.index ["department_id"], name: "index_parcours_documents_on_department_id"
    t.index ["type"], name: "index_parcours_documents_on_type"
    t.index ["user_id"], name: "index_parcours_documents_on_user_id"
  end

  create_table "participations", force: :cascade do |t|
    t.boolean "convocable", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "created_by_agent_prescripteur", default: false
    t.string "created_by_type"
    t.bigint "follow_up_id"
    t.string "france_travail_id"
    t.bigint "rdv_id", null: false
    t.bigint "rdv_solidarites_created_by_id"
    t.bigint "rdv_solidarites_participation_id"
    t.string "status", default: "unknown"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["follow_up_id"], name: "index_participations_on_follow_up_id"
    t.index ["status"], name: "index_participations_on_status"
    t.index ["user_id", "rdv_id"], name: "index_participations_on_user_id_and_rdv_id", unique: true
  end

  create_table "rdvs", force: :cascade do |t|
    t.string "address"
    t.datetime "cancelled_at", precision: nil
    t.text "context"
    t.datetime "created_at", null: false
    t.string "created_by"
    t.integer "duration_in_min"
    t.datetime "last_webhook_update_received_at"
    t.bigint "lieu_id"
    t.integer "max_participants_count"
    t.bigint "motif_id"
    t.bigint "organisation_id"
    t.bigint "rdv_solidarites_rdv_id"
    t.datetime "starts_at", precision: nil
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "users_count", default: 0
    t.string "uuid"
    t.string "visio_url"
    t.index ["created_by"], name: "index_rdvs_on_created_by"
    t.index ["lieu_id"], name: "index_rdvs_on_lieu_id"
    t.index ["motif_id"], name: "index_rdvs_on_motif_id"
    t.index ["organisation_id"], name: "index_rdvs_on_organisation_id"
    t.index ["rdv_solidarites_rdv_id"], name: "index_rdvs_on_rdv_solidarites_rdv_id", unique: true
    t.index ["status"], name: "index_rdvs_on_status"
  end

  create_table "referent_assignations", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "agent_id"], name: "index_referent_assignations_on_user_id_and_agent_id", unique: true
  end

  create_table "stats", force: :cascade do |t|
    t.integer "agents_count"
    t.float "average_time_between_invitation_and_rdv_in_days"
    t.json "average_time_between_invitation_and_rdv_in_days_by_month", default: {}
    t.datetime "created_at", null: false
    t.float "rate_of_autonomous_users"
    t.json "rate_of_autonomous_users_grouped_by_month", default: {}
    t.float "rate_of_no_show"
    t.float "rate_of_no_show_for_convocations"
    t.json "rate_of_no_show_for_convocations_grouped_by_month", default: {}
    t.float "rate_of_no_show_for_invitations"
    t.json "rate_of_no_show_for_invitations_grouped_by_month", default: {}
    t.json "rate_of_no_show_grouped_by_month", default: {}
    t.float "rate_of_users_accompanied_in_less_than_30_days"
    t.json "rate_of_users_accompanied_in_less_than_30_days_by_month", default: {}
    t.float "rate_of_users_oriented"
    t.json "rate_of_users_oriented_grouped_by_month", default: {}
    t.float "rate_of_users_oriented_in_less_than_45_days"
    t.json "rate_of_users_oriented_in_less_than_45_days_by_month", default: {}
    t.json "rdvs_count_grouped_by_month", default: {}
    t.json "sent_invitations_count_grouped_by_month", default: {}
    t.bigint "statable_id"
    t.string "statable_type"
    t.datetime "updated_at", null: false
    t.json "users_count_grouped_by_month", default: {}
    t.json "users_with_rdv_count_grouped_by_month", default: {}
    t.index ["statable_type", "statable_id"], name: "index_stats_on_statable"
  end

  create_table "super_admin_authentication_requests", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "invalidated_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "verification_attempts", default: 0, null: false
    t.datetime "verified_at"
    t.index ["agent_id"], name: "index_super_admin_authentication_requests_on_agent_id"
  end

  create_table "tag_organisations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organisation_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_tag_organisations_on_organisation_id"
    t.index ["tag_id"], name: "index_tag_organisations_on_tag_id"
  end

  create_table "tag_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["tag_id", "user_id"], name: "index_tag_users_on_tag_id_and_user_id", unique: true
    t.index ["tag_id"], name: "index_tag_users_on_tag_id"
    t.index ["user_id"], name: "index_tag_users_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "custom_sentence"
    t.boolean "display_mandatory_warning", default: false
    t.string "model"
    t.text "punishable_warning", default: "", null: false
    t.string "rdv_purpose"
    t.string "rdv_subject"
    t.string "rdv_title"
    t.string "rdv_title_by_phone"
    t.datetime "updated_at", null: false
    t.string "user_designation"
  end

  create_table "user_list_upload_invitation_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "format"
    t.string "internal_error_message"
    t.bigint "invitation_id"
    t.string "service_errors", default: [], array: true
    t.boolean "success"
    t.datetime "updated_at", null: false
    t.uuid "user_row_id", null: false
    t.index ["invitation_id"], name: "index_user_list_upload_invitation_attempts_on_invitation_id"
    t.index ["user_row_id"], name: "index_user_list_upload_invitation_attempts_on_user_row_id"
  end

  create_table "user_list_upload_processing_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "invitations_ended_at"
    t.datetime "invitations_started_at"
    t.datetime "invitations_triggered_at"
    t.datetime "updated_at", null: false
    t.uuid "user_list_upload_id", null: false
    t.datetime "user_saves_ended_at"
    t.datetime "user_saves_started_at"
    t.datetime "user_saves_triggered_at"
    t.index ["user_list_upload_id"], name: "index_user_list_upload_processing_logs_on_user_list_upload_id"
  end

  create_table "user_list_upload_user_rows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.string "affiliation_number"
    t.integer "assigned_organisation_id"
    t.date "birth_date"
    t.string "birth_name"
    t.json "cnaf_data", default: {}
    t.datetime "created_at", null: false
    t.string "department_internal_id"
    t.string "email"
    t.string "first_name"
    t.string "france_travail_id"
    t.string "last_name"
    t.bigint "matching_user_id"
    t.string "nir"
    t.string "organisation_search_terms"
    t.string "phone_number"
    t.string "referent_email"
    t.date "rights_opening_date"
    t.string "role"
    t.boolean "selected_for_invitation", default: false
    t.boolean "selected_for_user_save", default: false
    t.string "tag_values", default: [], array: true
    t.string "title"
    t.datetime "updated_at", null: false
    t.uuid "user_list_upload_id", null: false
    t.index ["assigned_organisation_id"], name: "index_user_list_upload_user_rows_on_assigned_organisation_id"
    t.index ["matching_user_id"], name: "index_user_list_upload_user_rows_on_matching_user_id"
    t.index ["user_list_upload_id"], name: "index_user_list_upload_user_rows_on_user_list_upload_id"
  end

  create_table "user_list_upload_user_save_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_type"
    t.string "internal_error_message"
    t.string "service_errors", default: [], array: true
    t.boolean "success"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.uuid "user_row_id", null: false
    t.index ["user_id"], name: "index_user_list_upload_user_save_attempts_on_user_id"
    t.index ["user_row_id"], name: "index_user_list_upload_user_save_attempts_on_user_row_id"
  end

  create_table "user_list_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "category_configuration_id"
    t.datetime "created_at", null: false
    t.string "file_name"
    t.string "origin", null: false
    t.bigint "structure_id", null: false
    t.string "structure_type", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_user_list_uploads_on_agent_id"
    t.index ["category_configuration_id"], name: "index_user_list_uploads_on_category_configuration_id"
    t.index ["origin"], name: "index_user_list_uploads_on_origin"
    t.index ["structure_type", "structure_id"], name: "index_user_list_uploads_on_structure"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.string "affiliation_number"
    t.date "birth_date"
    t.string "birth_name"
    t.datetime "created_at", null: false
    t.bigint "created_from_structure_id"
    t.string "created_from_structure_type"
    t.string "created_through"
    t.datetime "deleted_at"
    t.string "department_internal_id"
    t.string "email"
    t.string "first_name"
    t.string "france_travail_id"
    t.string "last_name"
    t.datetime "last_webhook_update_received_at"
    t.string "nir"
    t.bigint "old_rdv_solidarites_user_id"
    t.string "phone_number"
    t.bigint "rdv_solidarites_user_id"
    t.date "rights_opening_date"
    t.string "role"
    t.string "title"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["created_from_structure_type", "created_from_structure_id"], name: "index_users_on_created_from_structure"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["department_internal_id"], name: "index_users_on_department_internal_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["nir"], name: "index_users_on_nir"
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["rdv_solidarites_user_id"], name: "index_users_on_rdv_solidarites_user_id", unique: true
    t.index ["role", "affiliation_number"], name: "index_users_on_role_and_affiliation_number"
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "users_organisations", force: :cascade do |t|
    t.datetime "created_at"
    t.bigint "organisation_id", null: false
    t.datetime "updated_at"
    t.bigint "user_id", null: false
    t.index ["organisation_id", "user_id"], name: "index_applicants_orgas_on_orga_id_and_applicant_id", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.string "item_id", null: false
    t.string "item_type", null: false
    t.jsonb "object"
    t.jsonb "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organisation_id"
    t.string "secret"
    t.string "signature_type", default: "hmac"
    t.string "subscriptions", array: true
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["organisation_id"], name: "index_webhook_endpoints_on_organisation_id"
  end

  create_table "webhook_receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "resource_id"
    t.string "resource_model"
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.bigint "webhook_endpoint_id"
    t.index ["resource_model", "resource_id", "webhook_endpoint_id"], name: "index_on_webhook_endpoint_and_resource_model_and_id"
    t.index ["webhook_endpoint_id"], name: "index_webhook_receipts_on_webhook_endpoint_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "address_geocodings", "users"
  add_foreign_key "agent_roles", "agents"
  add_foreign_key "agent_roles", "organisations"
  add_foreign_key "api_calls", "agents"
  add_foreign_key "archives", "organisations"
  add_foreign_key "archives", "users"
  add_foreign_key "blocked_invitations_counters", "organisations"
  add_foreign_key "blocked_users", "users"
  add_foreign_key "category_configurations", "file_configurations"
  add_foreign_key "category_configurations", "motif_categories"
  add_foreign_key "category_configurations", "organisations"
  add_foreign_key "cookies_consents", "agents"
  add_foreign_key "creneau_availabilities", "category_configurations"
  add_foreign_key "csv_exports", "agents"
  add_foreign_key "dpa_agreements", "agents"
  add_foreign_key "dpa_agreements", "organisations"
  add_foreign_key "file_configurations", "agents", column: "created_by_agent_id"
  add_foreign_key "follow_ups", "motif_categories"
  add_foreign_key "follow_ups", "users"
  add_foreign_key "invitations", "departments"
  add_foreign_key "invitations", "follow_ups"
  add_foreign_key "invitations", "users"
  add_foreign_key "lieux", "organisations"
  add_foreign_key "messages_configurations", "organisations"
  add_foreign_key "motif_categories", "templates"
  add_foreign_key "motifs", "motif_categories"
  add_foreign_key "motifs", "organisations"
  add_foreign_key "notifications", "participations"
  add_foreign_key "organisations", "departments"
  add_foreign_key "orientation_types", "departments"
  add_foreign_key "orientations", "agents"
  add_foreign_key "orientations", "organisations"
  add_foreign_key "orientations", "orientation_types"
  add_foreign_key "orientations", "users"
  add_foreign_key "parcours_documents", "agents"
  add_foreign_key "parcours_documents", "departments"
  add_foreign_key "parcours_documents", "users"
  add_foreign_key "participations", "follow_ups"
  add_foreign_key "rdvs", "lieux"
  add_foreign_key "rdvs", "motifs"
  add_foreign_key "rdvs", "organisations"
  add_foreign_key "super_admin_authentication_requests", "agents"
  add_foreign_key "tag_organisations", "organisations"
  add_foreign_key "tag_organisations", "tags"
  add_foreign_key "tag_users", "tags"
  add_foreign_key "tag_users", "users"
  add_foreign_key "user_list_upload_invitation_attempts", "invitations"
  add_foreign_key "user_list_upload_invitation_attempts", "user_list_upload_user_rows", column: "user_row_id"
  add_foreign_key "user_list_upload_processing_logs", "user_list_uploads"
  add_foreign_key "user_list_upload_user_rows", "user_list_uploads"
  add_foreign_key "user_list_upload_user_rows", "users", column: "matching_user_id"
  add_foreign_key "user_list_upload_user_save_attempts", "user_list_upload_user_rows", column: "user_row_id"
  add_foreign_key "user_list_upload_user_save_attempts", "users"
  add_foreign_key "user_list_uploads", "agents"
  add_foreign_key "user_list_uploads", "category_configurations"
  add_foreign_key "webhook_receipts", "webhook_endpoints"
end
