module Redis::Rollbacks
  def self.included(base)
    base.extend(ClassMethods)
  end

  PROCESSOR = Hash.new

  def rollback_last
    if PROCESSOR.has_key?(last_command[0].to_s)
      PROCESSOR[last_command[0].to_s].call(self, last_effect, *last_command[1..last_command.size-1])
    end
  end

  module ClassMethods
    def rollback(command, &block)
      Redis::Rollbacks::PROCESSOR[command] = block
    end
  end
end                                                      
