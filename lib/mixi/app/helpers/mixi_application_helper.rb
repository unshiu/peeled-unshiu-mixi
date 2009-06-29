#== MixiHelperModule
#
# mixi plugin で共通して利用するhelper
#
module MixiApplicationHelperModule
  
  unless const_defined? :JQUERY_VAR
    JQUERY_VAR = '$'
  end

  # 画面を更新することで画面遷移処理をするリンクを出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  # 
  # option:
  # * <tt>:url</tt> - 必須。遷移先URL
  # * <tt>:history</tt> - 履歴を残すかどうか。デフォルトtrue
  def link_to_update(name, options = {}, html_options = nil)
    options[:history] ||= "true"
    link_to_function(name, update_function(options), html_options || options.delete(:html))
  end

  # JS実行リクエスト用のlink_toタグを出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。呼び出しjsのURL
  def link_to_script(name, options = {}, html_options = nil)
    link_to_function(name, script_function(options), html_options || options.delete(:html))
  end

  # Gadgetのcanvasへ遷移するリンクを出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。canvasへ渡すpagename
  def link_to_canvas(name, options = {}, html_options = nil)
    requestNavigateTo("canvas", name, options, html_options)
  end
  
  # Gadgetのhomeへ遷移するリンクを出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。homeへ渡すpagename
  def link_to_home(name, options = {}, html_options = nil)
    requestNavigateTo("home", name, options, html_options)
  end
  
  # Gadgetのprofileへ遷移するリンクを出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。profileへ渡すpagename
  def link_to_profile(name, options = {}, html_options = nil)
    requestNavigateTo("profile", name, options, html_options)
  end
  
  # Gadgetのpreviewへ遷移するリンクを出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。previewへ渡すpagename
  def link_to_preview(name, options = {}, html_options = nil)
    requestNavigateTo("preview", name, options, html_options)
  end
  
  # 画面を更新することで画面遷移処理をする button tag を出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。遷移先URL
  # * <tt>:history</tt> - 履歴を残すかどうか。デフォルトtrue
  def button_to_update(name, options = {}, html_options = nil)
    options[:history] ||= "true"
    button_to_function(name, update_function(options), html_options)
  end

  # JS実行リクエスト用の button tag を出力する
  # _param1_:: name
  # _param2_:: options
  # _param3_:: html_options
  #
  # option:
  # * <tt>:url</tt> - 必須。呼び出しjsのURL
  def button_to_script(name, options = {}, html_options = nil)
    button_to_function(name, script_function(options), html_options)
  end
  
  # 更新リクエストをサーバへ送るJSを出力する
  # _param1_:: options
  #
  # option:
  # * <tt>:url</tt> - 必須。リクエストを送るURL
  # * <tt>:method</tt> - 必須。post or get  
  # * <tt>:form</tt> - フォームの内容をシリアライズして送信する（formのsubmitボタンに仕掛ける場合）
  # * <tt>:submit</tt> - 指定値をformタグのid値を持つフォームの内容をシリアライズして送信する
  # * <tt>:with</tt> - javascript値を渡したい場合指定する
  def update_function(options)
    request_function(options, "#{JQUERY_VAR}.drecom_mixi_gadget.requestContainer")
  end
  
  # JSを実行するためのリクエストをサーバへ送るJSを出力する
  # _param1_:: options
  #
  # option:
  # * <tt>:url</tt> - 必須。リクエストを送るURL
  # * <tt>:method</tt> - 必須。post or get  
  # * <tt>:form</tt> - フォームの内容をシリアライズして送信する（formのsubmitボタンに仕掛ける場合）
  # * <tt>:submit</tt> - 指定値をformタグのid値を持つフォームの内容をシリアライズして送信する
  # * <tt>:with</tt> - javascript値を渡したい場合指定する
  def script_function(options)
    request_function(options, "#{JQUERY_VAR}.drecom_mixi_gadget.requestScript")
  end
  
  # activityを投稿するJSを出力する
  # _param1_:: options
  #
  # option:
  # * <tt>:title</tt> - 必須。タイトル
  # * <tt>:body</tt> - 必須。本文
  # * <tt>:priority</tt> - 優先度。デフォルトではHIGH
  def post_activity(options)
    options[:priority] ||= "HIGH"
    "#{JQUERY_VAR}.opensocial_simple.postActivity({'TITLE' : '#{options[:title]}', 'BODY' : '#{options[:body]}'}, '#{options[:priority]}' , function () { /* console.log(arguments) */ } /* optional */);"
  end
  
private

  def request_function(options, function_name)
    function = "#{function_name}("

    url_options = options[:url]
    url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
    function << "'#{escape_javascript(url_for(url_options))}'"

    param_options = '{}'
    if options[:form]
      param_options = "#{JQUERY_VAR}.param(#{JQUERY_VAR}(this).serializeArray())"
    elsif options[:submit]
      param_options = "#{JQUERY_VAR}('##{options[:submit]} :input').serialize()"
    elsif options[:with]
      if options[:with].is_a?(Array) || options[:with].is_a?(Hash)
        param_options = "#{options[:with].to_json.gsub(/\"/,"'")}"
      else
        param_options = "'#{options[:with]}'"
      end
    end
    function << ", #{param_options}" if param_options != '{}' || options[:method]

    if options[:method]
      case options[:method].downcase
      when "get"
        function << ", gadgets.io.MethodType.GET"
      when "post"
        function << ", gadgets.io.MethodType.POST"
      end
    end

    function << ");"
    
    if ActiveRecord::ConnectionAdapters::Column.value_to_boolean(options[:history])
      function << "#{JQUERY_VAR}.historyLoad('#{escape_javascript(options[:url])}');"
    end
    
    return function
  end
  
  def requestNavigateTo(view_name, name, options = {}, html_options = nil)
    link_to_function(name, "#{JQUERY_VAR}.drecom_mixi_gadget.requestNavigateTo('#{view_name}', '#{options[:url]}')", html_options || options.delete(:html))
  end
  
end