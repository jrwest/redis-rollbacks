require 'redis/audit'
require 'redis/rollbacks'
require 'redis/stack'

Redis.send(:include, Redis::Audit)
Redis.send(:include, Redis::Rollbacks)
