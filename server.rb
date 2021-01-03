require 'socket'
require 'byebug'

class MyRedis

  def initialize
    @socket = TCPServer.new 2000
    @data = {}
    @clients = []
    @command_hash = {
      get: -> (e) { handle_get(e) },
      set: -> (e) { handle_set(e) }
    }

    run
  end

  def run
    Thread.new do
      loop do
        @clients << @socket.accept
      end
    end

    loop do
      @clients.each do |client|
        input = client.read_nonblock(1024, exception: false)

        next if input == :wait_readable
        client.puts handle_command(input)
      end
    end
  end

  def handle_command(input)
    command = input.split.first.to_sym

    if @command_hash.include? command
      @command_hash[command].call(input)
    else
      "Wrong command"
    end
  end

  def handle_get(input)
    _, key = input.split
    @data[key]
  end

  def handle_set(input)
    _, key, value = input.split
    @data[key] = value
    "OK"
  end
end

MyRedis.new
