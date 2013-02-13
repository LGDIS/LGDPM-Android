require 'Address/address_controller'
require 'spec_helper'

describe "AddressController" do
  before(:all) do
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
    File.open(file_name, "w") do |f|
      f.write('{"01":{"":"A","001":{"":"AA","0001":"AAA","0002":"AAB"},"002":{"":"AB","0001":"ABA","0002":"ABB"}}')
      f.write(',"02":{"":"B","001":{"":"BA","0001":"BAA","0002":"BAB"},"002":{"":"BB","0001":"BBA","0002":"BBB"}}}')
    end
    @application = AppApplication.new
    @controller = AddressController.new
  end

  describe "cities" do
    it "市区町村オプションタグを返すこと" do
      actual = @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/cities", "state_cd" => "01"), {})
      actual.should == '<option value="">－</option><option value="001" >AA</option><option value="002" >AB</option>'
    end
  end

  describe "streets" do
    it "町名オプションタグを返すこと" do
      actual = @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/streets", "state_cd" => "01", "city_cd" => "001"), {})
      actual.should == '<option value="">－</option><option value="0001" >AAA</option><option value="0002" >AAB</option>'
    end
  end

  describe "download" do
    before(:all) do
      @lgdpm_http_server_authentication = Rho::RhoConfig.lgdpm_http_server_authentication
      @lgdpm_address_download_url = Rho::RhoConfig.lgdpm_address_download_url
      Rho::RhoConfig.lgdpm_http_server_authentication = ""
      Rho::RhoConfig.lgdpm_address_download_url = "downloadURL"
    end

    it "ダウンロードファイルメソッドが呼び出されること" do
      args = {:url => "downloadURL",
      :filename => File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json'),
      :headers => {},
      :callback => "/app/Address/download_callback",
      :callback_param => ""}
      Rho::AsyncHttp.should_receive(:download_file).with(args)
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/download"), {})
    end
    
    after(:all) do
      Rho::RhoConfig.lgdpm_http_server_authentication = @lgdpm_http_server_authentication
      Rho::RhoConfig.lgdpm_address_download_url = @lgdpm_address_download_url
    end
  end
  
  describe "download_callback" do
    context "ダウンロード正常終了の場合" do
      it "住所マスタがロードされ、メニュー画面に遷移すること" do
        Address.should_receive(:load_address)
        Alert.should_receive(:show_popup).with("住所マスタのダウンロードが完了しました")
        WebView.should_receive(:navigate).with(Rho::RhoConfig.start_path)
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/download_callback", "status" => "ok", "rho_callback" => "1"), {})
      end
    end
    context "ダウンロードエラーの場合" do
      it "エラー画面に遷移すること" do
        WebView.should_receive(:navigate).with("/app/Address/show_error")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/download_callback", "status" => "ng", "rho_callback" => "1"), {})
      end
      it "ファイルが削除されていること" do
        File.exist?(File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')).should be_false
      end
    end
  end

  describe "show_error" do
    before(:all) do
      AddressController.class_variable_set(:@@error_params, {'error_code' => '2', 'http_error' => '404'})
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/show_error"), {})
    end
    it "エラー画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :error)
    end
  end
end
