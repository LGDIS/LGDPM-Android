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
  def search
    render :action => :search, :back => Rho::RhoConfig.start_path
  end
  
  # 検索実行
  # POST /Evacuee/do_search
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
  def do_search_again
    @all_num = Evacuee.count_by_condition(@@search_condition)
    per_page = Rho::RhoConfig.lgdpm_per_page.to_i
    if @all_num < @@page * per_page
      @@page = @all_num / per_page
      @@page += 1 unless @all_num % per_page == 0
    end
    
    @evacuees = Evacuee.find_by_condition(@@page, @@search_condition)
    render :action => :list, :back => url_for(:action => :search)
  end
  
  # ページ切り替え
  # GET /Evacuee/paginate
  def paginate
    @@page = @params['page'] ? @params['page'].to_i : 0
    do_search_again
  end

  # 現在のページを返します
  # ==== Return
  # 現在のページ
  def get_current_page
    @@page
  end

  # 登録画面表示
  # GET /Evacuee/new
  def new
    if Evacuee.count_by_condition() >= Rho::RhoConfig.lgdpm_max_evacuees.to_i
      Alert.show_popup "最大登録件数に達しました。サーバ送信を行なってください。"
      redirect Rho::RhoConfig.start_path  
    end
    
    @evacuee = Evacuee.new(default_values())
    render :action => :new, :back => Rho::RhoConfig.start_path
  end

  # 更新画面表示
  # GET /Evacuee/{1}/edit
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
  def create
    evacuee = @params['evacuee']
    concat_date(evacuee, 'date_of_birth')
    concat_date(evacuee, 'shelter_entry_date')
    concat_date(evacuee, 'shelter_leave_date')
    
    @evacuee = Evacuee.new(evacuee)
    @evacuee.save
    @@current_shelter = @evacuee.shelter_name
    redirect :action => :new
  end

  # 更新実行
  # POST /Evacuee/{1}/update
  def update
    @evacuee = Evacuee.find(@params['id'])
    evacuee = @params['evacuee']
    concat_date(evacuee, 'date_of_birth')
    concat_date(evacuee, 'shelter_entry_date')
    concat_date(evacuee, 'shelter_leave_date')
    @evacuee.update_attributes(evacuee) if @evacuee
    redirect :action => :do_search_again
  end

  # 削除実行
  # POST /Evacuee/{1}/delete
  def delete
    @evacuee = Evacuee.find(@params['id'])
    @evacuee.destroy if @evacuee
    redirect :action => :do_search_again  
  end

  
  # 避難者データをアップロードします
  # POST /Evacuee/upload
  def upload
    @@evacuees = Evacuee.find(:all)
    @@cnt = 0
    if @@evacuees.empty?
      Alert.show_popup "避難者データが登録されていません"
      redirect Rho::RhoConfig.start_path  
    else
      @msg = "開発中です"
      render :action => :wait
    end
  end
  
  private
  # 登録画面デフォルト値を返します
  # ==== Return
  # デフォルト値
  def default_values
    values = {}
    values['home_state'] = Rho::RhoConfig.lgdpm_default_state
    values['home_city'] = Rho::RhoConfig.lgdpm_default_city
    values['sex'] = Rho::RhoConfig.lgdpm_default_sex
    values['in_city_flag'] = Rho::RhoConfig.lgdpm_default_in_city_flag
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
    @@current_shelter ||= ""
    values['shelter_name'] = @@current_shelter
      
    values
  end
end
