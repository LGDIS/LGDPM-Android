# encoding: utf-8
require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

# ログインコントローラ
class LoginController < Rho::RhoController
  # ログイン画面を表示します
  # GET /Evacuee/login
  def login
    render :action => :login
  end
  
  # ログイン処理を行ないます
  # POST /Evacuee/do_login
  def do_login
    login = Rho::RhoSupport.url_encode(@params['login'])
    password = Rho::RhoSupport.url_encode(@params['password'])
    Rho::AsyncHttp.post(
      :url => Rho::RhoConfig.lgdpm_login_url,
      :body => "user[login]=#{login}&user[password]=#{password}",
      :authorization => {:type => :basic, :username => 'test', :password => '1qazxsw2'},
      :callback => (url_for :action => :httppost_callback))
  end

  # HTTP POST処理のコールバック
  def httppost_callback
    if @params['http_error'] == "201"
      # 認証OK
      @@cookie = @params["headers"]["set-cookie"]
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
  def show_error
    @error_message = Rho::RhoError.new(@@error_params['error_code'].to_i).message
    if @@error_params['http_error']
      @error_detail = "HTTPステータスコード：#{@@error_params['http_error']}<br>#{@@error_params['body']}"
    else
      @error_detail = @@error_params['body']
    end
    render :action => :error
  end
end