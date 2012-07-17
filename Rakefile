#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

desc 'Run shoulda unit tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end


# Thanks, jekyll, for having your Rakefile on Github

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  line = File.read(gemspec_file)[/^\s*gem\.version\s*=\s*.*/]
  line.match(/.*gem\.version\s*=\s*['"](.*)['"]/)[1]
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

task :build do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

task :push do
  sh "gem push pkg/#{gem_file}"
end
