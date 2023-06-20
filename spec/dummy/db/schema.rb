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

ActiveRecord::Schema[7.0].define(version: 2023_06_20_194014) do
  create_table "mobile_pass_agents", force: :cascade do |t|
    t.string "username", null: false
    t.string "authenticatable_type"
    t.integer "authenticatable_id"
    t.string "webauthn_identifier"
    t.datetime "registered_at"
    t.datetime "last_authenticated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "index_mobile_pass_agents_on_authenticatable", unique: true
    t.index ["username"], name: "index_mobile_pass_agents_on_username", unique: true
  end

  create_table "mobile_pass_passkeys", force: :cascade do |t|
    t.string "identifier"
    t.string "public_key"
    t.integer "sign_count"
    t.integer "mobile_pass_agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mobile_pass_agent_id"], name: "index_mobile_pass_passkeys_on_mobile_pass_agent_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "mobile_pass_passkeys", "mobile_pass_agents"
end
