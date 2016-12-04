require "json"
require "httparty"
require "base64"

require "eyevision/version"
require "eyevision/client"

module Eyevision
  class AuthenticationError < StandardError; end
  class ApiError < StandardError; end
end
