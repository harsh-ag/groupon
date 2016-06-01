# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160527110051) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "deal_images", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "deal_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "deal_images", ["deal_id"], name: "index_deal_images_on_deal_id", using: :btree

  create_table "deals", force: :cascade do |t|
    t.string   "title",                limit: 255,                                           null: false
    t.text     "description",          limit: 65535
    t.integer  "min_qty",              limit: 4
    t.integer  "max_qty",              limit: 4
    t.datetime "start_time"
    t.datetime "expire_time"
    t.decimal  "price",                              precision: 8, scale: 2
    t.integer  "max_qty_per_customer", limit: 4
    t.text     "instructions",         limit: 65535
    t.boolean  "publishable",                                                default: false
    t.integer  "category_id",          limit: 4,                                             null: false
    t.integer  "merchant_id",          limit: 4,                                             null: false
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
  end

  add_index "deals", ["category_id"], name: "index_deals_on_category_id", using: :btree
  add_index "deals", ["merchant_id"], name: "index_deals_on_merchant_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "address",    limit: 255, null: false
    t.string   "city",       limit: 255, null: false
    t.string   "state",      limit: 255, null: false
    t.string   "country",    limit: 255, null: false
    t.integer  "deal_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "locations", ["deal_id"], name: "index_locations_on_deal_id", using: :btree

  create_table "merchants", force: :cascade do |t|
    t.string   "name",            limit: 255, null: false
    t.string   "email",           limit: 255, null: false
    t.string   "password_digest", limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "merchants", ["email"], name: "index_merchants_on_email", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                   limit: 255,                 null: false
    t.string   "last_name",                    limit: 255,                 null: false
    t.string   "email",                        limit: 255,                 null: false
    t.string   "password_digest",              limit: 255,                 null: false
    t.boolean  "admin",                                    default: false
    t.string   "remember_token",               limit: 255
    t.string   "verification_token",           limit: 255
    t.datetime "verification_token_expire_at"
    t.datetime "verified_at"
    t.string   "forgot_password_token",        limit: 255
    t.datetime "forgot_password_expire_at"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["forgot_password_token"], name: "index_users_on_forgot_password_token", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["verification_token"], name: "index_users_on_verification_token", using: :btree

  add_foreign_key "deal_images", "deals"
  add_foreign_key "deals", "categories"
  add_foreign_key "deals", "merchants"
  add_foreign_key "locations", "deals"
end
