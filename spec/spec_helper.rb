$LOAD_PATH << File.join(File.dirname(__FILE__), %w[.. lib])
require 'rspec'
require 'redis'
require 'redis-rollbacks'
