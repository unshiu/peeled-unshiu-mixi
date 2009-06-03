class CreateMixiUsers < ActiveRecord::Migration
  def self.up
    create_table :mixi_users do |t|
      t.string   :mixi_id,      :null => false
      t.integer  :base_user_id
      t.string   :nickname
      t.string   :profile_url
      t.string   :thumbnail_url
      t.integer  :status
      t.datetime :joined_at
      t.datetime :quitted_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :mixi_users, :mixi_id, :unique => true
  end

  def self.down
    drop_table :mixi_users
  end
end
