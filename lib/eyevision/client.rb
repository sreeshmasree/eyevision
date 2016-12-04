module Eyevision
  class Client
    include HTTParty

    BASE_URI = "https://vision-api.eyeem.com/v1"
    base_uri BASE_URI

    SUPPORTED_FEATURES = %w(TAGS CAPTIONS AESTHETIC_SCORE)

    def initialize(client_id, client_secret)
      @client_id     = client_id
      @client_secret = client_secret
    end

    def analyze(opts)
      case
      when opts[:file]
        image = from_file(opts[:file])
      when opts[:url]
        image = from_url(opts[:url])
      when opts[:image]
        image = opts[:image]
      else
        raise "You need to supply an image, file or URL"
      end

      features = SUPPORTED_FEATURES & (opts[:features] || SUPPORTED_FEATURES)

      resp = request('/analyze', body: body(image, features), headers: auth_headers, format: :json)

      JSON.parse(resp.body)["responses"].first
    end

    private

    def request(url, options, retry_count=1)
      resp = self.class.post(url, options)

      case resp.code
      when 200
        resp
      when 401 # token refresh
        if retry_count > 0
          @token = nil

          request(url, options.merge(headers: auth_headers), (retry_count - 1))
        else
          raise AuthenticationError, resp.body
        end
      else
          raise ApiError, resp.body 
      end
    end

    def encode(image)
      Base64.strict_encode64(image)
    end

    def from_url(url)
      encode(HTTParty.get(url).body)
    end

    def from_file(path)
      encode(File.binread(path))
    end

    def body(image, features)
      tasks = features.map{|f| {type: f}}
      {requests: [{ tasks: tasks, image: { content: image }}]}.to_json
    end

    def auth_headers
      {'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}"}
    end

    def token
      @token ||= request('/token', {body: {clientId: @client_id, clientSecret: @client_secret}, headers: {'Content-Type' => 'application/x-www-form-urlencoded'}}, retry_count=0)['access_token']
    end
  end
end
