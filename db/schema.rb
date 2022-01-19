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

ActiveRecord::Schema.define(version: 2022_01_17_163650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_agents_on_email", unique: true
  end

  create_table "agents_organisations", id: false, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "agent_id", null: false
    t.index ["organisation_id", "agent_id"], name: "index_agents_organisations_on_organisation_id_and_agent_id", unique: true
  end

  create_table "applicants", force: :cascade do |t|
    t.string "uid"
    t.integer "rdv_solidarites_user_id"
    t.string "affiliation_number"
    t.integer "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "department_internal_id"
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "phone_number"
    t.string "email"
    t.integer "title"
    t.date "birth_date"
    t.date "invitation_accepted_at"
    t.integer "status", default: 0
    t.date "rights_opening_date"
    t.string "birth_name"
    t.bigint "department_id"
    t.index ["department_id"], name: "index_applicants_on_department_id"
    t.index ["department_internal_id", "department_id"], name: "index_applicants_on_department_internal_id_and_department_id", unique: true
    t.index ["rdv_solidarites_user_id"], name: "index_applicants_on_rdv_solidarites_user_id", unique: true
    t.index ["status"], name: "index_applicants_on_status"
    t.index ["uid"], name: "index_applicants_on_uid", unique: true
  end

  create_table "applicants_organisations", id: false, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "applicant_id", null: false
    t.index ["organisation_id", "applicant_id"], name: "index_applicants_orgas_on_orga_id_and_applicant_id", unique: true
  end

  create_table "applicants_rdvs", id: false, force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.bigint "rdv_id", null: false
    t.index ["applicant_id", "rdv_id"], name: "index_applicants_rdvs_on_applicant_id_and_rdv_id", unique: true
  end

  create_table "configurations", force: :cascade do |t|
    t.string "sheet_name"
    t.integer "invitation_format"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "column_names"
    t.boolean "notify_applicant", default: false
    t.bigint "organisation_id"
    t.index ["organisation_id"], name: "index_configurations_on_organisation_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.string "capital"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "region"
    t.string "pronoun"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "format"
    t.string "link"
    t.string "token"
    t.datetime "sent_at"
    t.bigint "applicant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "clicked", default: false
    t.string "context"
    t.string "help_phone_number"
    t.bigint "department_id"
    t.index ["applicant_id"], name: "index_invitations_on_applicant_id"
    t.index ["department_id"], name: "index_invitations_on_department_id"
  end

  create_table "invitations_organisations", id: false, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "invitation_id", null: false
    t.index ["organisation_id", "invitation_id"], name: "index_invitations_orgas_on_orga_id_and_invitation_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.integer "event"
    t.datetime "sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "rdv_solidarites_rdv_id"
    t.index ["applicant_id"], name: "index_notifications_on_applicant_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "email"
    t.integer "rdv_solidarites_organisation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "department_id"
    t.string "rsa_agents_service_id"
    t.index ["department_id"], name: "index_organisations_on_department_id"
    t.index ["rdv_solidarites_organisation_id"], name: "index_organisations_on_rdv_solidarites_organisation_id", unique: true
  end

  create_table "rdvs", force: :cascade do |t|
    t.bigint "rdv_solidarites_rdv_id"
    t.datetime "starts_at"
    t.integer "duration_in_min"
    t.datetime "cancelled_at"
    t.bigint "rdv_solidarites_motif_id"
    t.bigint "rdv_solidarites_lieu_id"
    t.string "uuid"
    t.string "address"
    t.integer "created_by"
    t.integer "status"
    t.text "context"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "organisation_id"
    t.index ["created_by"], name: "index_rdvs_on_created_by"
    t.index ["organisation_id"], name: "index_rdvs_on_organisation_id"
    t.index ["rdv_solidarites_rdv_id"], name: "index_rdvs_on_rdv_solidarites_rdv_id", unique: true
    t.index ["status"], name: "index_rdvs_on_status"
  end

  add_foreign_key "applicants", "departments"
  add_foreign_key "configurations", "organisations"
  add_foreign_key "invitations", "applicants"
  add_foreign_key "invitations", "departments"
  add_foreign_key "notifications", "applicants"
  add_foreign_key "organisations", "departments"
  add_foreign_key "rdvs", "organisations"
end
