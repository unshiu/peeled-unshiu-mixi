#
# 招待履歴計測処理
#
module MixiAppInviteSummaryCreateWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :mixi_app_invite_summary_create_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def update_yesterday
    start_at = Time.now.yesterday.beginning_of_day
    end_at = Time.now.yesterday.end_of_day
    update_summary(MixiAppInviteSummary::SUMMARY_DAY, 1, start_at, end_at)
  end
  
  def update_last_week
    start_at = Time.now.ago(7.days).beginning_of_week
    end_at = Time.now.ago(7.days).end_of_week
    update_summary(MixiAppInviteSummary::SUMMARY_WEEK, 7, start_at, end_at)
  end
  
  def update_month
    start_at = Time.now.last_month.beginning_of_month
    end_at = Time.now.last_month.end_of_month
    update_summary(MixiAppInviteSummary::SUMMARY_MONTH, 30, start_at, end_at)
  end

private
  
  def update_summary(summary_type, before_days, start_at, end_at)
    registed_count = MixiAppInvite.installed.count(:conditions => ["updated_at between ? and ? ", start_at, end_at])
    active_history = MixiActiveHistory.find(:first, :conditions => ["before_days = ? and history_day = ? ", before_days, start_at.to_date])
    
    broadening_coefficient = registed_count.to_f / active_history.user_count
    MixiAppInviteSummary.create({:summary_type => summary_type, :start_at => start_at, :end_at => end_at, 
                                 :registed_mixi_user_count => registed_count, :broadening_coefficient => broadening_coefficient})
  rescue Exception => e
    @logger.error "mixi app invite summary update error \n #{e}"
  end
end