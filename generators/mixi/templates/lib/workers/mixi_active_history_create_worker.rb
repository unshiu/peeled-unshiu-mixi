#
# アクティブユーザ数履歴計測処理
#
class MixiActiveHistoryCreateWorker < BackgrounDRb::MetaWorker
  include MixiActiveHistoryCreateWorkerModule
end
