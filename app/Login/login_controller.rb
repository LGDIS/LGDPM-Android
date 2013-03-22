# encoding: utf-8
require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

# ログインコントローラ
class LoginController < Rho::RhoController
  include ApplicationHelper
  
  # ログイン画面を表示します
  # GET /Evacuee/login
  # ==== Args
  # ==== Return
  # ==== Raise
  def login
    render :action => :login
  end
  
  # ログイン処理を行ないます
  # POST /Evacuee/do_login
  # ==== Args
  # ==== Return
  # ==== Raise
  def do_login
    @@login = Rho::RhoSupport.url_encode(@params['login'])
    @@password = Rho::RhoSupport.url_encode(@params['password'])
    http_get_authenticity_token
  end

  # HTTP POST処理のコールバック
  # ==== Args
  # ==== Return
  # ==== Raise
  def http_post_callback
    if @params['http_error'] == "201"
      # 認証OK
      @@cookie = @params["cookies"]
      WebView.navigate(url_for(:controller => :Evacuee, :action => :upload))
    elsif  @params['http_error'] == "401"
      # 認証エラー
      WebView.execute_js("authentication_error()")
    else
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
    end
  end


  # 認証トークンGETコールバック
  # ==== Args
  # ==== Return
  # ==== Raise
  def http_get_callback
    if @params['status'] != 'ok'
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
    else
      if /<input name="authenticity_token" type="hidden" value="([^"]+)"/ =~ @params['body']
        @@authenticity_token = Regexp.last_match(1)
      end
      @@cookie = @params["cookies"] if @params["cookies"]
      http_post
    end
  end

  # エラー表示
  # ==== Args
  # ==== Return
  # ==== Raise
  def show_error
    @error_message = Rho::RhoError.new(@@error_params['error_code'].to_i).message
    if @@error_params['http_error']
      @error_detail = "HTTPステータスコード：#{@@error_params['http_error']}<br>#{@@error_params['body']}"
    else
      @error_detail = @@error_params['body']
    end
    render :action => :error
  end

  # Cookieを返します
  # ==== Args
  # ==== Return
  # Cookie
  # ==== Raise
  def self.get_cookie
    @@cookie
  end

  private

  # HTTP GET 処理
  # HTTP GET により、ログイン画面の認証トークンを取得します。
  # ==== Args
  # ==== Return
  # ==== Raise
  def http_get_authenticity_token
    params = {:url => Rho::RhoConfig.lgdpm_login_url,
             :callback => (url_for :action => :http_get_callback),
             :callback_param => ""}
    unless blank?(Rho::RhoConfig.lgdpm_http_server_authentication)
      params[:authorization] = {:type => Rho::RhoConfig.lgdpm_http_server_authentication.intern,
                               :username => Rho::RhoConfig.lgdpm_http_server_authentication_username,
                               :password => Rho::RhoConfig.lgdpm_http_server_authentication_password }
    end
    Rho::AsyncHttp.get(params)
  end

  # HTTP POST処理
  # HTTP POSTにより、ログイン処理を行ないます。
  # ==== Args
  # ==== Return
  # ==== Raise
  def http_post
    params = {:url => Rho::RhoConfig.lgdpm_login_url + ".json",
             :body => "user[login]=#{Rho::RhoSupport.url_encode(@@login)}&user[password]=#{Rho::RhoSupport.url_encode(@@password)}&authenticity_token=#{Rho::RhoSupport.url_encode(@@authenticity_token)}",
             :headers => {:cookie => @@cookie},
             :callback => (url_for :action => :http_post_callback),
             :callback_param => ""}
    unless blank?(Rho::RhoConfig.lgdpm_http_server_authentication)
      params[:authorization] = {:type => Rho::RhoConfig.lgdpm_http_server_authentication.intern,
                               :username => Rho::RhoConfig.lgdpm_http_server_authentication_username,
                               :password => Rho::RhoConfig.lgdpm_http_server_authentication_password }
    end
    Rho::AsyncHttp.post(params)
  end
end