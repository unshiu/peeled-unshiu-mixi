require 'oauth/signature/rsa/sha1'

module MixiGadgetIframeControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        layout 'mixi_gadget'
        
        before_filter :signature_require, :only => [:remote_token]
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
  
  # 署名付きリクエストでリクエスト元が正しいかを確認するフィルター
  # そもそもアプリ側から送信されるものが署名付きリクエストでなかった場合、認証されないためその後のメソッドは実行されない
  def signature_require
    signature_key = {
      'mixi.jp' => {
          :secret => AppResources[:mixi][:consumer_secret],
          :outgoing_key => AppResources[:mixi][:consumer_key],
          :container => {
            :endpoint => AppResources[:mixi][:endpoint],
            :content_type => 'application/json',
            :rest => ''
          }
      }
    }
    
    is_valid_request = false

    if params[:oauth_signature_method] == 'HMAC-SHA1'
      # 署名方式が HMAC-SHA1 
      key = params[:oauth_consumer_key]
      is_valid_request = signature_validate(key, signature_key[key][:secret], {:signature_method => 'HMAC-SHA1'})
    elsif params[:oauth_signature_method] == 'RSA-SHA1'
      # 署名方式が RSA-SHA1
      # RSA-SHA1 では 公開鍵のみ必要なので validate メソッドの 第１引数は nil. 公開鍵は第２引数に指定する )
      is_valid_request = signature_validate(nil, AppResources[:mixi][:oauth_public_key], {:signature_method => 'RSA-SHA1'})
    end

    unless is_valid_request
      render :text => '401 Unauthorized', :status => :unauthorized
    end

  end

  def signature_validate(key = CONSUMER_KEY, secret = CONSUMER_SECRET, options={})
    consumer = OAuth::Consumer.new(key, secret, options)
    begin
      signature = OAuth::Signature.build(request) do
        [nil, consumer.secret]
      end
      pass = signature.verify
    rescue OAuth::Signature::UnknownSignatureMethod => e
      logger.error 'An unknown signature method was supplied: ' + e.to_s
    end
    return pass
  end

end