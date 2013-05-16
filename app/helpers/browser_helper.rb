module BrowserHelper

  def placeholder(label=nil)
    "placeholder='#{label}'" if platform == 'apple'
  end

  def platform
    System::get_property('platform').downcase
  end

  def selected(option_value,object_value)
    option_value.to_s == object_value.to_s ? %(selected="yes") : ""
  end

  def checked(option_value,object_value)
    option_value.to_s == object_value.to_s ? %(checked="yes") : ""
  end

  def is_bb6
    platform == 'blackberry' && (System::get_property('os_version').split('.')[0].to_i >= 6)
  end
  
  def to_jcalendar(year)
    if year < 1912
      gg = '明治'
      yy = year - 1867
    elsif year == 1912
      gg = '大正'
      yy = '元'
    elsif year >= 1912 && year <= 1926
      gg = '大正'
      yy = year - 1911
    elsif year > 1926 && year < 1989
      gg = '昭和'
      yy = year - 1925
    elsif year == 1989
      gg = '平成'
      yy = '元'
    elsif year > 1989
      gg = '平成'
      yy = year - 1988
    end
    
    return gg + yy.to_s + '年'
  end
  
  # 年選択セレクトボックスタグのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 年選択セレクトボックスタグのHTML
  # ==== Raise
  def select_year_tag(options={})
    tag = %(<select style="width:150px" data-mini="true")
    tag << %( name="#{options[:name]}") if options[:name]
    tag << %( id="#{options[:id]}") if options[:id]
    tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
    tag << ">"
    tag << %(<option value="">－</option>)
    year = Time.now.year
    Rho::RhoConfig.lgdpm_max_year.to_i.times do |x|
      tag << %(<option value="#{year - x}" )
      tag << selected(year - x, options[:value])
      tag << %(>#{year - x }</option>)
    end
    tag << %(</select>)
  end
  
  # 年選択セレクトボックスタグのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 年選択セレクトボックスタグのHTML
  # ==== Raise
  def select_birthyear_tag(options={})
    tag = %(<select data-mini="true")
    tag << %( name="#{options[:name]}") if options[:name]
    tag << %( id="#{options[:id]}") if options[:id]
    tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
    tag << ">"
    tag << %(<option value="">－</option>)
    year = Time.now.year
    Rho::RhoConfig.lgdpm_max_year.to_i.times do |x|
      tag << %(<option value="#{year - x}" )
      tag << selected(year - x, options[:value])
      #tag << %(>#{year - x }</option>)
      tag << %(>#{(year - x).to_s + "(" + to_jcalendar(year - x) + ")" }</option>)
    end
    tag << %(</select>)
  end

  # 月選択セレクトボックスタグのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 月選択セレクトボックスタグのHTML
  # ==== Raise
  def select_month_tag(options={})
    tag = %(<select data-mini="true")
    tag << %( name="#{options[:name]}") if options[:name]
    tag << %( id="#{options[:id]}") if options[:id]
    tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
    tag << ">"
    tag << %(<option value="">－</option>)
    (1..12).each do |month|
      tag << %(<option value="#{'%02d' % month}" )
      tag << selected("#{'%02d' % month}", options[:value])
      tag << %(>#{month}</option>)
    end
    tag << %(</select>)
  end

  # 日選択セレクトボックスタグのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 日選択セレクトボックスタグのHTML
  # ==== Raise
  def select_day_tag(options={})
    tag = %(<select data-mini="true")
    tag << %( name="#{options[:name]}") if options[:name]
    tag << %( id="#{options[:id]}") if options[:id]
    tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
    tag << ">"
    tag << %(<option value="">－</option>)
    (1..31).each do |day|
      tag << %(<option value="#{'%02d' % day}" )
      tag << selected("#{'%02d' % day}", options[:value])
      tag << %(>#{day}</option>)
    end
    tag << %(</select>)
  end
  
  # 避難所選択セレクトボックスタグのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 避難所選択セレクトボックスタグのHTML
  # ==== Raise
  def select_shelter_tag(options={})
    shelters = Shelter.all()
    tag = %(<select)
    tag << %( name="#{options[:name]}") if options[:name]
    tag << %( id="#{options[:id]}") if options[:id]
    tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
    tag << ">"
    tag << %(<option value="">－</option>)
    shelters.each do |shelter_cd, name|
      tag << %(<option value="#{shelter_cd}" )
      tag << selected(shelter_cd, options[:value])
      tag << %(>#{name}</option>)
    end
    tag << %(</select>)
  end
  
  # 指定されたマスタのオプションタグのHTMLを返します
  # ==== Args
  # _kind_ :: マスタ種別
  # _options_ :: オプション
  # ==== Return
  # オプションタグのHTML
  # ==== Raise
  def master_options(kind, options={})
    data = Master.find_masters(kind)
    tag = ""
    tag << %(<option value="">－</option>) if options[:blank]
    data.each do |code, name|
      tag << %(<option value="#{code}" )
      tag << selected(code, options[:value])
      tag << %(>#{name}</option>)
    end
    tag
  end

  # 指定されたマスタのラジオボタンのHTMLを返します
  # ==== Args
  # _kind_ :: マスタ種別
  # _options_ :: オプション
  # ==== Return
  # ラジオボタンのHTML
  # ==== Raise
  def master_radios(kind, options={})
    data = Master.find_masters(kind)
    tag = ""
    data.each do |code, name|
      tag << %(<input type="radio" name="evacuee[#{kind}]" id="evacuee-#{kind}-#{code}" value="#{code}" )
      tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
      tag << checked(code, options[:value])
      tag << "/>"
      tag << %(<label for="evacuee-#{kind}-#{code}">#{name}</label>)
    end
    tag
  end
  
  # 都道府県のオプションタグのHTMLを返します
  # ==== Args
  # _value_ :: 指定された値と一致する選択肢を選択状態にします
  # ==== Return
  # オプションタグのHTML
  # ==== Raise
  def state_options(value="")
    address = Address.all
    tag = %(<option value="">－</option>)
    address.each do |state_cd, data|
      tag << %(<option value="#{state_cd}" )
      tag << selected(state_cd, value)
      tag << %(>#{data[""]}</option>)
    end
    tag
  end
  
  # 市区町村のオプションタグのHTMLを返します
  # ==== Args
  # _state_cd_ :: 都道府県コード
  # _value_ :: 指定された値と一致する選択肢を選択状態にします
  # ==== Return
  # オプションタグのHTML
  # ==== Raise
  def city_options(state_cd, value="")
    cities = Address.find_cities(state_cd)
    tag = %(<option value="">－</option>)
    cities.each do |city_cd, city|
      next if city_cd == ""      
      tag << %(<option value="#{city_cd}" )
      tag << selected(city_cd, value)
      tag << %(>#{city[""]}</option>)
    end
    tag
  end
  
  # 町目字のオプションタグのHTMLを返します
  # ==== Args
  # _state_cd_ :: 都道府県コード
  # _city_cd_ :: 市区町村コード
  # _value_ :: 指定された値と一致する選択肢を選択状態にします
  # ==== Return
  # オプションタグのHTML
  # ==== Raise
  def street_options(state_cd, city_cd, value="")
    streets = Address.find_streets(state_cd, city_cd)
    tag = %(<option value="">－</option>)
    streets.each do |street_cd, name|
      next if street_cd == ""      
      tag << %(<option value="#{street_cd}" )
      tag << selected(street_cd, value)
      tag << %(>#{name}</option>)
    end
    tag
  end
  
  # 前ページへ遷移するリンクのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 前ページへ遷移するリンクのHTML
  # ==== Raise
  def page_up_tag(options={})
    tag = ""
    if options[:page] > 0 
      tag << %(<a href="#{url_for :action => :paginate, :query =>{:page => options[:page] - 1} }")
      tag << %( name="#{options[:name]}") if options[:name]
      tag << %( id="#{options[:id]}") if options[:id]
      tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
      tag << %( data-role="button" data-icon="arrow-l" data-direction="reverse" >前へ</a>)
    end
    tag
  end
  
  # 次ページへ遷移するリンクのHTMLを返します
  # ==== Args
  # _options_ :: オプション
  # ==== Return
  # 次ページへ遷移するリンクのHTML
  # ==== Raise
  def page_down_tag(options={})
    tag = ""
    if (options[:page] + 1) * Rho::RhoConfig.lgdpm_per_page.to_i < options[:num]
      tag << %(<a href="#{url_for :action => :paginate, :query =>{:page => options[:page] + 1} }")
      tag << %( name="#{options[:name]}") if options[:name]
      tag << %( id="#{options[:id]}") if options[:id]
      tag << %( data-theme="#{options[:data_theme]}") if options[:data_theme]
      tag << %( data-role="button" data-icon="arrow-r" data-iconpos="right">次へ</a>)
    end
    tag
  end
end