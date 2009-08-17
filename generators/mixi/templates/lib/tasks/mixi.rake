namespace :unshiu do
  
  namespace :mixi do
    
    namespace :sample do
      
      desc 'create mixi inflow summaries test data generate.'
      task :create_mixi_inflow_summaries => [:environment] do
        MixiInflowSummary.delete_all
        for i in 1..10
          mixi_inflow_master = MixiInflowMaster.new
          mixi_inflow_master.route_name = "route_#{i}"
          mixi_inflow_master.route_key = "route_key_#{i}"
          mixi_inflow_master.save
          
          start = Date.today - 1.years
          for date in start..Date.today
            mixi_inflow_summary = MixiInflowSummary.new
            mixi_inflow_summary.summary_type = MixiInflowSummary::SUMMARY_DAY
            mixi_inflow_summary.start_at = Time.mktime(date.year, date.month, date.day, 0, 0, 0)
            mixi_inflow_summary.end_at = Time.mktime(date.year, date.month, date.day, 23, 59, 59)
            mixi_inflow_summary.mixi_inflow_master_id = mixi_inflow_master.id
            inflow = rand(100000)
            mixi_inflow_summary.inflow_mixi_user_count = inflow
            mixi_inflow_summary.registed_mixi_user_count = inflow - rand(inflow)
            mixi_inflow_summary.save
          end
          
          start = Date.today - 1.years
          1.upto(12) do |n|
            mixi_inflow_summary = MixiInflowSummary.new
            mixi_inflow_summary.summary_type = MixiInflowSummary::SUMMARY_MONTH
            mixi_inflow_summary.start_at = Time.mktime(date.year, n, 1, 0, 0, 0)
            mixi_inflow_summary.end_at = Time.mktime(date.year, n, 1, 0, 0, 0).end_of_month
            mixi_inflow_summary.mixi_inflow_master_id = mixi_inflow_master.id
            inflow = rand(100000)
            mixi_inflow_summary.inflow_mixi_user_count = inflow
            mixi_inflow_summary.registed_mixi_user_count = inflow - rand(inflow)
            mixi_inflow_summary.save
          end
        end
      end
      
      desc 'create mixi app invite summaries test data generate.'
      task :create_mixi_app_invite_summaries => [:environment] do
        
        start = Date.today - 1.years
        for date in start..Date.today
          MixiAppInviteSummary.create({:summary_type => MixiAppInviteSummary::SUMMARY_DAY, 
                                       :start_at => Time.mktime(date.year, date.month, date.day, 0, 0, 0), 
                                       :end_at => Time.mktime(date.year, date.month, date.day, 23, 59, 59), 
                                       :registed_mixi_user_count => rand(10000), :broadening_coefficient => rand(10000)/10000.to_f})
        end
        
        date = Date.today - 1.years
        while date < Date.today
          start_at = date.beginning_of_week
          end_at = date.end_of_week
          MixiAppInviteSummary.create({:summary_type => MixiAppInviteSummary::SUMMARY_WEEK, 
                                       :start_at => Time.mktime(start_at.year, start_at.month, start_at.day, 0, 0, 0), 
                                       :end_at => Time.mktime(end_at.year, end_at.month, end_at.day, 23, 59, 59), 
                                       :registed_mixi_user_count => rand(10000), :broadening_coefficient => rand(10000)/10000.to_f})
          date = date.end_of_week.tomorrow
        end
        
        date = Date.today - 1.years
        while date < Date.today
          start_at = date.beginning_of_month
          end_at = date.end_of_month
          MixiAppInviteSummary.create({:summary_type => MixiAppInviteSummary::SUMMARY_MONTH, 
                                       :start_at => Time.mktime(start_at.year, start_at.month, start_at.day, 0, 0, 0), 
                                       :end_at => Time.mktime(end_at.year, end_at.month, end_at.day, 23, 59, 59), 
                                       :registed_mixi_user_count => rand(10000), :broadening_coefficient => rand(10000)/10000.to_f})
          date = date.end_of_month.tomorrow
        end
      end
      
    end
  end
end