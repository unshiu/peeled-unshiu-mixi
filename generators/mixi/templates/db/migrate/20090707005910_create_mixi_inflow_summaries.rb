class CreateMixiInflowSummaries < ActiveRecord::Migration
  def self.up
    create_table :mixi_inflow_summaries do |t|
      t.integer  :summary_type,              :null => false
      t.datetime :start_at,                  :null => false
      t.datetime :end_at,                    :null => false
      t.integer  :inflow_mixi_user_count,    :null => false
      t.integer  :registed_mixi_user_count,  :null => false
      t.integer  :mixi_inflow_master_id,     :null => false
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_inflow_summaries
  end
end
