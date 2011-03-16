require 'spec_helper'
require 'contacts/yahoo'

describe Contacts::Yahoo do
  before(:each) do
    config = YAML.load_file(File.expand_path("../../config/contacts.yml", __FILE__))
    Contacts.configure(config["test"])
    @yahoo = Contacts::Yahoo.new
    fake_responses
  end

  context "authentication_url" do
    it "should return an authentication url" do
      @yahoo.authentication_url("http://browser.zen.turingstudio.com/test").length.should_not == 0
    end
  end

  context "authorize" do
    it "should set the access token if the authoriztion is granted" do
      @yahoo.authentication_url("http://browser.zen.turingstudio.com/test").length.should_not == 0
      @yahoo.authorize({})
      @yahoo.access_token.should_not == nil
    end
  end

  context "contacts" do
    it "should return an array of contacts (all users with email addresses)" do
      @yahoo.authentication_url("http://browser.zen.turingstudio.com/test").length.should_not == 0
      @yahoo.authorize({})
      contacts = @yahoo.contacts
      contacts.should_not == nil
      contacts.length.should == 3
    end

    it "should return multiple email addresses for user with multiple email addresses" do
      @yahoo.authentication_url("http://browser.zen.turingstudio.com/test").length.should_not == 0
      @yahoo.authorize({})
      contacts = @yahoo.contacts
      contacts[1].emails.length.should == 2
    end
  end
end