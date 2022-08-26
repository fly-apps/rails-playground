require 'socket'
require 'surro-gate'

class Hijacker
  def initialize(app)
    puts "hijacker"
    @app = app
    @proxy = SurroGate.new

    @transmitter = Thread.new do
      loop do
        @proxy.select(1000)

        @proxy.each_ready do |left, right|
          begin
            right.write_nonblock(left.read_nonblock(4096))
          rescue => ex
            puts "Connection #{left} <-> #{right} closed due to #{ex}"
            cleanup(left, right)
          end
        end
      end
    end

    @transmitter.abort_on_exception = true
  end

  def call(env)
    if env['HTTP_UPGRADE'] != "websocket"
      status, headers, response = @app.call(env)
      return [status, headers, response]
    end

    host = "localhost"
    port = 12345

    http = env['rack.hijack'].call
    http ||= env["rack.hijack_io"]

    puts "writing http response"
    # Write a proper HTTP response
    http.write_nonblock(http_response)

    puts "writing http response"

    # Open the remote TCP socket
    sock = TCPSocket.new(host, port)

    puts "Start proxying"
    # Start proxying
    @proxy.push(http, sock)

    puts "Redirecting incoming request from #{env['REMOTE_ADDR']} to [#{host}]:#{port}"

    # Rack requires this line below
    # return [200, {}, []]
  # rescue => ex
  #   puts "#{ex.class} happened for #{env['REMOTE_ADDR']} trying to access #{host}:#{port}"
  #   cleanup(http, sock)
  #   return not_found # Return with a 404 error
  end

  private

  def http_response
    <<~HEREDOC.sub(/\n$/, "\n\n").gsub(/ {2,}/, '').gsub("\n", "\r\n")
    HTTP/1.1 101 Switching Protocols
    Connection: Upgrade
    Sec-WebSocket-Protocol: actioncable-v1-json
    Upgrade: websocket
    HEREDOC
  end

  def not_found
    [404, { 'Content-Type' => 'text/plain' }, ['Not found!']]
  end

  def cleanup(*sockets)
    # Omit `nil`s from the array
    sockets.compact!
    # Close the opened sockets and remove them from the proxy
    sockets.each { |sock| sock.close unless sock.closed? }
    @proxy.pop(*sockets) if sockets.length > 1
  end
end
