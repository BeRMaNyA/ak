Ak.require 'repositories/base'
Ak.require 'requests/quote'
Ak.require 'entities/quote'

module Repositories
  class Quote < Base
    def all
      wrap(source.all)
    end

    def find(id)
      json = source.find(id)
      wrap(json)
    end

    def random
      wrap(source.random)
    end
  end
end
