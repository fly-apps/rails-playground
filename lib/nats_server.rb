class NatsServer


def self.start!
  @process = ChildProcess.build("nats-server")
  @process.io.inherit!
  @process.start
  @process.wait
end

end
