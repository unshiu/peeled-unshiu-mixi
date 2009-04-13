ActionController::Routing::Routes.draw do |map|
  map.connect '/gadget.xml', :controller => 'mixi_gadget', :action => 'index', :format => 'xml'
end
