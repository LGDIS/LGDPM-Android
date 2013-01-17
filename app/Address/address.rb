# 住所データモデル
class Address
  include Rhom::PropertyBag

  
  # 住所データを返します
  # ==== Return
  # 住所データ
  def self.all
    return @@address
  end
  
  # 指定された都道府県の市区町村データを返します
  # ==== Args
  # _pref_code_  :: 都道府県コード
  # ==== Return
  # 市区町村データ
  def self.find_cities(pref_cd)
    return @@address[pref_cd]
  end
  
  # 指定された都道府県、市区町村の町目字データを返します
  # ==== Args
  # _pref_code_  :: 都道府県コード
  # _city_code_  :: 市区町村コード
  # ==== Return
  # 町目字データ
  def self.find_towns(pref_cd, city_cd)
    return @@address[pref_cd][city_cd]
  end
  
  # JSONファイルから、住所データをロードします
  # ダウンロードした新しいJSONファイルがあれば、そちらをロードし、なければ、アプリに同梱したJSONファイルをロードします
  def self.load_address()
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
