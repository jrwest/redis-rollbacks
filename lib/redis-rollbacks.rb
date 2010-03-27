require 'redis/audit'
require 'redis/rollbacks'

Redis.send(:include, Redis::Audit)
Redis.send(:include, Redis::Rollbacks)
