#== MixiHelperModule
#
# mixi plugin で共通して利用するhelper
#
module MixiApplicationHelperModule
  
  unless const_defined? :JQUERY_VAR
    JQUERY_VAR = '$'
  end

  def link_to_update(name, options = {}, html_options = nil)
    link_to_function(name, update_function(options), html_options || options.delete(:html))
  end

  def link_to_script(name, options = {}, html_options = nil)
    link_to_function(name, script_function(options), html_options || options.delete(:html))
  end

  def button_to_update(name, options = {}, html_options = nil)
    button_to_function(name, update_function(options), html_options)
  end

  def button_to_script(name, options = {}, html_options = nil)
    button_to_function(name, script_function(options), html_options)
  end

  def update_function(options)
    request_function(options, '$.drecom_mixi_gadget.requestContainer')
  end

  def script_function(options)
    request_function(options, '$.drecom_mixi_gadget.requestScript')
  end

protected

  def request_function(options, function_name)
    function = "#{function_name}("

    url_options = options[:url]
    url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
    function << "'#{escape_javascript(url_for(url_options))}'"

    param_options = '{}'
    if options[:form]
      param_options = "#{JQUERY_VAR}.param(#{JQUERY_VAR}(this).serializeArray())"
    elsif options[:submit]
      param_options = "#{JQUERY_VAR}('##{options[:submit]} :input').serialize()"
    elsif options[:with]
      if options[:with].is_a?(Array) || options[:with].is_a?(Hash)
        param_options = "#{options[:with].to_json.gsub(/\"/,"'")}"
      else
        param_options = "'#{options[:with]}'"
      end
    end
    function << ", #{param_options}" if param_options != '{}' || options[:method]

    if options[:method]
      case options[:method].downcase
      when "get"
        function << ", gadgets.io.MethodType.GET"
      when "post"
        function << ", gadgets.io.MethodType.POST"
      end
    end

    function << ")"

    return function
  end
    
end