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

ActiveRecord::Schema[7.0].define(version: 2026_04_15_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "deals", force: :cascade do |t|
    t.date "deal_date", null: false
    t.bigint "client_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "buyer_id"
    t.string "quality", null: false
    t.integer "bags", null: false
    t.decimal "rate", precision: 10, scale: 2, null: false
    t.integer "commission_type", default: 0, null: false
    t.decimal "commission_value", precision: 8, scale: 4, null: false
    t.decimal "bill_amount", precision: 12, scale: 2, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["buyer_id"], name: "index_deals_on_buyer_id"
    t.index ["client_id", "deal_date"], name: "index_deals_on_client_id_and_deal_date"
    t.index ["client_id"], name: "index_deals_on_client_id"
    t.index ["deal_date"], name: "index_deals_on_deal_date"
    t.index ["seller_id"], name: "index_deals_on_seller_id"
    t.index ["status"], name: "index_deals_on_status"
  end

  create_table "parties", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.text "address"
    t.string "roles", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_parties_on_name"
    t.index ["roles"], name: "index_parties_on_roles", using: :gin
  end

  add_foreign_key "deals", "parties", column: "buyer_id"
  add_foreign_key "deals", "parties", column: "client_id"
  add_foreign_key "deals", "parties", column: "seller_id"
end
