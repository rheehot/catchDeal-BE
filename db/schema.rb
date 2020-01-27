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

ActiveRecord::Schema.define(version: 2020_01_27_070750) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_users", force: :cascade do |t|
    t.string "app_player", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_token"
    t.boolean "alarm_status", default: true, null: false
    t.integer "max_push_count", default: 5, null: false
  end

  create_table "book_marks", force: :cascade do |t|
    t.bigint "app_user_id", null: false
    t.bigint "hit_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_user_id"], name: "index_book_marks_on_app_user_id"
    t.index ["hit_product_id"], name: "index_book_marks_on_hit_product_id"
  end

  create_table "hit_products", force: :cascade do |t|
    t.string "product_id"
    t.datetime "date", default: -> { "CURRENT_TIMESTAMP" }
    t.string "title"
    t.boolean "is_sold_out"
    t.string "website"
    t.integer "view", default: 0
    t.integer "comment", default: 0
    t.integer "like", default: 0
    t.integer "score", default: 0
    t.string "image_url", default: "0"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dead_check", default: false
    t.string "redirect_url"
    t.boolean "is_title_changed", default: false
  end

  create_table "keyword_alarms", force: :cascade do |t|
    t.bigint "app_user_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_user_id"], name: "index_keyword_alarms_on_app_user_id"
  end

  create_table "keyword_pushalarm_lists", force: :cascade do |t|
    t.bigint "app_user_id", null: false
    t.string "keyword_title", null: false
    t.bigint "hit_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_user_id"], name: "index_keyword_pushalarm_lists_on_app_user_id"
    t.index ["hit_product_id"], name: "index_keyword_pushalarm_lists_on_hit_product_id"
  end

  create_table "notices", force: :cascade do |t|
    t.string "user_id"
    t.string "title"
    t.string "category", default: "일반"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "admin", default: false
    t.string "nickname"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "book_marks", "hit_products"
end
