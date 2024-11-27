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

ActiveRecord::Schema[8.0].define(version: 2024_11_13_104329) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "location", ["inside", "outside"]
  create_enum "state", ["on", "off"]

  create_table "local_weathers", force: :cascade do |t|
    t.float "temperature"
    t.float "humidity"
    t.integer "pressure"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sensor_id", null: false
    t.index ["sensor_id"], name: "index_local_weathers_on_sensor_id"
  end

  create_table "sensors", force: :cascade do |t|
    t.string "name"
    t.enum "location", enum_type: "location"
    t.enum "state", default: "off", enum_type: "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "local_weathers", "sensors"
end
