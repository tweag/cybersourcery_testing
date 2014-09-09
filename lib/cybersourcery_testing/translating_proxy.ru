require 'cybersourcery_testing/translating_proxy'

puts 'WE ARE HERE'
puts ARGV[0]

run CybersourceryTesting::TranslatingProxy.new({
  translating_proxy: 'http://127.0.0.1:5555',
  silent_post_server: 'https://testsecureacceptance.cybersource.com',
  target_host: 'http://127.0.0.1:5556',
  response_page_url: 'http://tranquil-ocean-5865.herokuapp.com/confirm',
  local_response_page_url: 'http://127.0.0.1:3000/confirm'
})
