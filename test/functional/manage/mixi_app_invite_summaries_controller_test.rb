
module Manage::MixiAppInviteSummariesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_profiles
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
        fixtures :mixi_app_invite_summaries
      end
    end
  end

  define_method('test: index は招待者数履歴を表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_app_invite_summaries'])
  end
  
  define_method('test: search は日別の招待者数履歴を検索し表示することができる') do 
    login_as :quentin
  
    1.upto(10) do |i|
      # 検索対象外
      MixiAppInviteSummary.create({:summary_type => MixiAppInviteSummary::SUMMARY_DAY, 
                                   :registed_mixi_user_count => rand(1000), :broadening_coefficient => 0.5,
                                   :start_at => Time.mktime(2008, 1, 20, 0, 0, 0), :end_at => Time.mktime(2008, 1, 20, 23, 59, 59)})
      MixiAppInviteSummary.create({:summary_type => MixiAppInviteSummary::SUMMARY_DAY, 
                                   :registed_mixi_user_count => rand(1000), :broadening_coefficient => 0.5,
                                   :start_at => Time.mktime(2007, 1, 21, 0, 0, 0), :end_at => Time.mktime(2007, 1, 22, 23, 59, 59)})
                                   
      
      # 検索対象内  
      MixiAppInviteSummary.create({:summary_type => MixiAppInviteSummary::SUMMARY_DAY, 
                                   :registed_mixi_user_count => rand(1000), :broadening_coefficient => 0.5,
                                   :start_at => Time.mktime(2008, 1, 21, 0, 0, 0), :end_at => Time.mktime(2008, 1, 22, 23, 59, 59)})

    end
 
    post :search, :mixi_app_invite_summary_search => { 
                               :type => "day", 
                               "start_at(1i)" => 2008, "start_at(2i)" => 1, "start_at(3i)" => 21 ,
                               "end_at(1i)"   => 2009,   "end_at(2i)" => 11,  "end_at(3i)" => 11 }
    assert_response :success
    assert_template 'index'
    
    
    assert_not_nil(assigns['mixi_app_invite_summaries'])
    assert_equal(assigns['mixi_app_invite_summaries'].size, 10)
    assigns['mixi_app_invite_summaries'].each do | mixi_app_invite_summary |
      assert(mixi_app_invite_summary.start_at >= Time.mktime(2008, 1, 21, 0, 0, 0))
      assert(mixi_app_invite_summary.end_at <= Time.mktime(2009, 11, 11, 23, 59, 59))
    end
  end
  
  define_method('test: search は週ごとの招待者数履歴を検索し表示することができる') do 
    login_as :quentin
  
    post :search, :mixi_app_invite_summary_search => { 
                              :type => "week", 
                              "start_at(1i)" => 2008, "start_at(2i)" => 2 ,
                              "end_at(1i)"   => 2010, "end_at(2i)"   => 10 } 
    assert_response :success
    assert_template 'index'
  end
  
  define_method('test: search は月ごとの招待者数履歴を検索し表示することができる') do 
    login_as :quentin
  
    post :search, :mixi_app_invite_summary_search => { 
                              :type => "month", 
                              "start_at(1i)" => 2008, "start_at(2i)" => 2 ,
                              "end_at(1i)"   => 2010, "end_at(2i)"   => 10 } 
    assert_response :success
    assert_template 'index'
  end
end