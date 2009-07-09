class MixiApplicationController < ApplicationController
  include MixiApplicationControllerModule
  before_filter :color_filter
  
private

  def color_filter
    @baton_color = params[:baton_color].nil? ? BatonColor::RED : params[:baton_color].to_i
  end
  
end