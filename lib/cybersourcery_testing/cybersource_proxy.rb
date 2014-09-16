require 'sinatra'
require 'base64'
require 'json'
require 'vcr'
require 'nokogiri'
require 'webmock'
require 'cybersourcery'
require 'cybersourcery_testing/vcr'
require 'cybersourcery_testing/translating_proxy'

use CybersourceryTesting::TranslatingProxy

CybersourceryTesting::Vcr.configure

get('/') do
  [200, {'Content-Type' => 'text/html'}, ["It's not a trick it's an illusion"]]
end
