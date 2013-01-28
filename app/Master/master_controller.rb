# encoding: utf-8
require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

# マスタデータコントローラ
class MasterController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper

  # APPLICマスタダウンロード
  def download
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
    File.delete(file_name) if File.exist?(file_name)
    params = {:url => Rho::RhoConfig.lgdpm_master_download_url,
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

  # APPLICマスタダウンロードコールバック
  def download_callback
    if @params['status'] != 'ok'
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
      File.delete(file_name) if File.exist?(file_name)
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
    else
      Master.load_master()
      Alert.show_popup "APPLICマスタのダウンロードが完了しました"
      WebView.navigate(Rho::RhoConfig.start_path)
    end
  end
  
  # エラー表示
  def show_error
    @error_message = Rho::RhoError.new(@@error_params['error_code'].to_i).message
    @error_detail = "HTTPステータスコード：#{@@error_params['http_error']}"
    render :action => :error
  end
end
