class CreateMixiFriends < ActiveRecord::Migration
  def self.up
    create_table :mixi_friends do |t|
      t.integer  :mixi_user_id,     :null => false
      t.integer  :friend_id,        :null => false
      t.datetime :deleted_at
      
      t.timestamps
    end
    add_index :mixi_friends, [:mixi_user_id, :friend_id], :unique => true
  end

  def self.down
    drop_table :mixi_friends
  end
end
