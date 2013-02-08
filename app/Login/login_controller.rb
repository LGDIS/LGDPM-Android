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
    login = Rho::RhoSupport.url_encode(@params['login'])
    password = Rho::RhoSupport.url_encode(@params['password'])
    params = {:url => Rho::RhoConfig.lgdpm_login_url,
             :body => "user[login]=#{login}&user[password]=#{password}",
             :callback => (url_for :action => :httppost_callback),
             :callback_param => ""}
    unless blank?(Rho::RhoConfig.lgdpm_http_server_authentication)
      params[:authorization] = {:type => Rho::RhoConfig.lgdpm_http_server_authentication.intern,
                               :username => Rho::RhoConfig.lgdpm_http_server_authentication_username,
                               :password => Rho::RhoConfig.lgdpm_http_server_authentication_password }
    end
    Rho::AsyncHttp.post(params)
  end

  # HTTP POST処理のコールバック
  # ==== Args
  # ==== Return
  # ==== Raise
  def httppost_callback
    if @params['http_error'] == "201"
      # 認証OK
      @@cookie = @params["cookies"]
      url = url_for(:controller => :Evacuee, :action => :upload)
      WebView.navigate(url_for(:controller => :Evacuee, :action => :upload))
    elsif  @params['http_error'] == "401"
      # 認証エラー
      WebView.execute_js("authentication_error()")
    else
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
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
end