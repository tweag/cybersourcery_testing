require 'cybersourcery_testing/translating_proxy'

run CybersourceryTesting::TranslatingProxy.new({
  translating_proxy: ENV['CYBERSOURCERY_SOP_PROXY_URL'],
  silent_post_server: ENV['CYBERSOURCERY_SOP_TEST_URL'],
  target_host: ENV['CYBERSOURCERY_TARGET_HOST_URL'],
  response_page_url: ENV['CYBERSOURCERY_RESPONSE_PAGE_URL'],
  local_response_page_path: ENV['CYBERSOURCERY_LOCAL_RESPONSE_PAGE_PATH']
})
