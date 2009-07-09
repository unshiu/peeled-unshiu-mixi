class CreateMixiInflows < ActiveRecord::Migration
  def self.up
    create_table :mixi_inflows do |t|
      t.integer :mixi_inflow_master_id,  :null => false
      t.text :referrer
      t.string :tracking_key
      t.string :app_name
      t.integer :mixi_user_id
      t.datetime :registed_at
      
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_inflows
  end
end
