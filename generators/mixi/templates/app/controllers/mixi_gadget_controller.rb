class MixiGadgetController < MixiApplicationController
  include MixiGadgetControllerModule
  
  # gadgetが表示されて最初に閲覧するページ。アプリ開発者がoverwriteして利用する
  # pnt_filter_title:　mixiアプリトップを表示
  def top
    # application overwrite
  end

  # モバイル版で最初に閲覧するページ。アプリ開発者がoverwriteして利用する
  def top_mobile
    # application overwrite
  end

end
