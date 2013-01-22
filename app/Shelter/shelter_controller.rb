require 'rho/rhocontroller'
require 'helpers/browser_helper'

# 避難所コントローラ
class ShelterController < Rho::RhoController
  # 避難所マスタダウンロード
  def download
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
    File.delete(file_name) if File.exist?(file_name)
    Rho::AsyncHttp.download_file(
      :url => Rho::RhoConfig.lgdpm_shelter_download_url,
      :filename => file_name,
      :headers => {},
      :callback => (url_for :action => :download_callback),
      :callback_param => "" )
    render :action => :wait
  end

  # 避難所マスタダウンロードコールバック
  def download_callback
    if @params['status'] != 'ok'
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
      File.delete(file_name) if File.exist?(file_name)
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
    else
      Shelter.load_shelter()
      Alert.show_popup "避難所マスタのダウンロードが完了しました"
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
