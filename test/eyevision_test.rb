require 'test_helper'

class EyevisionTest < Minitest::Test

  def setup
    @client = Eyevision::Client.new("CLIENT ID", "CLIENT SECRET")
  end

  def test_works_with_base64
    stub_auth!
    stub_analyze!
    
    assert_equal(@client.analyze(image: "image"), {"tags" => %w(a b c)})
  end

  def test_works_with_url
    stub_auth!
    stub_analyze!

    image_url = "https://cdn.eyeem.com/thumb/fa153872f1fb87d2c49f03da2e605cbdc343230d-1479466499934/1200/1200"

    image_request = stub_request(:get, image_url)
      .to_return(status: 200, body: "imagebody")

    @client.analyze(url: image_url)

    assert_requested(image_request, times: 1)
  end

  def test_works_with_file
    stub_auth!
    analyze_request = stub_analyze!

    @client.analyze(file: __FILE__)

    assert_requested(analyze_request, times: 1)
  end

  def test_authentication_error
    stubbed_request = stub_request(:post, Eyevision::Client::BASE_URI + "/token")
      .to_return(status: 401)

    assert_raises(Eyevision::AuthenticationError) {
      @client.analyze(image: "bogusstring")
    }

    assert_requested(stubbed_request, times: 1)
  end

  def test_token_refresh

    stubbed_token_request = stub_auth!

    # so that it tries it before refreshing
    @client.instance_variable_set('@token', 'token')

    stubbed_image_request = stub_request(:post, Eyevision::Client::BASE_URI + "/analyze")
      .to_return(status: 401).then.to_return(status: 200, body: {responses: [tags: %w(a b c)]}.to_json)

    @client.analyze(image: "bogusstring")

    assert_requested(stubbed_token_request, times: 1)
    assert_requested(stubbed_image_request, times: 2)
  end

  private

  def stub_auth!
    stub_request(:post, Eyevision::Client::BASE_URI + "/token")
      .to_return(status: 200, body: {access_token: "token"}.to_json)
  end

  def stub_analyze!
    stub_request(:post, Eyevision::Client::BASE_URI + "/analyze").
      to_return(status: 200, body: {responses: [tags: %w(a b c)]}.to_json)
  end
end
