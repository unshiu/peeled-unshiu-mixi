#
# Mixiの最終ログイン履歴を取得する
#
require 'miyazakiresistance'

class MixiLatestLogin < MiyazakiResistance::Base
  include MixiLatestLoginModule
end
