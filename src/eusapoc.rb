#!/usr/bin/env ruby

require 'json'
require 'httparty'
require 'kafka'

@name = "eusapoc"
@time = ENV['TIME'].nil? ? 10 : ENV['TIME']
device = ENV['DEVICE']
if device.nil?
    puts "Error, DEVICE is mandatory"
    exit 1
end
apikey = ENV['APIKEY']
if apikey.nil?
    puts "Error, APIKEY is mandatory"
    exit 1
end
kafka_broker = ENV['KAFKA_BROKER'].nil? ? "127.0.0.1" : ENV['KAFKA_BROKER']
kafka_port = ENV['KAFKA_PORT'].nil? ? "9092" : ENV['KAFKA_PORT']
@kafka_topic = ENV['KAFKA_TOPIC'].nil? ? "eusapoc" : ENV['KAFKA_TOPIC']
kclient = Kafka.new(seed_brokers: ["#{kafka_broker}:#{kafka_port}"], client_id: "gijonbus2k")
url = "https://api.meraki.com/api/v0/devices/#{device}/clients?timespan=#{time}"

def w2k(url,apikey,kclient)
    lastdigest = ""
    headers = { "X-Cisco-Meraki-API-Key" => apikey }
    puts "[#{@name}] Starting eusapoc thread"
    while true
        begin
            puts "[#{@name}] Connecting to #{url}" unless ENV['DEBUG'].nil?
            response = HTTParty.get(url, headers: headers)
            next if lastdigest == Digest::MD5.hexdigest(response.body)
            eusahash = JSON.parse(response.body)
            timestamp = Time.now.to_i
            eusahash.each do |client|
                client["timestamp"] = timestamp
                #puts "bus asset: #{JSON.pretty_generate(bus)}\n" unless ENV['DEBUG'].nil?
                kclient.deliver_message("#{client.to_json}",topic: @kafka_topic)
            end

            sleep @time
        rescue Exception => e
            puts "Exception: #{e.message}"

        end
    end

end


Signal.trap('INT') { throw :sigint }

catch :sigint do
        t1 = Thread.new{w2k(url,apikey,kclient)}
        t1.join
end

puts "Exiting from eusapoc"

## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:
