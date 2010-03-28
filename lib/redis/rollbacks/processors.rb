class Redis
  
  # DELETE
  rollback "delete" do |client, type, *command|
    case (last_value = client.last_value(command[0]))
    when String
      client.set command[0], last_value
    when Array
      last_value.each do |member|
        client.rpush command[0], member
      end
    end
  end

  # LPOP
  rollback "lpop" do |client, type, *command|
    case type
    when :update
      client.lpush command[0], client.last_value(command[0]).first
    end
  end

  # LPUSH
  rollback "lpush" do |client, type, *command|
    case type
    when :create
      client.delete command[0]
    when :update
      client.lpop command[0]
    end
  end

  # RPOP
  rollback "rpop" do |client, type, *command|
    case type
    when :update
      client.rpush command[0], client.last_value(command[0]).last
    end
  end

  # RPUSH
  rollback "rpush" do |client, type, *args| 
    case type
    when :create
      client.delete args[0]
    when :update
      client.rpop args[0]
    end
  end

  # SET
  rollback "set" do |client, type, *command| 
    case type
    when :create
      client.delete command[0]
    when :update
      client.set command[0], client.last_value(command[0])
    end
  end
end
