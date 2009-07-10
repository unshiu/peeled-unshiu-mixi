#
# MixiUserの登録：一部遅延していいものだけバックグラウンドで行う
#
class MixiUserRegistWorker < BackgrounDRb::MetaWorker
  include MixiUserRegistWorkerModule
end

