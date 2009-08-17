# == Schema Information
#
# Table name: mixi_tokens
#
#  id         :integer(4)      not null, primary key
#  token      :string(255)
#  use_flag   :boolean(1)
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class MixiToken < ActiveRecord::Base
  include MixiTokenModule
end
