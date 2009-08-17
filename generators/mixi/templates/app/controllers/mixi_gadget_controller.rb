class MixiGadgetController < MixiApplicationController
  include MixiGadgetControllerModule
  
  # gadgetが表示されて最初に閲覧するページ。アプリ開発者がoverwriteして利用する
  def top
    # application overwrite
  end

end
