describe "Master" do
  describe "load_master" do
    context "アプリ同梱JSON読み込みの場合" do
      before do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
        File.delete(file_name) if File.exist?(file_name)
      end
      it "JSONを読み込めること" do
        Master.load_master()
        Master.all().size.should == 14
        Master.all["sex"]["1"].force_encoding("utf-8").should == "男"
        Master.all["physical_disability_certificate"]["0"].force_encoding("utf-8").should == "該当しない"
      end
    end

    context "ダウンロードJSON読み込みの場合" do
      before do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
        File.open(file_name, "w") do |f|
          f.write('{"01":{"1":"AA","2":"AB"},"02":{"1":"BA","2":"BB","3":"BC"},"03":{"1":"CA","2":"CB"}}')
        end
      end
      it "JSONを読み込めること" do
        Master.load_master()
        Master.all().size.should == 3
        Master.all["02"]["1"].should == "BA"
        Master.all["03"]["2"].should == "CB"
      end
      after do
        file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
        File.delete(file_name) if File.exist?(file_name)
      end
    end
  end
  
  describe "find_masters" do
    before do
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
      File.open(file_name, "w") do |f|
        f.write('{"01":{"1":"AA","2":"AB"},"02":{"1":"BA","2":"BB","3":"BC"},"03":{"1":"CA","2":"CB"}}')
      end
      Master.load_master()
    end

    it "指定マスタデータを返すこと" do
      Master.find_masters("01").size.should == 2
      Master.find_masters("01")["1"].should == "AA"
      Master.find_masters("01")["2"].should == "AB"
    end
    after do
      file_name = File.join(Rho::RhoApplication::get_model_path('app','Master'), 'new_master.json')
      File.delete(file_name) if File.exist?(file_name)
    end
  end
end