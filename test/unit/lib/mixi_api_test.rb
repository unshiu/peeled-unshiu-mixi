require 'opensocial'

module MixiAPITestModule
  define_method('test: register はJSONで受け取ったデータをDBに保存する') do
    owner = { "mixi_id" => 500,
              "nickname" => "jane",
              "thumbnail_url" => "http://unshiu.drecom.jp/profile/500/profile.gif" }.to_json
    friends = { "mixi.jp:501" => { "mixi_id" => 501, "nickname" => "doe",
                                   "thumbnail_url" => "http://unshiu.drecom.jp/profile/501/profile.gif" } }.to_json
    
    MixiAPI.register(owner, owner, friends)
    
    mixi_user = MixiUser.find_by_mixi_id(500)
    assert_equal(mixi_user.nickname, "jane")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/500/profile.gif")
    assert_not_nil(mixi_user.joined_at) # アプリ利用者なのでアプリを利用している
    
    mixi_user = MixiUser.find_by_mixi_id(501)
    assert_equal(mixi_user.nickname, "doe")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/501/profile.gif")
  end
  
  define_method('test: parse_json はJSONをパースする') do
    hash = { "id" => "mixi.jp:1",
             "nickname" => "nick",
             "display_name" => "nick",
             "has_app" => "true",
             "is_viewer" => "true",
             "is_owner" => "true",
             "updated" => "2009-01-01T00:00:00Z",
             "thumbnail_url" => "http://unshiu.drecom.jp/profile/1/profile.gif" }
    assert_equal(MixiAPI.parse_json(hash.to_json), hash)
  end
  
  define_method('test: parse_json にハッシュを渡すとそのまま返す') do
    hash = { "id" => "mixi.jp:1",
             "nickname" => "nick",
             "display_name" => "nick",
             "has_app" => "true",
             "is_viewer" => "true",
             "is_owner" => "true",
             "updated" => "2009-01-01T00:00:00Z",
             "thumbnail_url" => "http://unshiu.drecom.jp/profile/1/profile.gif" }
    assert_equal(MixiAPI.parse_json(hash), hash)
  end
  
  define_method('test: person はコンテナからユーザーの情報を取得する') do
    OpenSocial::FetchPersonRequest.any_instance.stubs(:send).returns(
      { "id" => "mixi.jp:1",
        "nickname" => "nick",
        "display_name" => "nick",
        "has_app" => "true",
        "is_viewer" => "true",
        "is_owner" => "true",
        "updated" => "2009-01-01T00:00:00Z",
        "thumbnail_url" => "http://unshiu.drecom.jp/profile/1/profile.gif" })
    person = MixiAPI::RESTHandler.new('1').person
    expected = { "mixi_id" => "1", "nickname" => "nick", "thumbnail_url" => "http://unshiu.drecom.jp/profile/1/profile.gif" }
    assert_equal(expected, person)
  end
  
  define_method('test: friends はコンテナから友人の情報を取得する') do
    OpenSocial::FetchPeopleRequest.any_instance.stubs(:send).returns(
      { "mixi.jp:2" => {
          "id" => "mixi.jp:2",
          "nickname" => "friend",
          "has_app" => "false",
          "display_name" => "friend",
          "updated" => "2009-01-01T00:00:00Z",
          "thumbnail_url" => "http://unshiu.drecom.jp/profile/2/profile.gif"} })
    friends = MixiAPI::RESTHandler.new('1').friends
    expected = { "mixi.jp:2" => { "mixi_id" => "2", "nickname" => "friend",
                                  "thumbnail_url" => "http://unshiu.drecom.jp/profile/2/profile.gif" }}
    assert_equal(expected, friends)
  end
end