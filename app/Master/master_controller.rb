require 'rho/rhocontroller'
require 'helpers/browser_helper'

# マスタデータコントローラ
class MasterController < Rho::RhoController
  include BrowserHelper

  # マスタデータダウンロード 
  def download
    Alert.show_popup "開発中"
    redirect Rho::RhoConfig.start_path  
  end
end
