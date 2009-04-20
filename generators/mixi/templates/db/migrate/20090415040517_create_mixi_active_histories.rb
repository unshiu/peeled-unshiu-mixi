class CreateMixiActiveHistories < ActiveRecord::Migration
  def self.up
    create_table :mixi_active_histories do |t|
      t.date    :history_day 
      t.integer :user_count

      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_active_histories
  end
end
