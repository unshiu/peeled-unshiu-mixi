#== ManageMixiActiveHistoriesControllerModule
# 
module ManageMixiActiveHistoriesControllerModule
  
  def index
    if params[:year]
      @mixi_active_histories = MixiActiveHistory.by_year_period(params[:year].to_i).find(:all, :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})      
    else
      @mixi_active_histories = MixiActiveHistory.find(:all, :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
    end
    
    @years = []
    (MixiActiveHistory.oldest_year..MixiActiveHistory.newest_year).each { |year| @years << year }
  end

  def month
    @mixi_active_histories = MixiActiveHistory.summary_by_year_month(params[:year])
    @years = []
    (MixiActiveHistory.oldest_year..MixiActiveHistory.newest_year).each { |year| @years << year }
  end
  
  def year
    @mixi_active_histories = MixiActiveHistory.summary_by_year
  end
  
  def search
    active_mixi_user_search_form = Forms::MixiActiveUserSearchForm.new(params[:mixi_user_active_seach])
    unless active_mixi_user_search_form.valid?
      @mixi_active_histories = MixiActiveHistory.find(:all, :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
      @years = []
      (MixiActiveHistory.oldest_year..MixiActiveHistory.newest_year).each { |year| @years << year }
      render :action => 'index'
      return
    end
    
    @active_users = Array.new

    if active_mixi_user_search_form.day? # 日別表示
      histories = MixiActiveHistory.period(active_mixi_user_search_form.start_date, active_mixi_user_search_form.end_date)
      histories.each do |history|
        active_user = Hash.new
        active_user[:date] = history.history_day.strftime('%Y/%m/%d')
        active_user[:count] = history.user_count
        @active_users << active_user
      end

    elsif active_mixi_user_search_form.month? # 月別表示

      histories = MixiActiveHistory.summary_period_by_year_month(active_mixi_user_search_form.start_date, active_mixi_user_search_form.end_date)
      histories.each do |history|
        active_user = Hash.new
        active_user[:date] = history.history_day.strftime('%Y/%m')
        active_user[:count] = history.user_count
        @active_users << active_user
      end
    end
    
  end
  
  
end