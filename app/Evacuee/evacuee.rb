# encoding: utf-8

# 避難者データモデル
class Evacuee
  include Rhom::PropertyBag

  # 指定された条件で、避難者を検索します。
  # ==== Args
  # _page_ :: ページ番号
  # _conditions_ :: 検索条件
  # ==== Return
  # 避難者データ
  # ==== Raise
  def self.find_by_condition(page, conditions={})
    Evacuee.paginate(:page => page, :per_page => Rho::RhoConfig.lgdpm_per_page.to_i, :conditions => create_advanced_query_conditions(conditions), 
      :op => 'AND', :select => ['family_name','given_name', 'date_of_birth', 'date_of_birth_year', 'date_of_birth_month', 'date_of_birth_day','shelter_name'],
      :order => ['alternate_family_name', 'alternate_given_name'])
  end

  # 指定された条件で、避難者の件数をカウントします。
  # ==== Args
  # _conditions_ :: 検索条件
  # ==== Retrun
  # 件数
  # ==== Raise
  def self.count_by_condition(conditions={})
    Evacuee.find(:count, :conditions => create_advanced_query_conditions(conditions), :op => 'AND')
  end

  # 検索条件から、RhomのAdvanced Query形式の検索条件を生成します。
  # ==== Args
  # _conditions_ :: 検索条件
  # ==== Return
  # Advanced Query形式の検索条件
  # ==== Raise
  def self.create_advanced_query_conditions(conditions={})
    advanced_query = {}
    if conditions
      conditions.each do |key, value|
        unless value.empty?
          if key == "alternate_family_name" or key == "alternate_given_name"
            advanced_query.store({:name => key, :op => 'LIKE'}, "%#{value}%")
          elsif key == "date_of_birth_from"
            advanced_query.store({:func => "CAST", :name => "date_of_birth as INTEGER", :op => '>='}, "#{value}")
          elsif key == "date_of_birth_to"
            advanced_query.store({:func => "CAST", :name => "date_of_birth as INTEGER", :op => '<='}, "#{value}")
          elsif !key.end_with?("_from") and !key.end_with?("_to")
            advanced_query.store({:name => key, :op => '='}, "#{value}")
          end
        end
      end
    end
    advanced_query
  end

  # 避難者データをURLエンコードして返します。
  # ==== Args
  # ==== Return
  # URLエンコードした結果文字列
  # ==== Raise
  def url_encode
    qstring = 'commit_kind=save'
    qstring << "&evacuee[family_name]=#{Rho::RhoSupport.url_encode(family_name)}"
    qstring << "&evacuee[given_name]=#{Rho::RhoSupport.url_encode(given_name)}"
    qstring << "&evacuee[alternate_family_name]=#{Rho::RhoSupport.url_encode(alternate_family_name)}"
    qstring << "&evacuee[alternate_given_name]=#{Rho::RhoSupport.url_encode(alternate_given_name)}"
    qstring << "&evacuee[date_of_birth]="
    unless date_of_birth.nil? or date_of_birth == ""
      qstring << "#{date_of_birth_year}-#{date_of_birth_month}-#{date_of_birth_day}"
    end
    qstring << "&evacuee[sex]=#{Rho::RhoSupport.url_encode(sex)}"
    qstring << "&evacuee[in_city_flag]=#{Rho::RhoSupport.url_encode(in_city_flag)}"
    qstring << "&evacuee[home_postal_code]=#{Rho::RhoSupport.url_encode(home_postal_code)}"
    qstring << "&evacuee[home_state]=#{Rho::RhoSupport.url_encode(home_state)}"
    qstring << "&evacuee[home_city]=#{Rho::RhoSupport.url_encode(Address.find_city_name(home_state, home_city))}"
    qstring << "&evacuee[home_street]=#{Rho::RhoSupport.url_encode(Address.find_street_name(home_state, home_city, home_street))}"
    qstring << "&evacuee[house_number]=#{Rho::RhoSupport.url_encode(house_number)}"
    qstring << "&evacuee[shelter_name]=#{Rho::RhoSupport.url_encode(shelter_name)}"
    qstring << "&evacuee[refuge_status]=#{Rho::RhoSupport.url_encode(refuge_status)}"
    qstring << "&evacuee[refuge_reason]=#{Rho::RhoSupport.url_encode(refuge_reason)}"
    qstring << "&evacuee[shelter_entry_date]="
    unless shelter_entry_date.nil? or shelter_entry_date == ""
      qstring << "#{shelter_entry_date_year}-#{shelter_entry_date_month}-#{shelter_entry_date_day}"
    end
    qstring << "&evacuee[shelter_leave_date]="
    unless shelter_leave_date.nil? or shelter_leave_date == ""
      qstring << "#{shelter_leave_date_year}-#{shelter_leave_date_month}-#{shelter_leave_date_day}"
    end
    qstring << "&evacuee[next_place]=#{Rho::RhoSupport.url_encode(next_place)}"
    qstring << "&evacuee[next_place_phone]=#{Rho::RhoSupport.url_encode(next_place_phone)}"
    qstring << "&evacuee[injury_flag]=#{Rho::RhoSupport.url_encode(injury_flag)}"
    qstring << "&evacuee[injury_condition]=#{Rho::RhoSupport.url_encode(injury_condition)}"
    qstring << "&evacuee[allergy_flag]=#{Rho::RhoSupport.url_encode(allergy_flag)}"
    qstring << "&evacuee[allergy_cause]=#{Rho::RhoSupport.url_encode(allergy_cause)}"
    qstring << "&evacuee[pregnancy]=#{Rho::RhoSupport.url_encode(pregnancy)}"
    qstring << "&evacuee[baby]=#{Rho::RhoSupport.url_encode(baby)}"
    qstring << "&evacuee[upper_care_level_three]=#{Rho::RhoSupport.url_encode(upper_care_level_three)}"
    qstring << "&evacuee[elderly_alone]=#{Rho::RhoSupport.url_encode(elderly_alone)}"
    qstring << "&evacuee[elderly_couple]=#{Rho::RhoSupport.url_encode(elderly_couple)}"
    qstring << "&evacuee[bedridden_elderly]=#{Rho::RhoSupport.url_encode(bedridden_elderly)}"
    qstring << "&evacuee[elderly_dementia]=#{Rho::RhoSupport.url_encode(elderly_dementia)}"
    qstring << "&evacuee[rehabilitation_certificate]=#{Rho::RhoSupport.url_encode(rehabilitation_certificate)}"
    qstring << "&evacuee[physical_disability_certificate]=#{Rho::RhoSupport.url_encode(physical_disability_certificate)}"
    qstring << "&evacuee[family_well]=#{family_well}"
    qstring << "&evacuee[public_flag]=#{Rho::RhoSupport.url_encode(public_flag)}"
    qstring << "&evacuee[note]=#{Rho::RhoSupport.url_encode(note)}"
  end
end
