class CreateMixiApps < ActiveRecord::Migration
  def self.up
    create_table :mixi_apps do |t|
      t.string   :name, :null => false
      t.string   :key,  :null => false
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_apps
  end
end
