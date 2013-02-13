require 'Master/master_controller'
require 'spec_helper'

describe "MasterController" do
  before(:all) do
    @application = AppApplication.new
    @controller = MasterController.new
  end

  describe "download" do
    before(:all) do
      @lgdpm_http_server_authentication = Rho::RhoConfig.lgdpm_http_server_authentication
      @lgdpm_master_download_url = Rho::RhoConfig.lgdpm_master_download_url
      Rho::RhoConfig.lgdpm_http_server_authentication = ""
      Rho::RhoConfig.lgdpm_master_download_url = "downloadURL"
    end

    it "ダウンロードファイルメソッドが呼び出されること" do
      args = {:url => "downloadURL",
      :filename => File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json'),
      :headers => {},
      :callback => "/app/Master/download_callback",
      :callback_param => ""}
      Rho::AsyncHttp.should_receive(:download_file).with(args)
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Master/download"), {})
    end
    
    after(:all) do
      Rho::RhoConfig.lgdpm_http_server_authentication = @lgdpm_http_server_authentication
      Rho::RhoConfig.lgdpm_master_download_url = @lgdpm_master_download_url
    end
  end
  
  describe "download_callback" do
    context "ダウンロード正常終了の場合" do
      it "APPLICマスタがロードされ、メニュー画面に遷移すること" do
        Master.should_receive(:load_master)
        Alert.should_receive(:show_popup).with("APPLICマスタのダウンロードが完了しました")
        WebView.should_receive(:navigate).with(Rho::RhoConfig.start_path)
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Master/download_callback", "status" => "ok", "rho_callback" => "1"), {})
      end
    end
    context "ダウンロードエラーの場合" do
      it "エラー画面に遷移すること" do
        WebView.should_receive(:navigate).with("/app/Master/show_error")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Master/download_callback", "status" => "ng", "rho_callback" => "1"), {})
      end
      it "ファイルが削除されていること" do
        File.exist?(File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')).should be_false
      end
    end
  end

  describe "show_error" do
    before(:all) do
      MasterController.class_variable_set(:@@error_params, {'error_code' => '2', 'http_error' => '404'})
    end
    it "エラー画面がレンダリングされること" do
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Master/show_error"), {})
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :error)
    end
  end
end
