require 'Evacuee/evacuee_controller'
require 'Login/login_controller'
require 'spec_helper'

describe "EvacueeController" do
  before(:all) do
    Rhom::Rhom.database_full_reset
    Rho::RhoUtils.load_offline_data(['object_values'], 'test')
    @lgdpm_per_page = Rho::RhoConfig.lgdpm_per_page
    Rho::RhoConfig.lgdpm_per_page = "2"
    @application = AppApplication.new
    @controller = EvacueeController.new
  end

  describe "search" do
    before(:all) do
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/search"), {})
    end
    it "検索画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :search)
    end
  end

  describe "do_search" do
    before(:all) do
      @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/do_search",
      "evacuee" => {"alternate_family_name" => ""}), {})
    end
    
    it "検索結果画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :list)
    end
    
    it "1ページ目を表示すること" do
      @controller.get_current_page.should == 0
    end
  end

  describe "do_search_again" do
    before(:all) do
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/do_search_again"), {})
    end
    
    it "検索結果画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :list)
    end
  end

  describe "paginate" do
    context "指定ページが存在する場合" do
      before(:all) do
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/paginate", "page" => "1"), {})
      end
      it "検索結果画面がレンダリングされること" do
        @controller.instance_variable_get(:@content).should == @controller.render(:action => :list)
      end
      it "指定ページを表示すること" do
        @controller.get_current_page.should == 1
      end
    end
    context "指定ページが存在しない場合" do
      before(:all) do
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/paginate", "page" => "4"), {})
      end
      it "検索結果画面がレンダリングされること" do
        @controller.instance_variable_get(:@content).should == @controller.render(:action => :list)
      end
      it "最終ページを表示すること" do
        @controller.get_current_page.should == 2
      end
    end
  end
  
  describe "new" do
    context "DB登録件数が最大件数未満の場合" do
      before(:all) do
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/new"), {})
      end
      it "登録画面がレンダリングされること" do
        @controller.instance_variable_get(:@content).should == @controller.render(:action => :new)
      end
    end
    context "DB登録件数が最大件数に達している場合" do
      before(:all) do
        @lgdpm_max_evacuees = Rho::RhoConfig.lgdpm_max_evacuees
        Rho::RhoConfig.lgdpm_max_evacuees = 5
      end
      it "メニュー画面にリダイレクトすること" do
        Alert.should_receive(:show_popup).with("最大登録件数に達しています。サーバ送信を行ってください。")
        response = {"headers" => {}}
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/new"), response)
        response["headers"]["Location"].should == Rho::RhoConfig.start_path
      end
      
      after(:all) do
        Rho::RhoConfig.lgdpm_max_evacuees = @lgdpm_max_evacuees
      end
    end
  end
  
  describe "edit" do
    context "データが存在する場合" do
      before(:all) do
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/edit", "id" => "1"), {})
      end
      it "更新画面がレンダリングされること" do
        @controller.instance_variable_get(:@content).should == @controller.render(:action => :edit)
      end
    end
    context "データが存在しない場合" do
      it "再検索にリダイレクトされること" do
        response = {"headers" => {}}
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/edit", "id" => "99999"), response)
        response["headers"]["Location"].should == "/app/Evacuee/do_search_again"
      end
    end
  end

  describe "create" do
    before do
      @evacuee = Evacuee.new
      Evacuee.should_receive(:new).and_return(@evacuee)
    end
    it "登録画面にリダイレクトされること" do
      Alert.should_receive(:show_popup).with("登録が完了しました。")
      @evacuee.should_receive(:save)
      response = {"headers" => {}}
      @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/create", 
      "evacuee" => {"family_name" => "名前"}), response)
      response["headers"]["Location"].should == "/app/Evacuee/new"
    end
  end
  
  describe "update" do
    before do
      @evacuee = Evacuee.new
      Evacuee.should_receive(:find).and_return(@evacuee)
    end
    it "再検索にリダイレクトされること" do
      Alert.should_receive(:show_popup).with("登録が完了しました。")
      @evacuee.should_receive(:update_attributes)
      response = {"headers" => {}}
      @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/update", "id" => "1",
      "evacuee" => {"family_name" => "名前"}), response)
      response["headers"]["Location"].should == "/app/Evacuee/do_search_again"
    end
  end
    
  describe "delete" do
    before do
      @evacuee = Evacuee.new
      Evacuee.should_receive(:find).and_return(@evacuee)
    end
    it "再検索にリダイレクトされること" do
      Alert.should_receive(:show_popup).with("削除が完了しました。")
      @evacuee.should_receive(:destroy)
      response = {"headers" => {}}
      @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/delete", "id" => "1"), response)
      response["headers"]["Location"].should == "/app/Evacuee/do_search_again"
    end
  end
  
  describe "upload" do
    context "データが存在しない場合" do
      before do
        Evacuee.should_receive(:find).with(:all).and_return([])
      end
      it "メニュー画面にリダイレクトすること" do
        Alert.should_receive(:show_popup).with("避難者データが登録されていません")
        response = {"headers" => {}}
        @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/upload"), response)
        response["headers"]["Location"].should == Rho::RhoConfig.start_path
      end
    end
    context "データが存在する場合" do
      before(:all) do
        @lgdpm_http_server_authentication = Rho::RhoConfig.lgdpm_http_server_authentication
        @lgdpm_upload_url = Rho::RhoConfig.lgdpm_upload_url
        Rho::RhoConfig.lgdpm_http_server_authentication = ""
        Rho::RhoConfig.lgdpm_upload_url = "uploadURL"
        @evacuee = Evacuee.new
        Evacuee.should_receive(:find).and_return([@evacuee])
        @evacuee.should_receive(:url_encode).and_return("url_encode_data")
        LoginController.should_receive(:get_cookie).and_return("cookie")
      end
      it "避難者がPOSTされること" do
         args = {:url => "uploadURL",
          :body => "url_encode_data",
          :callback => "/app/Evacuee/http_post_callback",
          :headers => {:cookie => "cookie"},
          :callback_param => ""}
        Rho::AsyncHttp.should_receive(:post).with(args)
        @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/upload"), {})
        @controller.instance_variable_get(:@content).should == @controller.render(:action => :wait)
      end
      after(:all) do
        Rho::RhoConfig.lgdpm_http_server_authentication = @lgdpm_http_server_authentication
        Rho::RhoConfig.lgdpm_upload_url = @lgdpm_upload_url
      end
    end
  end

  describe "http_post_callback" do
    before(:all) do 
      @lgdpm_http_server_authentication = Rho::RhoConfig.lgdpm_http_server_authentication
      @lgdpm_upload_url = Rho::RhoConfig.lgdpm_upload_url
      Rho::RhoConfig.lgdpm_http_server_authentication = ""
      Rho::RhoConfig.lgdpm_upload_url = "uploadURL"
    end
    context "正常の場合" do
      context "残りが無い場合" do
        before(:all) do
          @evacuee = Evacuee.new
          @evacuee.should_receive(:destroy)
          EvacueeController.class_variable_set(:@@evacuees, [@evacuee])
          EvacueeController.class_variable_set(:@@cnt, 0)
        end
        it "メニュー画面に遷移すること" do
          Alert.should_receive(:show_popup).with("登録が完了しました。")
          WebView.should_receive(:navigate).with(Rho::RhoConfig.start_path)
          @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/http_post_callback", "status" => "ok", "rho_callback" => "1"), {})
        end
      end
      context "残りがある場合" do
        before(:all) do
          @evacuee = Evacuee.new
          @evacuee.should_receive(:destroy)
          EvacueeController.class_variable_set(:@@evacuees, [@evacuee, @evacuee])
          EvacueeController.class_variable_set(:@@cnt, 0)
          @evacuee.should_receive(:url_encode).and_return("url_encode_data")
          LoginController.should_receive(:get_cookie).and_return("cookie")
        end
        it "避難者がPOSTされること" do
          args = {:url => "uploadURL",
            :body => "url_encode_data",
            :callback => "/app/Evacuee/http_post_callback",
            :headers => {:cookie => "cookie"},
            :callback_param => ""}
          Rho::AsyncHttp.should_receive(:post).with(args)
          WebView.should_receive(:navigate).with("/app/Evacuee/wait")
          @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/http_post_callback", "status" => "ok", "rho_callback" => "1"), {})
        end
      end
      context "キャンセルの場合" do
        before(:all) do
          @evacuee = Evacuee.new
          @evacuee.should_receive(:destroy)
          EvacueeController.class_variable_set(:@@canceled, true)
          EvacueeController.class_variable_set(:@@evacuees, [@evacuee, @evacuee])
          EvacueeController.class_variable_set(:@@cnt, 0)
        end
        it "メニュー画面に遷移すること" do
          Alert.should_receive(:show_popup).with("キャンセルしました。")
          WebView.should_receive(:navigate).with(Rho::RhoConfig.start_path)
          @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/http_post_callback", "status" => "ok", "rho_callback" => "1"), {})
        end
      end
      after(:all) do
        Rho::RhoConfig.lgdpm_http_server_authentication = @lgdpm_http_server_authentication
        Rho::RhoConfig.lgdpm_upload_url = @lgdpm_upload_url
      end
    end
    context "エラーの場合" do
      it "エラー画面に遷移すること" do
        WebView.should_receive(:navigate).with("/app/Evacuee/show_error")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/http_post_callback", "status" => "ng", "rho_callback" => "1"), {})
      end
    end
  end

  describe "show_error" do
    before(:all) do
      AddressController.class_variable_set(:@@error_params, {'error_code' => '2', 'http_error' => '500'})
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Evacuee/show_error"), {})
    end
    it "エラー画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :error)
    end
  end
  
  describe "cancel_upload" do
    before(:all) do
      @controller.serve(@application, nil, SpecHelper.create_request("POST /Evacuee/cancel_upload"), {})
    end
    it "キャンセルフラグが設定されること" do
      EvacueeController.class_variable_get(:@@canceled).should be_true
    end
    
  end
  
end
