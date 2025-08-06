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

ActiveRecord::Schema[8.0].define(version: 2025_07_21_141358) do
  create_table "ahoy_messages", id: :string, force: :cascade do |t|
    t.string "user_type"
    t.integer "user_id"
    t.text "to"
    t.string "mailer"
    t.text "subject"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_type", "user_id"], name: "index_ahoy_messages_on_user_type_and_user_id"
  end

  create_table "mailkick_subscriptions", force: :cascade do |t|
    t.string "subscriber_type"
    t.integer "subscriber_id"
    t.string "list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscriber_type", "subscriber_id", "list"], name: "index_mailkick_subscriptions_on_subscriber_and_list", unique: true
  end

  create_table "newsletters", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.boolean "published"
    t.date "publish_date"
    t.boolean "sent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscribers", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
