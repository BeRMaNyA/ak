root = File.expand_path('./', File.dirname(__FILE__))
$LOAD_PATH.push root

require 'cuba'
require_relative '../lib/ak'

Ak.root = root
Ak.require 'routes/quotes'

Ak.start

Cuba.define do
  on default do
    run Routes::Quotes
  end
end
