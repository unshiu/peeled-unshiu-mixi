class MixiAppInvitesAddColumnInviteStatus < ActiveRecord::Migration
  def self.up
    add_column :mixi_app_invites,  :invite_status,  :integer
  end

  def self.down
    remove_column :mixi_app_invites,  :invite_status
  end
end
