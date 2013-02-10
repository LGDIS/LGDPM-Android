require 'Address/address_controller'
require 'spec_helper'

describe "AddressController" do
  before(:all) do
    file_name = File.join(Rho::RhoApplication::get_model_path('app','Address'), 'new_address.json')
    File.open(file_name, "w") do |f|
      f.write('{"01":{"":"A","001":{"":"AA","0001":"AAA","0002":"AAB"},"002":{"":"AB","0001":"ABA","0002":"ABB"}}')
      f.write(',"02":{"":"B","001":{"":"BA","0001":"BAA","0002":"BAB"},"002":{"":"BB","0001":"BBA","0002":"BBB"}}}')
    end
    @application = AppApplication.new
    @controller = AddressController.new
  end

  describe "cities" do
    it "市区町村オプションタグを返すこと" do
      actual = @controller.serve(@application, nil, SpecHelper.create_request("GET /Address/cities", "state_cd" => "01"), {})
      actual.should == '<option value="">－</option><option value="001" >AA</option><option value="002" >AB</option>'
    end
  end
  
  
end
