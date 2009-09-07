#
# Mixiでの最終ログイン履歴を取得する
#
module MixiLatestLoginModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        if AppResources[:init][:tokyotyrant_on]
          server_config Rails.env, "config/miyazakiresistance.yml"
          set_timeout AppResources[:init][:tokyotyrant_timeout]
          set_column :app_name,     :string
          set_column :mixi_user_id, :integer
          set_column :latest_login, :datetime
        end
      end
    end
  end
  
  module ClassMethods
    
    # 最終ログイン履歴を更新しその値を返す。
    # return:: MixiLatestLogin　最終ログイン履歴
    def update_latest_login(mixi_user_id)
      return nil unless AppResources[:init][:tokyotyrant_on] 
      
      latest = find_by_mixi_user_id(mixi_user_id)
      if latest.nil?
        latest = create(:app_name => AppResources[:init][:service_name], :mixi_user_id => mixi_user_id, :latest_login => Time.now.to_i)
      else
        latest.latest_login = Time.now.to_i
        latest.save
      end
      latest
    end
    
    # mixiユーザIDから最終ログイン履歴を取得する。ログイン履歴がなければnilを返す
    # _param1_:: mixi_user_id
    # return:: MixiLatestLogin　最終ログイン履歴
    def find_by_mixi_user_id(base_user_id)
      return nil unless AppResources[:init][:tokyotyrant_on] 
      
      find(:first, :conditions => ["app_name = ? and mixi_user_id = ?", AppResources[:init][:service_name], base_user_id])
    end
  end
  
end