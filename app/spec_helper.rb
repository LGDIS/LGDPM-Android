class SpecHelper
  def self.create_request(url, params={})
    method, model, *action = url.split("/")
    request = {}
    request['application'] = 'app'
    request['model'] = model
    request['request-method'] = method.rstrip
    request[:modelpath] = Rho::RhoApplication::get_model_path('app',model)
    request['headers'] = {"Content-Type"=>"application/x-www-form-urlencoded"}
    if action.size > 1
      request['id'] = action[0]
      request['action'] = action[1]
    else
      request['action'] = action[0]
    end
    request['request-body'] = create_request_body(params)
    
    request
  end
  
  def self.create_request_body(params={})
    request_body = ""
    params.each do |key, value|
      if value.is_a?(Hash)
        value.each do |sub_key, sub_value|
          request_body << "&#{key}[#{sub_key}]=#{Rho::RhoSupport.url_encode(sub_value)}"
        end
      else
        request_body << "&#{key}=#{Rho::RhoSupport.url_encode(value)}"
      end
    end
    request_body.slice!(0) unless request_body.empty?
    request_body
  end
end
