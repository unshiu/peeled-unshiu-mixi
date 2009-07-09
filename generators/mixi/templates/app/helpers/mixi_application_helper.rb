module MixiApplicationHelper
  include MixiApplicationHelperModule
  
  def en_color(color_id)
    BatonColor::EN_LIST[color_id]
  end
  
  def paginate(page_enumerator)
    return '' if page_enumerator.last_page == 1 # 1ページしかない場合はリンクはなし
    link_params = params.dup
    link_params.delete('commit')
    link_params.delete('action')
    link_params.delete('controller')
    link_params.delete('page')
    
    <<-END
      <div class="paginate">
  		  <div class="turnover">
  		    #{link_to_update '前へ', :url => url_for({ :page => page_enumerator.previous_page }.merge(link_params)) if page_enumerator.previous_page? }
          #{page_links(page_enumerator, link_params)}
  		    #{link_to_update '次へ', :url => url_for({ :page => page_enumerator.next_page }.merge(link_params)) if page_enumerator.next_page? }
  		  </div>
  		</div>
  	END
  end
  
  def page_links(page_enumerator, link_params)
    result = ''
    current = page_enumerator.page
    last_page = page_enumerator.last_page
    start_page = current - 5
    start_page = 1 if start_page < 1
    end_page = start_page + 10
    end_page = last_page if end_page > last_page
    
    if start_page != 1
      result << '...'
    end
    for i in start_page..end_page
      if i == page_enumerator.page
        result << "<a class='on'>#{i.to_s}</a"
      else
        result << "#{link_to_update(i, :url => url_for({ :page => i }.merge(link_params)))}"
      end
    end
    if end_page != last_page
      result << '...'
    end
    result
  end
  
  def baton_category_icon_url(baton_category)
    "#{request.protocol}#{request.host}:#{request.port}/images/app/icon/genre/#{baton_category.icon}.gif"
  end
  
  def diary_body
    <<-END
      【#{@baton.title}】\n\n#{diary_body_answer(@baton_answers)}#{diary_body_runner(@baton_runners)}\n------\nこのバトンはmixiアプリの\n　#{AppResources[:baton][:mixi_application_url]}　で答えることができます！"
  	END
  end
  
  def diary_body_answer(baton_answers)
    body = ""
    baton_answers.each do |baton_answer|
    	body << "Q, #{h(baton_answer.baton_question.question)}\n"
    	body << "A, #{h(baton_answer.answer)}\n"
    	body <<	"#{h(baton_answer.answer_comment)}\n\n"
    end
    body
  end
  
  def diary_body_runner(baton_runners)
    return "" if baton_runners.empty?
    body = "↓回す人↓\n"
    baton_runners.each do |baton_runner|
    	body << "#{baton_runner.mixi_user.nickname} "
    end
    body
  end
  
  def baton_answer(baton)
    "(回答済み)" if baton.answer?(@mixi_user.id)
  end
end