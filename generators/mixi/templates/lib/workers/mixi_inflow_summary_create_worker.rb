#
# コンバージョン率履歴計測処理
#
class MixiInflowSummaryCreateWorker < BackgrounDRb::MetaWorker
  include MixiInflowSummaryCreateWorkerModule
end

