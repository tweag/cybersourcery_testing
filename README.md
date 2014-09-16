# Cybersourcery Testing

For Rails projects, supports feature/integration testing of the Cybersource Silent Order POST (SOP) service. It can be used with [the Cybersourcery gem](https://github.com/promptworks/cybersourcery) or as a stand-alone testing service. It uses a Sinatra proxy server and [VCR](https://github.com/vcr/vcr), to avoid the need for repeated requests to the Cybersource SOP test server.

## Features

Automated testing with Cybersource SOP is more difficult than typical 3rd party services. When a transaction is submitted, Cybersource dynamically generates a hidden form in the user's browser, which it then automatically submits to your site's response page for the transaction. Also, both your submission to Cybersource, and the response from Cybersource, require the verification of signatures that are unique to each transaction. The Cybersourcery Testing gem handles these complexities for you.

It includes:

* A proxy server to stand-in for the Cybersource SOP test server. It runs on Sinatra, and includes a middleware translating proxy which directs both requests to, and responses from, the Cybersource SOP test server to the Sinatra server.
* Detection and alerts for undocumented Cybersource SOP error conditions, where Cybersource returns only a general server error message. The proxy server will detect these conditions and raise exceptions that include clear explanations.
* VCR to record your test transactions, for re-use in future test runs. 
* The ability to define your own custom matchers, to detect variations in the data in test submissions. The gem comes with a check for changes in the credit card number. You can add checks for other fields as needed for your business requirements.

When a test is run that shows a change against any of the matchers you have defined, the proxy server will forward the transaction to the actual Cybersource SOP test server, and VCR will record the transaction. Subsequent runs of the same test will rely on the VCR recording. This means you can do repeated feature/integration testing without requiring ongoing contact with the Cybersource SOP test server.

## Installation

1. Add it to your Gemfile and run bundle:

  ```ruby
  gem 'cybersourcery_testing'
  bundle
  ```

2. Run the generator for creating a sample .env file, and update your .env file:

  ```console
  rails generate cybersourcery_testing:dotenv
  ```
  
  This generates a file in your Rails root directory named `.env.cybersourcery_testing_sample`. If you do not have a `.env` file already, rename it to `.env`. If you do have a `.env` file, copy the contents of the sample file and paste them to the end of your .env file. You can then delete the sample file.
  
3. Update your .env settings as needed:

  * CYBERSOURCERY_SOP_TEST_URL: the URL of the Cybersource Silent Order Post (SOP) test server. You should not need to change this.
  * CYBERSOURCERY_SOP_PROXY_URL: the base URL the Sinatra proxy will use.
  * CYBERSOURCERY_RESPONSE_PAGE_URL: this must match the "Customer Response Page" URL you have set in the Cybersource Business Center for the profile you will use when testing.
  * CYBERSOURCERY_LOCAL_RESPONSE_PAGE_PATH: the path to the local equivalent of the "Customer Response Page" (should be in URI path format, e.g. `/confirm`)
  * CYBERSOURCERY_USE_VCR_IN_TESTS: `true` or `false`. This should be `true` unless you have a special reason to change it. If you do not set this to `true` the Sinatra proxy will always forward all requests to the actual Cybersource SOP test server.
  * CYBERSOURCERY_VCR_CASSETTE_DIR: the relative path to where your VCR cassette file should be stored

## Usage

### Optional: Define matchers for VCR

When you submit a transaction through the proxy server, it will forward the request to the Cybersource SOP test sever only if there is a change in a field that VCR has a matcher for. VCR checks its existing cassettes to see if the request has changes to any of the fields it has matchers for. So it's up to you to decide which fields are important for detecting and testing changes in.

A matcher for detecting changes in the credit card number is included. If that's all you need, then you can skip the rest of this step.

To set up your own matchers:

1. Create a file to put your matchers in. Here is an example for detecting changes to the card type:
 
  ```ruby
  require 'cybersourcery_testing/cybersource_proxy'
 
  VCR.configure do |c|
    c.register_request_matcher :card_type_equality do |request_1, request_2|
      pattern = /\&card_type=(\d+)\&/i
      CybersourceryTesting::Vcr.did_it_change?(pattern, request_1.body, request_2.body)
    end
  end
  ```

  You can make as many `register_request_matcher` calls as you need.
  
2. Add the relative path to this file to your .env file, with the variable name `CYBERSOURCERY_SOP_PROXY_RB_PATH`. For example:

  ```console
  CYBERSOURCERY_SOP_PROXY_RB_PATH = 'spec/cybersource_proxy_custom.rb'
  ```

### Start the proxy server

The gem comes with a rake task for starting the proxy server:

```console
rake cybersourcery:proxy
```

It's a Sinatra server, running with Shotgun, which means you do not need to restart it if there are application changes, as Shotgun reloads the application each time. This entails a performance cost, but provides flexibility, and helps resolve certain technical issues with running VCR in the context of a middleware proxy.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/cybersourcery_testing/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
