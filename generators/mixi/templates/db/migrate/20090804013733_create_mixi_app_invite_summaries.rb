class CreateMixiAppInviteSummaries < ActiveRecord::Migration
  def self.up
    create_table :mixi_app_invite_summaries do |t|
      t.integer  :summary_type,              :null => false
      t.datetime :start_at,                  :null => false
      t.datetime :end_at,                    :null => false
      t.integer  :registed_mixi_user_count,  :null => false
      t.float    :broadening_coefficient,    :null => false
      t.datetime :deleted_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_app_invite_summaries
  end
end
