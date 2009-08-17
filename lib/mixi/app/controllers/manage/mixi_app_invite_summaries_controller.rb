#== ManageMixiAppInviteSummariesControllerModule
# 
module ManageMixiAppInviteSummariesControllerModule
  
  def index
    @mixi_app_invite_summaries = MixiAppInviteSummary.find(:all, :conditions => ["summary_type = ?", MixiAppInviteSummary::SUMMARY_DAY], 
                                                           :order => "start_at desc",
                                                           :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  end
  
  def search
    @mixi_app_invite_summary_search = Forms::MixiAppInviteSummarySearchForm.new(params[:mixi_app_invite_summary_search])
    unless @mixi_app_invite_summary_search.valid?
      render :action => 'index'
      return
    end

    @mixi_app_invite_summaries = MixiAppInviteSummary.find(:all, :conditions => ["summary_type = ? and start_at between ? and ?", @mixi_app_invite_summary_search.summary_type, @mixi_app_invite_summary_search.start_date, @mixi_app_invite_summary_search.end_date], 
                                                           :order => "start_at desc",
                                                           :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  
    render :action => 'index'
  end
  
end