class CreateMixiTokens < ActiveRecord::Migration
  def self.up
    create_table :mixi_tokens do |t|
      t.string   :token
      t.boolean  :use_flag
      t.datetime :deleted_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mixi_tokens
  end
end
