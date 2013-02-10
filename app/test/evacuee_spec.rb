describe "Evacuee" do
  before(:all) do
    Rhom::Rhom.database_full_reset
    Rho::RhoUtils.load_offline_data(['object_values'], 'test')
    @lgdpm_per_page = Rho::RhoConfig.lgdpm_per_page
    Rho::RhoConfig.lgdpm_per_page = "300"
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
    File.delete(file_name) if File.exist?(file_name)
    Address.load_address()
  end
  
  describe "find_by_condition" do
    describe "by_alternate_family_name" do
      it "完全一致検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"alternate_family_name" => "アア"})
        evacuees.size.should == 1
        evacuees[0].object.should == "1"
      end
      it "部分一致検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"alternate_family_name" => "ア"})
        evacuees.size.should == 2
        evacuees[0].object.should == "1"
        evacuees[1].object.should == "2"
      end
    end

    describe "alternate_given_name" do
      it "完全一致検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"alternate_given_name" => "カカ"})
        evacuees.size.should == 1
        evacuees[0].object.should == "1"
      end
      it "部分一致検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"alternate_given_name" => "キ"})
        evacuees.size.should == 2
        evacuees[0].object.should == "2"
        evacuees[1].object.should == "3"
      end
    end
    
    describe "date_of_birth" do
      it "開始生年月日検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"date_of_birth_from" => "20040101"})
        evacuees.size.should == 2
        evacuees[0].object.should == "4"
        evacuees[1].object.should == "5"
      end
      it "終了生年月日検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"date_of_birth_to" => "20040101"})
        evacuees.size.should == 3
        evacuees[0].object.should == "1"
        evacuees[1].object.should == "2"
        evacuees[2].object.should == "3"
      end
    end

    describe "in_city_flag" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"in_city_flag" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "2"
        evacuees[1].object.should == "3"
      end
    end

    describe "shelter_name" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"shelter_name" => "11"})
        evacuees.size.should == 1
        evacuees[0].object.should == "1"
      end
    end

    describe "injury_flag" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"injury_flag" => "1"})
        evacuees.size.should == 3
        evacuees[0].object.should == "3"
        evacuees[1].object.should == "4"
        evacuees[2].object.should == "5"
      end
    end

    describe "allergy_flag" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"allergy_flag" => "1"})
        evacuees.size.should == 3
        evacuees[0].object.should == "1"
        evacuees[1].object.should == "3"
        evacuees[2].object.should == "5"
      end
    end

    describe "pregnancy" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"pregnancy" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "2"
        evacuees[1].object.should == "4"
      end
    end

    describe "baby" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"baby" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "2"
        evacuees[1].object.should == "5"
      end
    end

    describe "upper_care_level_three" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"upper_care_level_three" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "4"
        evacuees[1].object.should == "5"
      end
    end

    describe "elderly_alone" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"elderly_alone" => "1"})
        evacuees.size.should == 3
        evacuees[0].object.should == "1"
        evacuees[1].object.should == "3"
        evacuees[2].object.should == "5"
      end
    end

    describe "elderly_couple" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"elderly_couple" => "1"})
        evacuees.size.should == 3
        evacuees[0].object.should == "3"
        evacuees[1].object.should == "4"
        evacuees[2].object.should == "5"
      end
    end

    describe "bedridden_elderly" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"bedridden_elderly" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "1"
        evacuees[1].object.should == "2"
      end
    end

    describe "elderly_dementia" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"elderly_dementia" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "4"
        evacuees[1].object.should == "5"
      end
    end

    describe "rehabilitation_certificate" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"rehabilitation_certificate" => "01"})
        evacuees.size.should == 1
        evacuees[0].object.should == "1"
      end
    end

    describe "physical_disability_certificate" do
      it "検索されること" do
        evacuees = Evacuee.find_by_condition(0, {"physical_disability_certificate" => "1"})
        evacuees.size.should == 2
        evacuees[0].object.should == "1"
        evacuees[1].object.should == "4"
      end
    end

    describe "paginate" do
      before(:all) do
        Rho::RhoConfig.lgdpm_per_page="2"
      end
      it "2ページ目が検索されること" do
        evacuees = Evacuee.find_by_condition(1)
        evacuees.size.should == 2
        evacuees[0].object.should == "3"
        evacuees[1].object.should == "4"
      end
      after(:all) do
        Rho::RhoConfig.lgdpm_per_page="300"
      end
    end
  end

  describe "count_by_condition" do
    it "件数が返されること" do
      cnt = Evacuee.count_by_condition({"date_of_birth_from" => "20030101", "date_of_birth_to" => "20050101"})
      cnt.should == 2
    end
  end

  describe "url_encode" do
    it "エンコード文字列が返されること" do
      evacuee = Evacuee.find("1")
      evacuee.url_encode.should == <<EOS.gsub("\n", "")
commit_kind=save
&evacuee[family_name]=%E3%81%82%E3%81%82
&evacuee[given_name]=%E3%81%8B%E3%81%8B
&evacuee[alternate_family_name]=%E3%82%A2%E3%82%A2
&evacuee[alternate_given_name]=%E3%82%AB%E3%82%AB
&evacuee[date_of_birth]=2001-01-01
&evacuee[sex]=1
&evacuee[in_city_flag]=0
&evacuee[home_postal_code]=1230001
&evacuee[home_state]=01
&evacuee[home_city]=%E6%9C%AD%E5%B9%8C%E5%B8%82%E4%B8%AD%E5%A4%AE%E5%8C%BA
&evacuee[home_street]=%E6%97%AD%E3%82%B1%E4%B8%98
&evacuee[house_number]=1
&evacuee[shelter_name]=11
&evacuee[refuge_status]=1
&evacuee[refuge_reason]=%E9%81%BF%E9%9B%A3%E7%90%86%E7%94%B1
&evacuee[shelter_entry_date]=2011-02-03
&evacuee[shelter_leave_date]=2012-04-05
&evacuee[next_place]=%E9%80%80%E6%89%80%E5%85%88
&evacuee[next_place_phone]=01-2345-6789
&evacuee[injury_flag]=0
&evacuee[injury_condition]=%E8%B2%A0%E5%82%B7%E5%86%85%E5%AE%B9
&evacuee[allergy_flag]=1
&evacuee[allergy_cause]=%E3%82%A2%E3%83%AC%E3%83%AB%E3%82%AE%E3%83%BC%E7%89%A9%E8%B3%AA
&evacuee[pregnancy]=0
&evacuee[baby]=0
&evacuee[upper_care_level_three]=0
&evacuee[elderly_alone]=1
&evacuee[elderly_couple]=0
&evacuee[bedridden_elderly]=1
&evacuee[elderly_dementia]=0
&evacuee[rehabilitation_certificate]=01
&evacuee[physical_disability_certificate]=1
&evacuee[note]=%E5%82%99%E8%80%83
EOS
    end
  end

  after(:all) do
    Rho::RhoConfig.lgdpm_per_page = @lgdpm_per_page
  end
end