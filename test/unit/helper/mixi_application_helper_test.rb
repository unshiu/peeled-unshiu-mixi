module MixiApplicationHelperTestModule
  
  define_method('test: link_to_update は画面更新用の link tag を出力する') do 
    tag = link_to_update("test", :url => "/next_page")
    assert_equal("<a href=\"#\" onclick=\"$.historyLoad('/next_page');; return false;\">test</a>", tag)
  end
  
  define_method('test: link_to_update はオプション指定で遷移履歴を残さないようなJSを出力する') do 
    tag = link_to_update("test", { :url => "/next_page", :history => "false" })
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestContainer('/next_page');; return false;\">test</a>")
  end
  
  define_method('test: link_to_script はJS実行のリクエストをサーバ側へ投げるリンクを出力する') do 
    tag = link_to_script("test", :url => "/request_js")
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestScript('/request_js');; return false;\">test</a>")
  end
  
  define_method('test: link_to_script はJS実行のリクエストをサーバ側へ投げるJSを出力する') do 
    tag = link_to_script("test", :url => "/request_js")
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestScript('/request_js');; return false;\">test</a>")
  end
  
  define_method('test: link_to_canvas は canvas view へ遷移するリンクを出力する') do 
    tag = link_to_canvas("test", :url => "canvas_pagename")
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestNavigateTo('canvas', 'canvas_pagename'); return false;\">test</a>")
  end
  
  define_method('test: link_to_home は home view へ遷移するリンクを出力する') do 
    tag = link_to_home("test", :url => "home_pagename")
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestNavigateTo('home', 'home_pagename'); return false;\">test</a>")
  end
  
  define_method('test: link_to_profile は profile view へ遷移するリンクを出力する') do 
    tag = link_to_profile("test", :url => "profile_pagename")
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestNavigateTo('profile', 'profile_pagename'); return false;\">test</a>")
  end
  
  define_method('test: link_to_preview は preview view へ遷移するリンクを出力する') do 
    tag = link_to_preview("test", :url => "preview_pagename")
    assert_equal(tag, "<a href=\"#\" onclick=\"$.drecom_mixi_gadget.requestNavigateTo('preview', 'preview_pagename'); return false;\">test</a>")
  end
  
  define_method('test: button_to_update は画面更新用の button tag を出力する') do 
    tag = button_to_update("test", :url => "/next_page")
    assert_equal("<input onclick=\"$.historyLoad('/next_page');;\" type=\"button\" value=\"test\" />", tag)
  end
  
  define_method('test: button_to_update はオプション指定で遷移履歴を残さないような button tag を出力する') do 
    tag = button_to_update("test", { :url => "/next_page", :history => "false" })
    assert_equal(tag, "<input onclick=\"$.drecom_mixi_gadget.requestContainer('/next_page');;\" type=\"button\" value=\"test\" />")
  end
  
  define_method('test: button_to_script はJS実行のリクエストをサーバ側へ投げるボタンを出力する') do 
    tag = button_to_script("test", { :url => "/request_js"})
    assert_equal(tag, "<input onclick=\"$.drecom_mixi_gadget.requestScript('/request_js');;\" type=\"button\" value=\"test\" />")
  end
  
  define_method('test: update_function は更新リクエスト用のJSを出力する') do 
    tag = update_function(:url => '/update', :submit => 'update_form', :method => "post")
    assert_equal(tag, "$.drecom_mixi_gadget.requestContainer('/update', $('#update_form :input').serialize(), gadgets.io.MethodType.POST);")
  end
  
  define_method('test: update_function は formのsubmitをにしかけ自分のform内容をパラメータにすることができる') do 
    tag = update_function(:url => '/update', :form => 'true', :method => "get")
    assert_equal(tag, "$.drecom_mixi_gadget.requestContainer('/update', $.param($(this).serializeArray()), gadgets.io.MethodType.GET);")
  end
  
  define_method('test: update_function は withをつかってパラメータを渡すことができる') do 
    tag = update_function(:url => '/update', :method => "get", :with => "test=testest")
    assert_equal(tag, "$.drecom_mixi_gadget.requestContainer('/update', 'test=testest', gadgets.io.MethodType.GET);")
  end
  
  define_method('test: script_function はJSを実行するためのリクエスト用のJSを出力する') do 
    tag = script_function(:url => '/update', :submit => 'update_form', :method => "post")
    assert_equal(tag, "$.drecom_mixi_gadget.requestScript('/update', $('#update_form :input').serialize(), gadgets.io.MethodType.POST);")
  end
  
  define_method('test: script_function は formのsubmitをにしかけ自分のform内容をパラメータにすることができる') do 
    tag = script_function(:url => '/update', :form => 'true', :method => "get")
    assert_equal(tag, "$.drecom_mixi_gadget.requestScript('/update', $.param($(this).serializeArray()), gadgets.io.MethodType.GET);")
  end
  
  define_method('test: script_function は withをつかってパラメータを渡すことができる') do 
    tag = script_function(:url => '/update', :method => "get", :with => "test=testest")
    assert_equal(tag, "$.drecom_mixi_gadget.requestScript('/update', 'test=testest', gadgets.io.MethodType.GET);")
  end
  
  define_method('test: mobile_gadget_url_for は mixiアプリモバイル用のURLを返す') do
    @controller = ActionController::Integration::Session.new
    ActionController::Request.any_instance.stubs(:mobile).returns(nil)
    
    tag = mobile_gadget_url_for(:controller => 'controller', :action => 'action')
    assert_equal(tag, '?url=http%3A%2F%2Flocalhost%3A3000%2Fcontroller%2Faction')
  end

  define_method('test: mobile_gadget_url_for は ドコモ携帯でアクセスしたときのmixiアプリモバイル用のURLを返す') do
    @controller = ActionController::Integration::Session.new
    ActionController::Request.any_instance.stubs(:mobile).returns(Jpmobile::Mobile::Docomo.new(request))
    
    tag = mobile_gadget_url_for(:controller => 'controller', :action => 'action')
    assert_equal(tag, '?guid=ON&url=http%3A%2F%2Flocalhost%3A3000%2Fcontroller%2Faction')
  end

  define_method('test: mobile_gadget_link_to は mixiアプリモバイル用のリンクタグを出力する') do
    @controller = ActionController::Integration::Session.new
    ActionController::Request.any_instance.stubs(:mobile).returns(nil)
    
    tag = mobile_gadget_link_to('link', :controller => 'controller', :action => 'action')
    assert_equal(tag, '<a href="?url=http%3A%2F%2Flocalhost%3A3000%2Fcontroller%2Faction">link</a>')
  end

  define_method('test: mobile_gadget_form_for は mixiアプリモバイル用のformタグを出力する') do
    @controller = ActionController::Integration::Session.new
    ActionController::Request.any_instance.stubs(:mobile).returns(nil)
    
    tag = mobile_gadget_form_for(:form, :url => { :controller => 'controller', :action => 'action' }) {}
    assert_equal(tag, '<form action="?url=http%3A%2F%2Flocalhost%3A3000%2Fcontroller%2Faction" method="post"></form>')
  end

  # 以下のメソッドがないと mobile_gadget_* が失敗する
  def request
    ActionController::Request.new(nil)
  end

  def protect_against_forgery?
    false
  end
  
end
