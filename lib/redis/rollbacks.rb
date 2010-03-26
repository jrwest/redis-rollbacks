module Redis::Rollbacks
  ROLLBACK_PROCESSOR = {
    "set" => lambda { |client, type, *args| 
      case type
      when :create
        client.delete args[0]
      when :update
        client.set args[0], client.last_value(args[0])
      end
    }
  }

  def rollback_last
    if ROLLBACK_PROCESSOR.has_key?(last_command[0].to_s)
      ROLLBACK_PROCESSOR[last_command[0].to_s].call(self, last_effect, *last_command[1..last_command.size-1])
    end
  end
end                                                      
