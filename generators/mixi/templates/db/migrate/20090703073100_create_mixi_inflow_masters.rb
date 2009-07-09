class CreateMixiInflowMasters < ActiveRecord::Migration
  def self.up
    create_table :mixi_inflow_masters do |t|
      t.string :route_name, :null => false
      t.string :route_key, :null => false
      
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_inflow_masters
  end
end
