require 'spec_helper'

describe Rapportive do
  
  it "should return data" do
    data = Rapportive.lookup('jakub','kuchar','','gmail.com')
    data.should include('contact')
  end

end