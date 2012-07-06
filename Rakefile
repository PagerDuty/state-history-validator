#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'
require 'bundler'

#require 'state_history_validator'

desc 'Test'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
