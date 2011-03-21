require 'fake_web'

FakeWeb.allow_net_connect = false

RSpec.configure do |config| 
end

def fake_responses
  FakeWeb.register_uri(:post, 'https://www.google.com/accounts/OAuthGetRequestToken', :body => 'oauth_token=faketoken&oauth_token_secret=faketokensecret')
  FakeWeb.register_uri(:post, 'https://www.google.com/accounts/OAuthGetAccessToken', :body => 'oauth_token=fake&oauth_token_secret=fake')
  FakeWeb.register_uri(:get, 'https://www.google.com/m8/feeds/contacts/default/thin?max-results=200', :body => feeds('google-many.xml'))
  FakeWeb.register_uri(:post, 'https://api.login.yahoo.com/oauth/v2/get_request_token', :body => 'oauth_token=faketoken&oauth_token_secret=faketokensecret')
  FakeWeb.register_uri(:post, 'https://api.login.yahoo.com/oauth/v2/get_token', :body => 'oauth_token=fake&oauth_token_secret=fake&xoauth_yahoo_guid=tester')
  FakeWeb.register_uri(:get, 'http://social.yahooapis.com/v1/user/tester/contacts?count=200&sort=asc&sort-fields=email&format=json', :body => feeds('yh_contacts.txt'))
  FakeWeb.register_uri(:get, 'https://livecontacts.services.live.com/users/@L@/rest/invitationsbyemail', :body => feeds('wl_contacts.xml'))
end

def feeds(*path)
  File.join(File.dirname(__FILE__), "feeds", path)
end