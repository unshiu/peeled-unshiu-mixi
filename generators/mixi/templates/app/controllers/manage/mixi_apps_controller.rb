class Manage::MixiAppsController < Manage::ApplicationController
  
  def index
    @mixi_apps = MixiApp.find(:all, 
                              :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]}, 
                              :order => 'created_at desc')
  end
  
  def new
    @mixi_app = MixiApp.new
  end
  
  def create_confirm
    @mixi_app = MixiApp.new(params[:mixi_app])
    @mixi_app.key_generate
    unless @mixi_app.valid?
      render :action => :new
      return
    end
  end
  
  def create
    @mixi_app = MixiApp.new(params[:mixi_app])
    if cancel?
      render :action => :new
      return 
    end
    
    if @mixi_app.save
      flash[:notice] = ""
    else
      flash[:error] = ""
    end
    redirect_to :action => :index
  end
  
  def show
    @mixi_app = MixiApp.find(params[:id])
  end
  
end
