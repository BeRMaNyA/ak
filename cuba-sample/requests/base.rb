require 'net/http'

module Requests
  class Base
    def get(path)
      url = self.class::URL
      uri = URI.parse("#{url}#{path}")

      request = Net::HTTP::Get.new(uri)

      response = Net::HTTP.start(uri.hostname, uri.port, { use_ssl: true }) do |http|
        http.request(request)
      end

      JSON.parse(response.body) rescue nil
    end
  end
end
