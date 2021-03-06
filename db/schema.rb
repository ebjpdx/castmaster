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

ActiveRecord::Schema.define(version: 20161114215600) do

  create_table "dependency_runs", force: :cascade do |t|
    t.integer  "forecast_run_id",           null: false
    t.integer  "dependent_forecast_run_id", null: false
    t.text     "name",                      null: false
    t.text     "target_table",              null: false
    t.text     "dependency_name",           null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "forecast_runs", force: :cascade do |t|
    t.text     "name",           null: false
    t.text     "target_table",   null: false
    t.text     "grain",          null: false
    t.date     "training_start"
    t.date     "training_end"
    t.date     "forecast_start"
    t.date     "forecast_end"
    t.text     "parameters"
    t.date     "date_reaped"
    t.text     "status"
    t.text     "error_message"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end


end
