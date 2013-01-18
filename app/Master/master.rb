# encoding: utf-8
# マスタデータモデル
class Master
  include Rhom::PropertyBag

  # 指定された種別のマスタデータを返します
  # ==== Args
  # _kind_  :: マスタ種別
  # ==== Return
  # マスタデータ
  def self.find_masters(kind)
    return @@master[kind]
  end
  
  # JSONファイルから、マスタデータをロードします
  # ダウンロードした新しいJSONファイルがあれば、そちらをロードし、なければ、アプリに同梱したJSONファイルをロードします
  def self.load_master()
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
    unless File.exist?(file_name)
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'master.json')
    end
    File.open(file_name) do |f|
      content = f.read()
      @@master = Rho::JSON.parse(content)
    end
  end
end
