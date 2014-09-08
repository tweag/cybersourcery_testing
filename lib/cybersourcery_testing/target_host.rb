require 'sinatra'
require 'base64'
require 'json'
require 'vcr'
require 'nokogiri'
require 'webmock'
require 'cybersourcery'
require 'cybersourcery_testing/vcr'
require ARGV[0] # path to cybersourcery initializer

CybersourceryTesting::Vcr.configure

get('/') { "It's not a trick it's an illusion" }

get '/*' do |path|
  proxy_request do |uri|
    Net::HTTP.get_response(uri)
  end
end

post '/*' do |path|
  uri = URI "#{Cybersourcery.configuration.sop_test_url}/#{path}"
  response = nil

  if Cybersourcery.configuration.use_vcr_in_tests
    VCR.use_cassette('cybersourcery',
      record: :new_episodes,
      match_requests_on: %i(method uri card_number_equality)) do
        response = Net::HTTP.post_form(uri, params)
      end
  else
     response = Net::HTTP.post_form(uri, params)
  end

  code     = response.code.to_i
  type     = response.content_type
  body     = response.body
  [code, { 'Content-Type' => type }, body]
end
