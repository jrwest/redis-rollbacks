module Redis::Audit
  NO_EFFECT_COMMANDS = %w[get randomkey]
  DESTRUCTIVE_COMMANDS = %w[delete]
  RECORD_PREVIOUS_COMMANDS = %w[set]
  def self.included(base)
    base.send(:attr_reader, :last_command, :last_effect)
    base.send(:alias_method, :call_command_without_audit, :call_command)
    base.send(:alias_method, :call_command, :call_command_with_audit)
  end

  def call_command_with_audit(argv)
    if record_effect(argv) == :update && RECORD_PREVIOUS_COMMANDS.include?(argv[0].to_s) 
      record_value(argv[1])
    end
    command_return = call_command_without_audit(argv)
    @last_command = argv
    command_return
  end

  def last_value(key)
    return unless @last_values
    @last_values[key]
  end

  def serialize_command(argv)
    argv.join(' ')
  end

  class Stack
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

  private

    def record_effect(argv)
      @last_effect = (!NO_EFFECT_COMMANDS.include? argv[0].to_s) ? effect_for(argv) : :none
    end

    def record_value(key)
      @last_values ||= {}
      @last_values[key] = call_command_without_audit ['get', key]
    end

    def effect_for(argv)
      DESTRUCTIVE_COMMANDS.include?(argv[0].to_s) ? :destroy : effect_for_non_destructive_command(argv[1])       
    end

    def effect_for_non_destructive_command(key)
      call_command_without_audit(['exists', key]) ? :update : :create
    end

end
