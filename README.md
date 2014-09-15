# Cybersourcery Testing

Supports feature/integration testing of the Cybersource Silent Order POST (SOP) service. It can be used with [Cybersourcery](https://github.com/promptworks/cybersourcery) or as a stand-alone service. Uses a proxy server and VCR, to avoid the need for repeated requests to the Cybersource SOP test server.

## Features

Automated testing with Cybersource SOP is more difficult than typical 3rd party services. When a transaction is submitted, Cybersource dynamically generates a hidden form in the user's browser, which it then automatically submits to your site's response page for the transaction. Also, both your submission to Cybersource, and the response from Cybersource, require the verification of signatures that are unique to each transaction.

The Cybersourcey Testing gem includes:

* A proxy server to stand-in for the Cybersource SOP test server. It runs on Sinatra, and includes a middleware translating proxy which directs both requests to, and responses from, the Cybersource SOP test server to the Sinatra server.
* [VCR](https://github.com/vcr/vcr) to record your test transactions, for re-use in future test runs. 
* The ability to define your own custom matchers, to detect variations in the data in test submissions. The gem comes with a check for changes in the credit card number. You can add checks for other fields as needed for your business requirements.

When a test is run that shows a change against any of the matchers you have defined, the proxy server will forward the test to the actual Cybersource SOP test server, which VCR will record. Subsequent runs of the same tests will rely on the VCR recordings. This means you can do repeated feature/integration testing without requiring ongoing contact with the Cybersource SOP test server.

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
  
  This generates a file in your root directory named `.env.cybersourcery_testing_sample`. If you do not have a `.env` file already, rename it to `.env`. If you do have a `.env` file, copy the contents of the sample file and paste them to the end of your .env file. You can then delete the sample file.
  
3. Update your .env settings as needed:

* CYBERSOURCERY_SOP_TEST_URL: the URL of the Cybersource silent order post (SOP) test server. You should not need to change this.
* CYBERSOURCERY_SOP_PROXY_URL: the base URL the Sinatra proxy will use.
* CYBERSOURCERY_RESPONSE_PAGE_URL: this must match the "Customer Response Page" you have set in the Cybersource Business Center for the profile you will use when testing.
* CYBERSOURCERY_LOCAL_RESPONSE_PAGE_PATH: the path to the local equivalent of the "Customer Response Page" (should be in URI path format, e.g. `/confirm`)
* CYBERSOURCERY_USE_VCR_IN_TESTS: `true` or `false`. This should be `true` unless you have a special reason. If you do not set this to `true` the Sinatra proxy will always forward all requests to the actual Cybersource SOP test server.
* CYBERSOURCERY_VCR_CASSETTE_DIR: the relative path to where your VCR cassette file should be stored


## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cybersourcery_testing/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
