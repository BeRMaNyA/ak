Ak.require_relative 'base'

module Requests
  class Quote < Base
    URL = 'https://programming-quotes-api.herokuapp.com'

    def all
      get '/quotes' 
    end

    def find(id)
      get "/quotes/id/#{id}"
    end

    def random
      get '/quotes/random'
    end
  end
end
