#
# アクティブユーザ数履歴計測処理
#
module MixiActiveHistoryCreateWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :mixi_active_history_create_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  # 前日のパラメータで定められたアクティブとする最終ログイン日以降のアクティブユーザ数計測をする
  def update_yesterday_active_count
    today = Date.today
    update_active_count_by_day(today - 1.day, today - AppResources[:mixi][:active_day].day)
  end
  
  # 指定日時以降にログイン履歴があるユーザ数を計算し履歴として更新する
  # 負荷が高い処理なので再計算は明示的に過去履歴が消されたときのみ行う
  # _param1_:: 履歴とする日付
  # _param2_:: アクティブの対象となる最終ログイン日付
  def update_active_count_by_day(history_day, target_day)
    
    history = MixiActiveHistory.find_by_history_day(target_day)
    if history.nil?
      active_count = MixiLatestLogin.count(:conditions => ["latest_login >= ? ", target_day.to_s])
      MixiActiveHistory.create(:history_day => history_day, :user_count => active_count)
    end
    
  rescue Exception => e
    @logger.error "mixi active history update active count \n #{e}"
  end

end
