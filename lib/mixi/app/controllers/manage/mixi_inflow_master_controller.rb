#== ManageInflowMasterControllerModule
# 
module ManageInflowMasterControllerModule
  
  def index
    @mixi_inflow_masters = MixiInflowMaster.find(:all, :order => "created_at desc",
                                                 :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  end
  
  def show
    @mixi_inflow_master = MixiInflowMaster.find(params[:id])
  end
  
  def new
    @mixi_inflow_master = MixiInflowMaster.new
  end
  
  def create_confirm
    @mixi_inflow_master = MixiInflowMaster.new(params[:mixi_inflow_master])
    @mixi_inflow_master.route_key = Util.random_string(32)
    
    unless @mixi_inflow_master.valid?
      render :action => "new"
    end
  end
  
  def create
    @mixi_inflow_master = MixiInflowMaster.new(params[:mixi_inflow_master])
    
    if params[:cancel]
      render :action => "new"
      return 
    end
    
    @mixi_inflow_master.save!
    flash[:notice] = t('view.flash.notice.mixi_inflow_master_create')
    redirect_to :action => :show, :id => @mixi_inflow_master.id
  end
  
  def edit
    @mixi_inflow_master = MixiInflowMaster.find(params[:id])
  end
  
  def update_confirm
    @mixi_inflow_master = MixiInflowMaster.find(params[:id])
    @mixi_inflow_master.attributes = params[:mixi_inflow_master]
    
    unless @mixi_inflow_master.valid?
      render :action => "edit", :id => @mixi_inflow_master.id
    end
  end
  
  def update
    @mixi_inflow_master = MixiInflowMaster.find(params[:id])
    @mixi_inflow_master.attributes = params[:mixi_inflow_master]
    
    if params[:cancel]
      render :action => "edit", :id => @mixi_inflow_master.id
      return 
    end
    
    @mixi_inflow_master.save
    flash[:notice] = t('view.flash.notice.mixi_inflow_master_update')
    redirect_to :action => :show, :id => @mixi_inflow_master.id
  end
  
  def destroy_confirm
    @mixi_inflow_master = MixiInflowMaster.find(params[:id])
  end
  
  def destroy
    if params[:cancel]
      render :action => "show", :id => params[:id]
      return 
    end
    
    MixiInflowMaster.destroy(params[:id])
    flash[:notice] = t('view.flash.notice.mixi_inflow_master_destroy')
    redirect_to :action => :index
  end
  
end