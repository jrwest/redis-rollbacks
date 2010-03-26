module Redis::Audit
  NO_EFFECT_COMMANDS = %w[get randomkey]
  DESTRUCTIVE_COMMANDS = %w[delete]
  def self.included(base)
    base.send(:attr_reader, :last_command, :last_effect)
    base.send(:alias_method, :call_command_without_audit, :call_command)
    base.send(:alias_method, :call_command, :call_command_with_audit)
  end
  
  def serialize_command(argv)
    argv.join(' ')
  end

  def call_command_with_audit(argv)
    record_effect(argv)
    command_return = call_command_without_audit(argv)
    @last_command = argv
    command_return
  end

  private

    def record_effect(argv)
      @last_effect = (!NO_EFFECT_COMMANDS.include? argv[0].to_s) ? effect_for(argv) : :none
    end

    def effect_for(argv)
      DESTRUCTIVE_COMMANDS.include?(argv[0].to_s) ? :destroy : effect_for_non_destructive_command(argv[1])       
    end

    def effect_for_non_destructive_command(key)
      call_command_without_audit(['exists', key]) ? :update : :create
    end

end
