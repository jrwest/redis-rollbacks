module Redis::Audit
  def serialize_command(argv)
    argv.join(' ')
  end
end
