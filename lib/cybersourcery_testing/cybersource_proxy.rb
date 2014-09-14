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

get '/*' do |path|
  response = Net::HTTP.get_response(URI uri)
  code     = response.code.to_i
  type     = response.content_type
  body     = response.body
  [code, { 'Content-Type' => type }, body]
end

post '/*' do |path|
  response = Net::HTTP.get_response(URI uri)
  code     = response.code.to_i
  type     = response.content_type
  body     = response.body
  [code, { 'Content-Type' => type }, body]
end
