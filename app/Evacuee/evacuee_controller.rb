# encoding: utf-8
require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

# 避難者コントローラ
class EvacueeController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper

  # 検索画面表示
  # GET /Evacuee/search
  # ==== Args
  # ==== Return
  # ==== Raise
  def search
    render :action => :search, :back => Rho::RhoConfig.start_path
  end

  # 検索実行
  # POST /Evacuee/do_search
  # ==== Args
  # ==== Return
  # ==== Raise
  def do_search
    @@page = 0
    @@search_condition = @params['evacuee']
    concat_date(@@search_condition, 'date_of_birth', 'from')
    concat_date(@@search_condition, 'date_of_birth', 'to')

    @all_num = Evacuee.count_by_condition(@@search_condition)
    @evacuees = Evacuee.find_by_condition(@@page, @@search_condition)
    render :action => :list, :back => url_for(:action => :search)
  end

  # 再検索実行
  # GET /Evacuee/do_search_again
  # ==== Args
  # ==== Return
  # ==== Raise
  def do_search_again
    @all_num = Evacuee.count_by_condition(@@search_condition)
    per_page = Rho::RhoConfig.lgdpm_per_page.to_i
    if @all_num == 0
      @@page = 0
    else
      if @all_num <= @@page * per_page
        @@page = @all_num / per_page -1
        @@page += 1 unless @all_num % per_page == 0
      end
    end
    
    @evacuees = Evacuee.find_by_condition(@@page, @@search_condition)
    render :action => :list, :back => url_for(:action => :search)
  end
  
  # ページ切り替え
  # GET /Evacuee/paginate
  # ==== Args
  # ==== Return
  # ==== Raise
  def paginate
    @@page = @params['page'] ? @params['page'].to_i : 0
    do_search_again
  end

  # 現在のページを返します
  # ==== Args
  # ==== Return
  # 現在のページ
  # ==== Raise
  def get_current_page
    @@page
  end

  # 登録画面表示
  # GET /Evacuee/new
  # ==== Args
  # ==== Return
  # ==== Raise
  def new
    if Evacuee.count_by_condition() >= Rho::RhoConfig.lgdpm_max_evacuees.to_i
      Alert.show_popup "登録が完了しました。登録件数が最大件数に達しました。"
      redirect Rho::RhoConfig.start_path
    end
    
    @evacuee = Evacuee.new(default_values())
    render :action => :new, :back => Rho::RhoConfig.start_path
  end

  # 更新画面表示
  # GET /Evacuee/{1}/edit
  # ==== Args
  # ==== Return
  # ==== Raise
  def edit
    @evacuee = Evacuee.find(@params['id'])
    if @evacuee
      render :action => :edit, :back => url_for(:action => :do_search_again)
    else
      redirect :action => :do_search_again
    end
  end

  # 登録実行
  # POST /Evacuee/create
  # ==== Args
  # ==== Return
  # ==== Raise
  def create
    evacuee = @params['evacuee']
    concat_date(evacuee, 'date_of_birth')
    concat_date(evacuee, 'shelter_entry_date')
    concat_date(evacuee, 'shelter_leave_date')
    set_in_city_flag(evacuee)
    @evacuee = Evacuee.new(evacuee)
    @evacuee.save
    @@current_shelter = @evacuee.shelter_name
    redirect :action => :new
  end

  # 更新実行
  # POST /Evacuee/{1}/update
  # ==== Args
  # ==== Return
  # ==== Raise
  def update
    @evacuee = Evacuee.find(@params['id'])
    evacuee = @params['evacuee']
    concat_date(evacuee, 'date_of_birth')
    concat_date(evacuee, 'shelter_entry_date')
    concat_date(evacuee, 'shelter_leave_date')
    set_in_city_flag(evacuee)
    if @evacuee
      @evacuee.update_attributes(evacuee)
      Alert.show_popup "登録が完了しました。"
    end
    redirect :action => :do_search_again
  end

  # 削除実行
  # POST /Evacuee/{1}/delete
  # ==== Args
  # ==== Return
  # ==== Raise
  def delete
    @evacuee = Evacuee.find(@params['id'])
    if @evacuee
      @evacuee.destroy 
      Alert.show_popup "削除が完了しました。"
    end
    redirect :action => :do_search_again
  end

  # 避難者データをアップロードします
  # POST /Evacuee/upload
  # ==== Args
  # ==== Return
  # ==== Raise
  def upload
    @@evacuees = Evacuee.find(:all)
    @@cnt = 0
    @@canceled = false
    if @@evacuees.empty?
      Alert.show_popup "避難者データが登録されていません"
      redirect Rho::RhoConfig.start_path  
    else
      http_post(@@evacuees[@@cnt])
      wait
    end
  end

  # 通信中画面表示
  # ==== Args
  # ==== Return
  # ==== Raise
  def wait
    @msg = "避難者をサーバに登録しています。（#{@@cnt + 1}／#{@@evacuees.size}）"
    render :action => :wait
  end

  # 避難者データPOSTコールバック
  # ==== Args
  # ==== Return
  # ==== Raise
  def http_post_callback
    if @params['status'] != 'ok'
      @@error_params = @params
      WebView.navigate(url_for(:action => :show_error))
    else
      # アップロードしたデータをローカルDBから削除
      @@evacuees[@@cnt].destroy

      if @@canceled
        # キャンセル
        Alert.show_popup "キャンセルしました。"
        WebView.navigate(Rho::RhoConfig.start_path)
      else
        # 次のデータをアップロード
        @@cnt += 1
        if @@cnt < @@evacuees.size
          http_post(@@evacuees[@@cnt])
          WebView.navigate(url_for(:action => :wait))
        else
          Alert.show_popup "登録が完了しました。"
          WebView.navigate(Rho::RhoConfig.start_path)
        end
      end
    end
  end

  # エラー表示
  # ==== Args
  # ==== Return
  # ==== Raise
  def show_error
    @error_message = Rho::RhoError.new(@@error_params['error_code'].to_i).message
    if @@error_params['http_error']
      @error_detail = "HTTPステータスコード：#{@@error_params['http_error']}<br>#{@@error_params['body']}"
    else
      @error_detail = @@error_params['body']
    end
    render :action => :error
  end

  # キャンセル
  # POST /Evacuee/cancel_upload
  # ==== Args
  # ==== Return
  # ==== Raise
  def cancel_upload
    @@canceled = true
  end
  
  private
  
  # 登録画面デフォルト値を返します
  # ==== Args
  # ==== Return
  # デフォルト値
  # ==== Raise
  def default_values
    values = {}
    values['home_state'] = Rho::RhoConfig.lgdpm_default_state
    values['home_city'] = Rho::RhoConfig.lgdpm_default_city
    values['home_street'] = Rho::RhoConfig.lgdpm_default_street
    values['sex'] = Rho::RhoConfig.lgdpm_default_sex
    values['refuge_status'] = Rho::RhoConfig.lgdpm_default_refuge_status
    values['injury_flag'] = Rho::RhoConfig.lgdpm_default_injury_flag
    values['allergy_flag'] = Rho::RhoConfig.lgdpm_default_allergy_flag
    values['pregnancy'] = Rho::RhoConfig.lgdpm_default_pregnancy
    values['baby'] = Rho::RhoConfig.lgdpm_default_baby
    values['upper_care_level_three'] = Rho::RhoConfig.lgdpm_default_upper_care_level_three
    values['elderly_alone'] = Rho::RhoConfig.lgdpm_default_elderly_alone
    values['elderly_couple'] = Rho::RhoConfig.lgdpm_default_elderly_couple
    values['bedridden_elderly'] = Rho::RhoConfig.lgdpm_default_bedridden_elderly
    values['elderly_dementia'] = Rho::RhoConfig.lgdpm_default_elderly_dementia
    values['rehabilitation_certificate'] = Rho::RhoConfig.lgdpm_default_rehabilitation_certificate
    values['physical_disability_certificate'] = Rho::RhoConfig.lgdpm_default_physical_disability_certificate
    @@current_shelter ||= Rho::RhoConfig.lgdpm_default_shelter_name
    values['shelter_name'] = @@current_shelter
      
    values
  end

  # 日付連結処理
  # 指定されたパラメータ（Hash）に格納された、年、月、日のデータを連結し、年月日のデータとしてパラメータに格納します。
  # 年、月、日のキーは、それぞれ、(name)_year[_(suffix)]、 (name)_month[_(suffix)]、(name)_day[_(suffix)]とします。
  # 格納する年月日のキーは、(name)[_(suffix)]とします。
  # ==== Args
  # _params_ :: パラメータ
  # _name_ :: パラメータに格納されている年、月、日の名前 
  # _suffix_ :: 接尾語
  # ==== Return
  # ==== Raise
  def concat_date(params, name, suffix = "")
    unless suffix.empty? or suffix.start_with?("_") 
      suffix = "_" + suffix
    end
    if blank?(params["#{name}_year#{suffix}"]) or blank?(params["#{name}_month#{suffix}"]) or blank?(params["#{name}_day#{suffix}"])
      params["#{name}#{suffix}"] = ""
    else
      params["#{name}#{suffix}"] = params["#{name}_year#{suffix}"] + params["#{name}_month#{suffix}"] + params["#{name}_day#{suffix}"]
    end
  end

  # 市内／市外区分設定処理
  # 指定されたパラメータ（Hash）に格納された、都道府県、市区町村のデータから、市内／市外区分を判定し、パラメータに格納します。
  # ==== Args
  # _params_ :: パラメータ
  # ==== Return
  # ==== Raise
  def set_in_city_flag(params)
    unless blank?(params["home_city"])
      if params["home_state"] == Rho::RhoConfig.lgdpm_in_city_state and params["home_city"] == Rho::RhoConfig.lgdpm_in_city_city
        params["in_city_flag"] = Rho::RhoConfig.lgdpm_in_city_flag_in
      else
        params["in_city_flag"] = Rho::RhoConfig.lgdpm_in_city_flag_out
      end
    end
  end

  # HTTP Post処理
  # HTTP Postにより、指定された避難者データをサーバに登録します。
  # ==== Args
  # _data_ :: 避難者データ
  # ==== Return
  # ==== Raise
  def http_post(data)
    params = {:url => Rho::RhoConfig.lgdpm_upload_url,
             :body => data.url_encode,
             :callback => (url_for :action => :http_post_callback),
             :headers => {:cookie => LoginController.get_cookie},
             :callback_param => ""}
    unless blank?(Rho::RhoConfig.lgdpm_http_server_authentication)
      params[:authorization] = {:type => Rho::RhoConfig.lgdpm_http_server_authentication.intern,
                               :username => Rho::RhoConfig.lgdpm_http_server_authentication_username,
                               :password => Rho::RhoConfig.lgdpm_http_server_authentication_password }
    end
    Rho::AsyncHttp.post(params)
  end
end
