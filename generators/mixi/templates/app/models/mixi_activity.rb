# == Schema Information
#
# Table name: mixi_activities
#
#  id                   :integer(4)      not null, primary key
#  create_mixi_user_id  :integer(4)      not null
#  receipt_mixi_user_id :integer(4)      not null
#  title                :text
#  body                 :text
#  priority             :string(255)
#  deleted_at           :datetime
#  created_at           :datetime
#  updated_at           :datetime
#

class MixiActivity < ActiveRecord::Base
  include MixiActivityModule
end
