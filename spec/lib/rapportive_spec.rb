require 'spec_helper'

describe Rapportive do
  
  it "should return data if using proxy" do
    data = Rapportive.lookup('jakub','kuchar','','gmail.com', true)
    data.should eq("jakub@gmail.com")
  end

  it "should return data if not using proxy" do
    data = Rapportive.lookup('jakub','kuchar','','gm.com', false)
    data.should eq("Nothing found")
  end

end