# encoding: utf-8

# 住所データモデル
class Address
  include Rhom::PropertyBag

  # 全住所データを返します
  # ==== Args
  # ==== Return
  # 全住所データ
  # ==== Raise
  def self.all
    return @@address
  end

  # 指定された都道府県の市区町村データを返します
  # ==== Args
  # _state_code_  :: 都道府県コード
  # ==== Return
  # 市区町村データ
  # ==== Raise
  def self.find_cities(state_cd)
    if state_cd.nil? or state_cd.empty?
      return {}
    end
    return @@address[state_cd]
  end

  # 指定された都道府県、市区町村の町目字データを返します
  # ==== Args
  # _state_code_  :: 都道府県コード
  # _city_code_  :: 市区町村コード
  # ==== Return
  # 町目字データ
  # ==== Raise
  def self.find_streets(state_cd, city_cd)
    if state_cd.nil? or state_cd.empty? or city_cd.nil? or city_cd.empty?
      return {}
    end
    return @@address[state_cd][city_cd]
  end

  # 市区町村名を返します
  # ==== Args
  # _state_code_  :: 都道府県コード
  # _city_code_  :: 市区町村コード
  # ==== Return
  # 市区町村名
  # ==== Raise
  def self.find_city_name(state_cd, city_cd)
    if state_cd.nil? or state_cd.empty? or city_cd.nil? or city_cd.empty?
      return ""
    end
    return @@address[state_cd][city_cd][""]
  end

  # 町名を返します
  # ==== Args
  # _state_code_  :: 都道府県コード
  # _city_code_  :: 市区町村コード
  # _street_cd_  :: 町名コード
  # ==== Return
  # 町名
  # ==== Raise
  def self.find_street_name(state_cd, city_cd, street_cd)
    if state_cd.nil? or state_cd.empty? or city_cd.nil? or city_cd.empty? or street_cd.nil? or street_cd.empty?
      return ""
    end
    return @@address[state_cd][city_cd][street_cd]
  end

  # JSONファイルから、住所データをロードします
  # ダウンロードした新しいJSONファイルがあれば、そちらをロードし、なければ、アプリに同梱したJSONファイルをロードします
  # ==== Args
  # ==== Return
  # ==== Raise
  def self.load_address
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
    unless File.exist?(file_name)
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'address.json')
    end
    File.open(file_name) do |f|
      content = f.read()
      @@address = Rho::JSON.parse(content)
    end
  end
end
