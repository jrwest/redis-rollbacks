class Redis::Stack
  attr_reader :key

  def empty?
    size == 0
  end
  
  def initialize(options)
    @key = options[:key]
    @db = options[:db]
  end

  def peek
    (@db.lrange key, 0, 0).first
  end

  def pop
    @db.lpop key
  end

  def push(*members)
    members.each do |member|
      @db.lpush key, member
    end
  end

  def size
    to_a.size
  end

  def to_a
    @db.lrange key, 0, -1
  end
end
