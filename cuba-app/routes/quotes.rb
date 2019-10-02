Ak.require 'repositories/quote'

module Routes
  class Quotes < Cuba
    define do
      on get, root do
        repo  = Repositories::Quote.new(mode: :api)
        quote = repo.random

        res.write quote
      end
    end
  end
end
