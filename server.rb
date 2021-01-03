require 'socket'
require 'byebug'

class MyRedis
  def initialize
    @socket = TCPServer.new 2000
    @data = {}
    @clients = []
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

        if input == :wait_readable
          next
        else
          client.puts handle_command(input)
        end
      end
    end
  end

  def handle_command(input)
    commands = input.split
    if commands[0] == "get"
      @data[commands[1]]
    elsif commands[0] == "set"
      @data[commands[1]] = commands[2]
      "OK"
    end
  end
end

MyRedis.new
