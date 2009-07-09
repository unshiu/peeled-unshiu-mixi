#== MixiInflowsControllerModule
# 
# サービスへの登録流入先を記録する
#
module MixiInflowsControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        layout 'mixi_gadget'
      end
    end
  end
  
  def add
    @unique_key = Time.now.to_i.to_s + Util.random_string(32)
    
    master = MixiInflowMaster.find_by_route_key(params[:key]) if params[:key]
    master_key = master ? master.id : MixiInflowMaster::OTHER
    
    @next_url = params[:next_url] ? params[:next_url] : AppResources[:mixi][:default_inflow_next_url]
    MixiInflow.create({:mixi_inflow_master_id => master_key, :referrer => request.referer, :tracking_key => @unique_key})
  end
  
  def show
    @mixi_user_id = params[:mixi_user_id]
    @app_name = params[:app_name]
  end
  
  def create
    mixi_inflow = MixiInflow.find_by_tracking_key(params[:tracking_key])
    if mixi_inflow
      mixi_inflow.mixi_user_id = params[:mixi_user_id]
      mixi_inflow.app_name = params[:app_name]
      mixi_inflow.registed_at = Time.now
      mixi_inflow.save
    end
    render :text => "OK"
  end

end