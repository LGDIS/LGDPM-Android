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
    concat_date(@@search_condition, 'birthday', 'from')
    concat_date(@@search_condition, 'birthday', 'to')

    @all_num = Evacuee.count_by_condition(@@search_condition)
    @evacuees = Evacuee.find_by_condition(@@page, @@search_condition)
    render :action => :list, :back => url_for(:action => :search)
  end
  
  # 再検索実行
  # GET /Evacuee/do_search_again
  def do_search_again
    @all_num = Evacuee.count_by_condition(@@search_condition)
    per_page = Rho::RhoConfig.pf_per_page.to_i
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
    if Evacuee.count_by_condition() >= Rho::RhoConfig.pf_max_evacuees.to_i
      Alert.show_popup "最大登録件数に達しました。サーバ送信を行なってください。"
      redirect Rho::RhoConfig.start_path  
    end
    
    prefecture = Rho::RhoConfig.pf_default_prefecture
    city = Rho::RhoConfig.pf_default_city
    @@current_shelter ||= ""
    @evacuee = Evacuee.new({'prefecture' => prefecture, 'city' => city, 'shelter' => @@current_shelter})
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
    concat_date(evacuee, 'birthday')
    concat_date(evacuee, 'in_date')
    concat_date(evacuee, 'out_date')
    
    @evacuee = Evacuee.new(evacuee)
    @evacuee.save
    @@current_shelter = @evacuee.shelter
    redirect :action => :new
  end

  # 更新実行
  # POST /Evacuee/{1}/update
  def update
    @evacuee = Evacuee.find(@params['id'])
    evacuee = @params['evacuee']
    concat_date(evacuee, 'birthday')
    concat_date(evacuee, 'in_date')
    concat_date(evacuee, 'out_date')
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

  def login
    Alert.show_popup "開発中"
    redirect Rho::RhoConfig.start_path  
  end
end
