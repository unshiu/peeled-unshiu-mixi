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

#
# MixiでのActivity履歴を保持する
#
module MixiActivityModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :create_mixi_user, :foreign_key => "create_mixi_user_id", :class_name => "MixiUser"
        belongs_to :receipt_mixi_user, :foreign_key => "receipt_mixi_user_id", :class_name => "MixiUser"
      end
    end
  end
  
  module ClassMethods
  end
  
  def to_mobile_gadget_json
    %({"title":"#{self.title}"})
  end
end
