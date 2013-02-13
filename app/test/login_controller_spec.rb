require 'Login/login_controller'
require 'spec_helper'

describe "LoginController" do
  before(:all) do
    @application = AppApplication.new
    @controller = LoginController.new
  end

  describe "login" do
    before(:all) do
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Login/login"), {})
    end
    it "ログイン画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :login)
    end
  end
  
  describe "do_login" do
    before(:all) do
      @lgdpm_http_server_authentication = Rho::RhoConfig.lgdpm_http_server_authentication
      @lgdpm_login_url = Rho::RhoConfig.lgdpm_login_url
      Rho::RhoConfig.lgdpm_http_server_authentication = ""
      Rho::RhoConfig.lgdpm_login_url = "loginURL"
    end
    it "ログイン、パスワードがPOSTされること" do
      args = {:url => "loginURL",
        :body => "user[login]=login&user[password]=password",
        :callback => "/app/Login/http_post_callback",
        :callback_param => ""}
      Rho::AsyncHttp.should_receive(:post).with(args)
      @controller.serve(@application, nil, SpecHelper.create_request("POST /Login/do_login", "login" => "login", "password" => "password"), {})
    end
    after(:all) do
      Rho::RhoConfig.lgdpm_http_server_authentication = @lgdpm_http_server_authentication
      Rho::RhoConfig.lgdpm_login_url = @lgdpm_login_url
    end
  end
  
  describe "http_post_callback" do
    context "認証ＯＫの場合" do
      it "アップロード画面に遷移すること" do
        WebView.should_receive(:navigate).with("/app/Evacuee/upload")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Login/http_post_callback", "status" => "ok", "http_error" => "201", "rho_callback" => "1", "cookies" => "cookie"), {})
        LoginController.get_cookie.should == "cookie"
      end
    end
    context "認証ＮＧの場合" do
      it "認証エラー表示JavaScriptを実行すること" do
        WebView.should_receive(:execute_js).with("authentication_error()")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Login/http_post_callback", "status" => "ng", "http_error" => "401", "rho_callback" => "1"), {})
      end
    end
    context "エラーの場合" do
      it "エラー画面に遷移すること" do
        WebView.should_receive(:navigate).with("/app/Login/show_error")
        @controller.serve(@application, nil, SpecHelper.create_request("GET /Login/http_post_callback", "status" => "ng", "http_error" => "500", "rho_callback" => "1"), {})
      end
    end
  end

  describe "show_error" do
    before(:all) do
      LoginController.class_variable_set(:@@error_params, {'error_code' => '2', 'http_error' => '404'})
      @controller.serve(@application, nil, SpecHelper.create_request("GET /Login/show_error"), {})
    end
    it "エラー画面がレンダリングされること" do
      @controller.instance_variable_get(:@content).should == @controller.render(:action => :error)
    end
  end
  
  describe "cookie" do
    before(:all) do
      LoginController.class_variable_set(:@@cookie, "cookie")
    end
    
    it "@@cookieが返されること" do
      LoginController.get_cookie.should == "cookie"
    end
  end
end
