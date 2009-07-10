#
# コンバージョン率履歴計測処理
#
module MixiInflowSummaryCreateWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :mixi_inflow_summary_create_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def update_yesterday
    start_at = Time.now.yesterday.beginning_of_day
    end_at = Time.now
    update_summary(MixiInflowSummary::SUMMARY_DAY, start_at, end_at)
  end
  
  def update_month
    start_at = Time.now.last_month.beginning_of_month
    end_at = Time.now.last_month.end_of_month
    update_summary(MixiInflowSummary::SUMMARY_MONTH, start_at, end_at)
  end
  
  # 指定開始日から指定終了日までの流入ユーザ数とそのうちアプリへ登録したユーザ数を計算し履歴として保存する
  # 負荷が高い処理なので再計算は明示的に過去履歴が消されたときのみ行う
  # _param1_:: 履歴タイプ
  # _param2_:: 計測開始日
  # _param3_:: 計測終了日
  def update_summary(summary_type, start_at, end_at)
    summary = MixiInflowSummary.find(:first, :conditions => ["summary_type = ? and start_at = ? and end_at = ? ", summary_type, start_at, end_at])
    if summary.nil?
      inflows = MixiInflow.count(:conditions => ["created_at between ? and ? ", start_at, end_at], :group => ["mixi_inflow_master_id"])
      registeds = MixiInflow.count(:conditions => ["registed_at between ? and ? ", start_at, end_at], :group => ["mixi_inflow_master_id"])
      
      inflows.each do |inflow|
        regsited_count = registeds[inflow[0]] ? registeds[inflow[0]] : 0
        MixiInflowSummary.create(:summary_type => summary_type, :start_at => start_at, :end_at => end_at,
                                 :inflow_mixi_user_count => inflow[1], :registed_mixi_user_count => regsited_count,
                                 :mixi_inflow_master_id => inflow[0])
      end
      
      total_inflow = MixiInflow.count(:conditions => ["created_at between ? and ? ", start_at, end_at])
      total_registed = MixiInflow.count(:conditions => ["registed_at between ? and ? ", start_at, end_at])
      MixiInflowSummary.create(:summary_type => summary_type, :start_at => start_at, :end_at => end_at,
                               :inflow_mixi_user_count => total_inflow, :registed_mixi_user_count => total_registed,
                               :mixi_inflow_master_id => MixiInflowMaster::TOTAL)
      
    end
    
  rescue Exception => e
    @logger.error "mixi inflow summary update error \n #{e}"
  end
  
  
end