module Redis::Rollbacks
  ROLLBACK_PROCESSOR = {
    "set" => lambda { |client, type, *args| 
      case type
      when :create
        client.delete args[0]
      end
    }
  }

  def rollback_last
    if ROLLBACK_PROCESSOR.has_key?(last_command[0])
      ROLLBACK_PROCESSOR[last_command[0]].call(self, last_effect, *last_command[1..last_command.size-1])
    end
  end
end                                                      
