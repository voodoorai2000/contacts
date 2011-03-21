require 'spec_helper'
require 'contacts/windows_live'

describe Contacts::WindowsLive do

  before(:each) do
    config = YAML.load_file(File.expand_path("../../config/contacts.yml", __FILE__))
    Contacts.configure(config["test"])
    @wl = Contacts::WindowsLive.new
    @wl.delegation_token = "fake_token"
    @wl.token_expires_at = Time.now+1
  end


  context "return_url" do
    it "should allow the return url to be set in the config" do
      @wl.return_url.should_not == nil
    end
    
    it "should return the return url from configuration if the return url is not set" do
      @wl.authentication_url().length.should_not == 0
    end
    
  end
  
  context "authentication_url" do
    it "should return an authentication url" do
      @wl.authentication_url("http://browser.zen.turingstudio.com/test").length.should_not == 0
    end
  end

  context "contacts" do
     it "should return an array of contacts (all users with email addresses)" do
       contacts = @wl.contacts
       contacts.should_not == nil
       contacts.length.should == 3
     end
     
     it "should contain a single name which is a join of the first and last name fields" do
       contacts = @wl.contacts
       contacts[1].name.should == "Rafael Timbo"
     end
   end
end
