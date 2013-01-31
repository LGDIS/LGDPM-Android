require 'rho/rhoapplication'
require 'json'

# アプリケーションクラス
class AppApplication < Rho::RhoApplication
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    @@toolbar = nil
    super
    @default_menu = { 
      "メニュー" => :home,
      "終了" => :close,
    } 

    # 住所データのロード     
    Address.load_address()
    
    # 避難所データのロード
    Shelter.load_shelter()
    
    # マスタデータのロード
    Master.load_master()
     
    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")
    # SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')
  end
end
