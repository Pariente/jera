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

ActiveRecord::Schema.define(version: 20170420133258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "title"
    t.text     "content"
    t.date     "published_date"
    t.string   "media_url"
    t.string   "thumbnail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entries", ["source_id"], name: "index_entries_on_source_id", using: :btree

  create_table "entry_actions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "entry_id"
    t.integer  "source_id"
    t.boolean  "harvested",  default: false
    t.boolean  "masked",     default: false
    t.boolean  "read",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_user_id"
    t.integer "status",         default: 0
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "status",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "memberships", ["team_id"], name: "index_memberships_on_team_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "recommendation_id"
    t.text     "text"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "messages", ["recommendation_id"], name: "index_messages_on_recommendation_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "recommendations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "receiver_id"
    t.integer  "team_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "entry_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.string   "rss_url"
    t.string   "picture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "colour",     default: 0
  end

  add_index "subscriptions", ["source_id"], name: "index_subscriptions_on_source_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "status",     default: 0
    t.string   "picture"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",                                 null: false
    t.string   "encrypted_password",     default: "",                                 null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                                  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.string   "username"
    t.string   "picture",                default: "/images/default_user_picture.png"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
