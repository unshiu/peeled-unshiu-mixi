# == Schema Information
#
# Table name: mixi_active_histories
#
#  id          :integer(4)      not null, primary key
#  history_day :date
#  user_count  :integer(4)
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class MixiActiveHistory < ActiveRecord::Base
  include MixiActiveHistoryModule
end
