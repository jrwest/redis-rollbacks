module Redis::Audit
  def self.included(base)
    base.send(:attr_reader, :last_command)
    base.send(:alias_method, :call_command_without_audit, :call_command)
    base.send(:alias_method, :call_command, :call_command_with_audit)
  end
  
  def serialize_command(argv)
    argv.join(' ')
  end

  def call_command_with_audit(argv)
    call_command_without_audit(argv)
    @last_command = argv
  end
end
