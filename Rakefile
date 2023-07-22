require "rake"
require "bundler/setup"
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rails'
  task.requires << 'rubocop-performance'
  task.requires << 'rubocop-rspec'
  task.requires << 'rubocop-rake'
  task.requires << 'rubocop-factory_bot'
end

task default: %i[spec rubocop]
