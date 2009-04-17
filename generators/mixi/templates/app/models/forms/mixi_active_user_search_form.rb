#
# 管理画面でのmixiアクティブユーザ検索用form
#
module Forms
  class MixiActiveUserSearchForm < ActiveForm
    include Forms::MixiActiveUserSearchFormModule
  end
end