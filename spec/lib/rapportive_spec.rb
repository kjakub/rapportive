require 'spec_helper'

describe Rapportive do
  
  it "should return data if using proxy" do
    data = Rapportive.lookup('jakub','kuchar','','gmail.com', true)
    data.should eq("jakub@gmail.com")
  end

end