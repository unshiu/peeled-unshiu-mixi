class MixiGadgetController < MixiApplicationController
  include MixiGadgetControllerModule
  
  def top
    @batons = Baton.find(:all, :conditions => ["create_mixi_user_id = ?", session[:owner].id])
  end

end
