# encoding: utf-8
require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

# 住所データコントローラ
class AddressController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper

  # 市区町村のオプションタグを返す  
  # GET /Address/cities
  # ==== Args
  # ==== Return
  # 市区町村オプションタグ
  # ==== Raise
  def cities
    render :string => city_options(@params['state_cd']), :partial => true
  end

  # 町目字のオプションタグを返す  
  # GET /Address/streets
  # ==== Args
  # ==== Return
  # 町目字オプションタグ
  # ==== Raise
  def streets
    render :string => street_options(@params['state_cd'], @params['city_cd']), :partial => true
  end

  # 住所マスタダウンロード 
  # GET /Address/download
  # ==== Args
  # ==== Return
  # ==== Raise
  def download
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
    File.delete(file_name) if File.exist?(file_name)
    params = {:url => Rho::RhoConfig.lgdpm_address_download_url,
             :filename => file_name,
             :headers => {},
             :callback => (url_for :action => :download_callback),
             :callback_param => ""}
    unless blank?(Rho::RhoConfig.lgdpm_http_server_authentication)
      params[:authorization] = {:type => Rho::RhoConfig.lgdpm_http_server_authentication.intern,
                               :username => Rho::RhoConfig.lgdpm_http_server_authentication_username,
                               :password => Rho::RhoConfig.lgdpm_http_server_authentication_password }
    end
    Rho::AsyncHttp.download_file(params)
    render :action => :wait
  end

  # 住所マスタダウンロードコールバック
  # ==== Args
  # ==== Return
  # ==== Raise
  def download_callback
    if @params['status'] != 'ok'
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
      File.delete(file_name) if File.exist?(file_name)
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
    else
      Address.load_address()
      Alert.show_popup "住所マスタのダウンロードが完了しました"
      WebView.navigate(Rho::RhoConfig.start_path)
    end
  end
  
  # エラー表示
  # GET /Address/show_error
  # ==== Args
  # ==== Return
  # ==== Raise
  def show_error
    @error_message = Rho::RhoError.new(@@error_params['error_code'].to_i).message
    @error_detail = "HTTPステータスコード：#{@@error_params['http_error']}"
    render :action => :error
  end
end
