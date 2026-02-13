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

ActiveRecord::Schema[8.1].define(version: 2026_02_13_163154) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "business_locations", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address1"
    t.string "address2"
    t.bigint "business_id", null: false
    t.string "city"
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.text "instructions"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "name", null: false
    t.string "postal_code"
    t.string "region"
    t.datetime "updated_at", null: false
    t.index ["business_id", "active"], name: "index_business_locations_on_business_id_and_active"
    t.index ["business_id"], name: "index_business_locations_on_business_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "status", default: "active", null: false
    t.string "support_email"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_businesses_on_slug", unique: true
    t.index ["status"], name: "index_businesses_on_status"
  end

  create_table "drivers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name"
    t.decimal "last_latitude", precision: 10, scale: 8
    t.datetime "last_location_at"
    t.decimal "last_longitude", precision: 11, scale: 8
    t.string "license_number"
    t.string "password_digest", null: false
    t.string "phone", null: false
    t.decimal "rating", precision: 3, scale: 2
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "vehicle_type"
    t.datetime "verified_at"
    t.index "lower((email)::text)", name: "index_drivers_on_lower_email", unique: true
    t.index ["phone"], name: "index_drivers_on_phone", unique: true
    t.index ["status"], name: "index_drivers_on_status"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "family", null: false
    t.datetime "last_used_at"
    t.bigint "owner_id", null: false
    t.string "owner_type", null: false
    t.datetime "revoked_at"
    t.string "token_hash", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "family"], name: "index_refresh_tokens_on_owner_type_and_owner_id_and_family"
    t.index ["owner_type", "owner_id"], name: "index_refresh_tokens_on_owner"
    t.index ["owner_type", "owner_id"], name: "index_refresh_tokens_on_owner_type_and_owner_id"
    t.index ["token_hash"], name: "index_refresh_tokens_on_token_hash", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "name"], name: "index_roles_on_business_id_and_name", unique: true
    t.index ["business_id"], name: "index_roles_on_business_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["business_id"], name: "index_users_on_business_id"
  end

  add_foreign_key "business_locations", "businesses"
  add_foreign_key "roles", "businesses"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "businesses"
end
