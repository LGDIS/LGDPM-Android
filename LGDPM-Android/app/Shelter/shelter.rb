# 避難所データモデル
class Shelter
  include Rhom::PropertyBag

  # 避難所を返します
  # ==== Return
  # 避難所データ
  def self.find_shelters()
    @@shelter
  end

  # 避難所名を返します
  # ==== Args
  # _shelter_code_  :: 避難所コード
  # ==== Return
  # 避難所名
  def self.find_name(shelter_cd)
    @@shelter[shelter_cd]
  end  
  
  # JSONファイルから、避難所データをロードします
  # ダウンロードした新しいJSONファイルがあれば、そちらをロードし、なければ、アプリに同梱したJSONファイルをロードします
  def self.load_shelter()
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
    unless File.exist?(file_name)
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'shelter.json')
    end
    File.open(file_name) do |f|
      content = f.read()
      @@shelter = Rho::JSON.parse(content)
    end
  end
end
