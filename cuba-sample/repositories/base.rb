module Repositories
  class Base
    attr_reader :mode, :source

    def initialize(mode:)
      @mode = mode
      raise 'api mode is only supported' unless api?
      @source = Object.const_get("Requests::#{repository_class}").new
    end

    def wrap(json)
      return nil unless json
      klass = Object.const_get "Entities::#{repository_class}"
      klass.wrap json
    end

    private

    def repository_class
      self.class.to_s.split('::').last
    end

    def api?
      @mode == :api
    end
  end
end
