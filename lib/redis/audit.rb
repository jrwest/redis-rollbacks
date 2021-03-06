module Redis::Audit
  NO_EFFECT_COMMANDS = %w[get randomkey]
  DESTRUCTIVE_COMMANDS = %w[delete]
  RECORD_PREVIOUS_COMMANDS = %w[set delete lpush lpop rpush rpop]
  def self.included(base)
    base.send(:attr_reader, :last_effect, :audit_stack)
    base.send(:alias_method, :call_command_without_audit, :call_command)
    base.send(:alias_method, :call_command, :call_command_with_audit)
  end

  def audit_key
    'redis:audit'
  end

  # TODO refactor, refactor, refactor
  def call_command_with_audit(argv)
    if [:update, :destroy].include?(record_effect(argv)) && RECORD_PREVIOUS_COMMANDS.include?(argv[0].to_s) 
      record_value(argv[1])
    end
    command_return = call_command_without_audit(argv)
    if @audit_stack
      @audit_stack.push serialize_command(argv)
    else
      @last_command = serialize_command(argv)
    end
    command_return
  end

  def last_command(n = 1)
    if @audit_stack
      n = @audit_stack.size if n > @audit_stack.size
      commands = @audit_stack.to_a[0...n].map { |c| unserialize_command(c) }
      commands.size > 1 ? commands : commands[0]
    else
      unserialize_command(@last_command)
    end
  end

  def last_value(key)
    return unless @last_values
    @last_values[key]
  end
  
  def serialize_command(argv)
    argv.join(' ')
  end
  
  def start_audit
    @audit_stack = Stack.new(:db => self, :key => audit_key)
  end

  def stop_audit
    @audit_stack.destroy
    @audit_stack = nil
  end
  
  def unserialize_command(command)
    command.split(' ')
  end

  class Stack
    attr_reader :key

    def destroy
      @db.call_command_without_audit ['delete', key]
    end

    def empty?
      size == 0
    end
    
    def initialize(options)
      @key = options[:key]
      @db = options[:db]
    end
    
    def peek
      (@db.call_command_without_audit ['lrange', key, 0, 0]).first
    end
    
    def pop
      @db.call_command_without_audit ['lpop', key]
    end
    
    def push(*members)
      members.each do |member|
        @db.call_command_without_audit ['lpush', key, member]
      end
    end
    
    def size
      to_a.size
    end
    
    def to_a
      @db.call_command_without_audit ['lrange', key, 0, -1]
    end
  end

  private

    def record_effect(argv)
      @last_effect = (!NO_EFFECT_COMMANDS.include? argv[0].to_s) ? effect_for(argv) : :none
    end

    def record_value(key)
      @last_values ||= {}
      case call_command_without_audit ['type', key]
      when 'string'
        @last_values[key] = call_command_without_audit ['get', key]
      when 'list'
        @last_values[key] = call_command_without_audit ['lrange', key, 0, -1]
      end
    end

    def effect_for(argv)
      DESTRUCTIVE_COMMANDS.include?(argv[0].to_s) ? :destroy : effect_for_non_destructive_command(argv[1])       
    end

    def effect_for_non_destructive_command(key)
      call_command_without_audit(['exists', key]) ? :update : :create
    end

end
