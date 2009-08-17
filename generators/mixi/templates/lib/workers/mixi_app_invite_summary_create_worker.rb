#
# 招待統計履歴計測処理
#
class MixiAppInviteSummaryCreateWorker < BackgrounDRb::MetaWorker
  include MixiAppInviteSummaryCreateWorkerModule
end

