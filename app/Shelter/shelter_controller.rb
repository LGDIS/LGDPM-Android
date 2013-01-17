require 'rho/rhocontroller'
require 'helpers/browser_helper'

# 避難所コントローラ
class ShelterController < Rho::RhoController
  # 避難所マスタダウンロード
  def download
    Alert.show_popup "開発中"
    redirect Rho::RhoConfig.start_path  
  end
end
