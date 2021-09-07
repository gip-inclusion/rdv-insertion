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

ActiveRecord::Schema.define(version: 2021_09_07_172021) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_agents_on_email", unique: true
  end

  create_table "agents_departments", id: false, force: :cascade do |t|
    t.bigint "department_id", null: false
    t.bigint "agent_id", null: false
    t.index ["department_id", "agent_id"], name: "index_agents_departments_on_department_id_and_agent_id", unique: true
  end

  create_table "applicants", force: :cascade do |t|
    t.string "uid"
    t.integer "rdv_solidarites_user_id"
    t.string "affiliation_number"
    t.integer "role"
    t.bigint "department_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "custom_id"
    t.index ["department_id"], name: "index_applicants_on_department_id"
    t.index ["rdv_solidarites_user_id"], name: "index_applicants_on_rdv_solidarites_user_id", unique: true
    t.index ["uid"], name: "index_applicants_on_uid", unique: true
  end

  create_table "configurations", force: :cascade do |t|
    t.string "sheet_name"
    t.integer "invitation_format"
    t.bigint "department_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "column_names"
    t.index ["department_id"], name: "index_configurations_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.string "capital"
    t.integer "rdv_solidarites_organisation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "region"
    t.string "phone_number"
    t.index ["rdv_solidarites_organisation_id"], name: "index_departments_on_rdv_solidarites_organisation_id", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "format"
    t.string "link"
    t.string "token"
    t.datetime "sent_at"
    t.bigint "applicant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "seen", default: false
    t.index ["applicant_id"], name: "index_invitations_on_applicant_id"
  end

  add_foreign_key "applicants", "departments"
  add_foreign_key "configurations", "departments"
  add_foreign_key "invitations", "applicants"
end
