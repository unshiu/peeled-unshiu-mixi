require 'oauth/signature/rsa/sha1'

module MixiGadgetIframeControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        layout 'mixi_gadget'
        
        before_filter :token_require, :only => [:index]
      end
    end
  end
  
  def remote_token
    token = Digest::SHA1.hexdigest(Time.now.to_i.to_s + Util.random_string(32))
    @mixi_token = MixiToken.create(:token => token)
    
    render :text => @mixi_token.token
  end
  
  # iframeでアプリケーションを開いたときに表示するトップページ。アプリ開発者がoverwriteして利用する
  def index
  end
  
private

  def token_require
    @mixi_token = MixiToken.find_by_token(params[:mixi_token])
    if @mixi_token.nil? || @mixi_token.use_flag 
      redirect_to_error("U-10000")
    else
      @mixi_token.use_flag = true
      @mixi_token.save
      true
    end
  end

end