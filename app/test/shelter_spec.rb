describe "Shelter" do
  describe "load_shelter" do
    context "アプリ同梱JSON読み込みの場合" do
      before do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
        File.delete(file_name) if File.exist?(file_name)
      end
      it "JSONを読み込めること" do
        Shelter.load_shelter()
        Shelter.all().size.should == 311
        Shelter.all["1"].force_encoding("utf-8").should == "石巻小学校"
        Shelter.all["311"].force_encoding("utf-8").should == "牡鹿保健福祉センター（市管理分）"
      end
    end

    context "ダウンロードJSON読み込みの場合" do
      before do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
        File.open(file_name, "w") do |f|
          f.write('{"01":"A","02":"B","03":"C","04":"D"}')
        end
      end
      it "JSONを読み込めること" do
        Shelter.load_shelter()
        Shelter.all().size.should == 4
        Shelter.all["02"].should == "B"
        Shelter.all["04"].should == "D"
      end
      after do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
        File.delete(file_name) if File.exist?(file_name)
      end
    end
  end
  
  describe "find_name" do
    before do
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
      File.open(file_name, "w") do |f|
        f.write('{"01":"A","02":"B","03":"C","04":"D"}')
      end
      Shelter.load_shelter()
    end

    it "避難所名を返すこと" do
      Shelter.find_name("03").should == "C"
    end
    after do
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Shelter'), 'new_shelter.json')
      File.delete(file_name) if File.exist?(file_name)
    end
  end
end