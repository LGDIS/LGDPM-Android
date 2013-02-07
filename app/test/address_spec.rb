describe "Address" do
  describe "load_address" do
    context "アプリ同梱JSON読み込みの場合" do
      before do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
        File.delete(file_name) if File.exist?(file_name)
      end
      it "JSONを読み込めること" do
        Address.load_address()
        Address.all().size.should == 47
        Address.all["04"][""].force_encoding("utf-8").should == "宮城県"
        Address.all["04"]["202"][""].force_encoding("utf-8").should == "石巻市"
        Address.all["01"]["101"]["0001"].force_encoding("utf-8").should == "旭ケ丘"
        Address.all["47"]["382"]["0001"].force_encoding("utf-8").should == "与那国"
      end
    end

    context "ダウンロードJSON読み込みの場合" do
      before do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
        File.open(file_name, "w") do |f|
          f.write('{"01":{"":"A","001":{"":"AA","0001":"AAA","0002":"AAB"},"002":{"":"AB","0001":"ABA","0002":"ABB"}}')
          f.write(',"02":{"":"B","001":{"":"BA","0001":"BAA","0002":"BAB"},"002":{"":"BB","0001":"BBA","0002":"BBB"}}}')
        end
      end
      it "JSONを読み込めること" do
        Address.load_address()
        Address.all().size.should == 2
        Address.all["02"][""].should == "B"
        Address.all["01"]["002"]["0002"].should == "ABB"
      end
      after do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
        File.delete(file_name) if File.exist?(file_name)
      end
    end
  end
  describe "find" do
    before(:all) do
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
      File.open(file_name, "w") do |f|
        f.write('{"01":{"":"A","001":{"":"AA","0001":"AAA","0002":"AAB"},"002":{"":"AB","0001":"ABA","0002":"ABB"}}')
        f.write(',"02":{"":"B","001":{"":"BA","0001":"BAA","0002":"BAB"},"002":{"":"BB","0001":"BBA","0002":"BBB"}}}')
      end
      Address.load_address()
    end
    describe "find_cities" do
      it "市区町村データを返すこと" do
        Address.find_cities("01").size.should == 3
        Address.find_cities("01")[""].should == "A"
      end
    end
    describe "find_streets" do
      it "町目字データデータを返すこと" do
        Address.find_streets("02", "002").size.should == 3
        Address.find_streets("02", "002")[""].should == "BB"
      end
    end
    describe "find_city_name" do
      it "市区町村名を返すこと" do
        Address.find_city_name("01", "002").should == "AB"
      end
    end
    describe "find_street_name" do
      it "町名を返すこと" do
        Address.find_street_name("02", "001", "0002").should == "BAB"
      end
    end
    after(:all) do
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
      File.delete(file_name) if File.exist?(file_name)
    end
  end
end

