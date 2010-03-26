require 'redis/audit'

Redis.send(:include, Redis::Audit)
