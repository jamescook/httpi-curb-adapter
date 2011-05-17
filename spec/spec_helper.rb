
require "bundler"
Bundler.require :default, :development

RSpec.configure do |config|
  config.mock_with :rspec
end

HTTPI.log = false  # disable for specs

require "support/fixture.rb"
require "support/matchers.rb"
