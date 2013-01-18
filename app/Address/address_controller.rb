# encoding: utf-8
require 'rho/rhocontroller'
require 'helpers/browser_helper'

# 住所データコントローラ
class AddressController < Rho::RhoController
  include BrowserHelper

  # 市区町村のオプションタグを返す  
  # ==== Return
  # 市区町村オプションタグ
  def cities
    render :string => city_options(@params['state_cd']), :partial => true
  end

  # 町目字のオプションタグを返す  
  # ==== Return
  # 町目字オプションタグ
  def streets
    render :string => street_options(@params['state_cd'], @params['city_cd']), :partial => true
  end

  # 住所マスタダウンロード 
  def download
    Alert.show_popup "開発中"
    redirect Rho::RhoConfig.start_path  
  end
end
