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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130409020218) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "office_address"
    t.text     "delivery_address"
    t.integer  "town_id"
    t.boolean  "is_deleted",       :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "employees", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "address"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.decimal  "average_cost",     :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "selling_price",    :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "inventory_value",  :precision => 12, :scale => 2, :default => 0.0
    t.integer  "ready",                                           :default => 0
    t.integer  "pending_receival",                                :default => 0
    t.integer  "pending_delivery",                                :default => 0
    t.boolean  "is_deleted",                                      :default => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  create_table "material_consumptions", :force => true do |t|
    t.integer  "sales_order_entry_id"
    t.integer  "material_usage_id"
    t.integer  "usage_option_id"
    t.boolean  "is_confirmed",         :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "material_usages", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "price_histories", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.text     "the_role",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sales_order_entries", :force => true do |t|
    t.integer  "sales_order_id"
    t.integer  "entry_id"
    t.integer  "entry_case",                                    :default => 1
    t.integer  "quantity"
    t.decimal  "unit_price",     :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "total_price",    :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "discount",       :precision => 5,  :scale => 2, :default => 0.0
    t.boolean  "is_deleted",                                    :default => false
    t.boolean  "is_confirmed",                                  :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  create_table "sales_orders", :force => true do |t|
    t.integer  "customer_id"
    t.string   "code"
    t.date     "order_date"
    t.boolean  "is_confirmed", :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_deleted",   :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "service_components", :force => true do |t|
    t.decimal  "commission_amount", :precision => 11, :scale => 2, :default => 0.0
    t.integer  "service"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  create_table "service_executions", :force => true do |t|
    t.integer  "service_component_id"
    t.integer  "employee_id"
    t.decimal  "commission_amount",    :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_confirmed",                                        :default => false
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.boolean  "is_deleted",                                   :default => false
    t.decimal  "selling_price", :precision => 11, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "stock_entries", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "source_document_id"
    t.string   "source_document"
    t.integer  "source_document_entry_id"
    t.string   "source_document_entry"
    t.integer  "quantity"
    t.integer  "item_id"
    t.integer  "remaining_quantity"
    t.boolean  "is_finished",                                             :default => false
    t.decimal  "base_price_per_piece",     :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
  end

  create_table "stock_entry_mutations", :force => true do |t|
    t.integer  "stock_entry_id"
    t.integer  "stock_mutation_id"
    t.integer  "quantity"
    t.integer  "case"
    t.integer  "mutation_status",   :default => 2
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "stock_migrations", :force => true do |t|
    t.integer  "item_id"
    t.string   "code"
    t.integer  "creator_id"
    t.integer  "quantity"
    t.boolean  "is_confirmed",                                :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.decimal  "average_cost", :precision => 11, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  create_table "stock_mutations", :force => true do |t|
    t.integer  "quantity"
    t.integer  "stock_entry_usage_id"
    t.string   "source_document_entry"
    t.integer  "source_document_entry_id"
    t.string   "source_document"
    t.integer  "source_document_id"
    t.integer  "mutation_case"
    t.integer  "mutation_status",          :default => 1
    t.integer  "item_status",              :default => 1
    t.integer  "item_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "address"
    t.boolean  "is_deleted",     :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "usage_options", :force => true do |t|
    t.integer  "material_usage_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.boolean  "is_deleted",             :default => false
    t.boolean  "is_main_user",           :default => false
    t.string   "authentication_token"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
