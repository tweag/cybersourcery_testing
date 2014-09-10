require 'sinatra'
require 'base64'
require 'json'
require 'vcr'
require 'nokogiri'
require 'webmock'
require 'cybersourcery'
require 'cybersourcery_testing/vcr'

CybersourceryTesting::Vcr.configure

get('/') { "It's not a trick it's an illusion" }

get '/*' do |path|
  response = Net::HTTP.get_response(URI uri)
  code     = response.code.to_i
  type     = response.content_type
  body     = response.body
  [code, { 'Content-Type' => type }, body]
end

post '/*' do |path|
  uri = URI "#{ENV['CYBERSOURCERY_SOP_TEST_URL']}/#{path}"
  response = nil

  if ENV['CYBERSOURCERY_USE_VCR_IN_TESTS']
    VCR.use_cassette(
      'cybersourcery',
      record: :new_episodes,
      match_requests_on: CybersourceryTesting::Vcr.match_requests_on
    ) do
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
