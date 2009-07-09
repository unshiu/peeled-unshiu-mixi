#== ManageInflowSummariesControllerModule
# 
module ManageInflowSummariesControllerModule
  
  def index
    @mixi_inflow_summaries = MixiInflowSummary.days.total.find(:all, :order => "start_at desc",
                                                                :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
    @mixi_inflow_masters = MixiInflowMaster.find(:all)
  end
  
  def show
    @total_inflow_summary = MixiInflowSummary.find(params[:id])
    @mixi_inflow_summaries = MixiInflowSummary.days.find(:all, :conditions => [" start_at = ? and end_at = ? and mixi_inflow_master_id != ?", @total_inflow_summary.start_at, @total_inflow_summary.end_at, MixiInflowMaster::TOTAL])
  end
  
  def search
    @mixi_inflow_summary_search = Forms::MixiInflowSummarySearchForm.new(params[:mixi_inflow_summary_search])
    @mixi_inflow_summaries = MixiInflowSummary.find(:all, :conditions => ["summary_type = ? and mixi_inflow_master_id = ? and start_at >= ? and end_at <= ?", @mixi_inflow_summary_search.summary_type, @mixi_inflow_summary_search.mixi_inflow_master_id, @mixi_inflow_summary_search.start_date, @mixi_inflow_summary_search.end_date], 
                                                          :order => "start_at desc", :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
    @mixi_inflow_masters = MixiInflowMaster.find(:all)
    
    render :action => 'index'
  end
  
end