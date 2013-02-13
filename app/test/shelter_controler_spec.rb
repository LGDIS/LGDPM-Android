require 'Shelter/shelter_controller'
require 'spec_helper'

describe "ShelterController" do
  before(:all) do
    @application = AppApplication.new
    @controller = ShelterController.new
  end

  describe "download" do
    before(:all) do
      @lgdpm_http_server_authentication = Rho::RhoConfig.lgdpm_http_server_authentication
      @lgdpm_shelter_download_url = Rho::RhoConfig.lgdpm_shelter_download_url
      Rho::RhoConfig.lgdpm_http_server_authentication = ""
      Rho::RhoConfig.lgdpm_shelter_download_url = "downloadURL"
    end

    it "ダウンロードファイルメソッドが呼び出されること" do
      args = {:url => "downloadURL",
      :filename => File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json'),
      :headers => {},
      :callback => "/app/Shelter/download_callback",
      :callback_param => ""}
      Rho::AsyncHttp.should_receive(:download_file).with(args)
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Shelter/download"), {})
    end
    
    after(:all) do
      Rho::RhoConfig.lgdpm_http_server_authentication = @lgdpm_http_server_authentication
      Rho::RhoConfig.lgdpm_shelter_download_url = @lgdpm_shelter_download_url
    end
  end
  
  describe "download_callback" do
    context "ダウンロード正常終了の場合" do
      it "避難所マスタがロードされ、メニュー画面に遷移すること" do
        Shelter.should_receive(:load_shelter)
        Alert.should_receive(:show_popup).with("避難所マスタのダウンロードが完了しました")
        WebView.should_receive(:navigate).with(Rho::RhoConfig.start_path)
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Shelter/download_callback", "status" => "ok", "rho_callback" => "1"), {})
      end
    end
    context "ダウンロードエラーの場合" do
      it "エラー画面に遷移すること" do
        WebView.should_receive(:navigate).with("/app/Shelter/show_error")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Shelter/download_callback", "status" => "ng", "rho_callback" => "1"), {})
      end
      it "ファイルが削除されていること" do
        File.exist?(File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')).should be_false
      end
    end
  end

  describe "show_error" do
    before(:all) do
      ShelterController.class_variable_set(:@@error_params, {'error_code' => '2', 'http_error' => '404'})
    end
    it "エラー画面がレンダリングされること" do
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Shelter/show_error"), {})
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :error)
    end
  end
end
