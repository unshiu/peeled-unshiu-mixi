class CreateMixiActivities < ActiveRecord::Migration
  def self.up
    create_table :mixi_activities do |t|
      t.integer :create_mixi_user_id,      :null => false
      t.integer :receipt_mixi_user_id, :null => false
      t.text :title
      t.text :body
      t.string :priority
      
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_activities
  end
end
