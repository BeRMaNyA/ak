require File.expand_path("../lib/ak/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ak'
  s.summary     = 'Easily hot reload your ruby app'
  s.description = 'Lightweight library for "hot code" reloading'
  s.author      = 'Bernardo Castro'
  s.email       = 'bernacas@gmail.com'
  s.version     = Ak.version
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")
  s.add_dependency 'filewatcher', '~> 1.1.1'
end
