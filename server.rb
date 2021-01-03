require 'socket'
require 'byebug'

class MyRedis

  # COMMAND = [
  #   :get,
  #   :set
  # ]

  COMMAND = [
    :get,
    :set
  ]
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
    command = input.split.first

    if COMMAND.include? command
      if command == "get"
        handle_get(input)
      elsif command == "set"
        handle_set(input)
      end
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
