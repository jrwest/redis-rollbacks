when testing an application using Redis there is no way to have atomic examples. Operation effects remain in the database between examples. This is a first step into possibly changing that.

### Example

#### Rolling Back a SET that creates a key
   
   require 'redis'
   require 'redis-rollbacks'  

   r = Redis.new 
   r.delete 'key' # just so you know its not there for purposes of this example
   r.set 'key', 'abc'
   r.last_command # [:set, 'abc', 'key']
   r.last_effect  # :create
   r.rollback_last
   r.get 'key'    # nil 