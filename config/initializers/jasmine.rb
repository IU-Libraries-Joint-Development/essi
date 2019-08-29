# Setup Sprockets environment for serving Jasmine fixtures
if defined?(Jasmine::Jquery::Rails::Engine)
  JasmineFixtureServer = Sprockets::Environment.new
  
  JasmineFixtureServer.append_path 'app/assets/stylesheets'
  JasmineFixtureServer.append_path 'spec/javascripts/fixtures'
  
  JasmineFixtureServer.logger = Rails.logger
end
