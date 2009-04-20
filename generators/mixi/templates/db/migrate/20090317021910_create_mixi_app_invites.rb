class CreateMixiAppInvites < ActiveRecord::Migration
  def self.up
    create_table :mixi_app_invites do |t|
      t.integer  :mixi_user_id,    :null => false
      t.integer  :invitee_user_id, :null => false
      t.datetime :deleted_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_app_invites
  end
end
