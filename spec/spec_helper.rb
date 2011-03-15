require 'fake_web'

FakeWeb.allow_net_connect = false

RSpec.configure do |config| 
end

def fake_responses
  FakeWeb.register_uri(:post, 'https://www.google.com/accounts/OAuthGetRequestToken', :body => 'oauth_token=faketoken&oauth_token_secret=faketokensecret')
  FakeWeb.register_uri(:post, 'https://www.google.com/accounts/OAuthGetAccessToken', :body => 'oauth_token=fake&oauth_token_secret=fake')
  FakeWeb.register_uri(:get, 'http://www.google.com/m8/feeds/contacts/default/thin?max-results=200', :body => feeds('google-many.xml'))
end

def feeds(*path)
  File.join(File.dirname(__FILE__), "feeds", path)
end