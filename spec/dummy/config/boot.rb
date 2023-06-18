ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)

# Set up gems listed in the Gemfile.
require "bundler/setup" if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
