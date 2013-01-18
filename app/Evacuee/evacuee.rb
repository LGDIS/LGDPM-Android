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
  def self.count_by_condition(conditions={})
    Evacuee.find(:count, :conditions => create_advanced_query_conditions(conditions), :op => 'AND')
  end
  
  # 検索条件から、RhomのAdvanced Query形式の検索条件を生成します。
  # ==== Args
  # _conditions_ :: 検索条件
  # ==== Return
  # Advanced Query形式の検索条件
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
end
