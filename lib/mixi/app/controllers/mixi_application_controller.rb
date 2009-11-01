#== MixiApplicationControllerModule
# 
# mixi plugin を利用する際全アプリケーション的に必要なModule
#
module MixiApplicationControllerModule

private
  
  # 現在そのアプリを閲覧しているユーザを返す
  def current_mixiapp_viewer
    session[:opensocial_viewer] ? session[:opensocial_viewer].dup : MixiUser.find_by_mixi_id(params[:opensocial_viewer_id])
  end
  
  # 現在そのアプリのガジェットを所有しているユーザを返す
  def current_mixiapp_owner
    session[:opensocial_owner] ? session[:opensocial_owner].dup : MixiUser.find_by_mixi_id(params[:opensocial_owner_id])
  end
  
  def validate_session
    if current_mixiapp_viewer
      true
    else
      respond_to do |format|
        format.html { redirect_to :controller => 'mixi_gadget', :action => 'timeout', :format => 'html' }
        format.js   { redirect_to :controller => 'mixi_gadget', :action => 'timeout', :format => 'js' }
      end
      false
    end
  end
  
  def redirect_mixi_gadget_to(options = {}, response_status = {})
    options[:opensocial_viewer_id] = current_mixiapp_viewer.mixi_id
    options[request.session_options[:key]] = request.session_options[:id]
    redirect_to(options, response_status)
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
