class CreateMixiAppRegists < ActiveRecord::Migration
  def self.up
    create_table :mixi_app_regists do |t|
      t.integer  :mixi_user_id, :null => false
      t.string   :mixi_app_id,  :null => false
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :mixi_app_regists, [:mixi_user_id, :mixi_app_id], :unique => true
  end

  def self.down
    drop_table :mixi_app_regists
  end
end
