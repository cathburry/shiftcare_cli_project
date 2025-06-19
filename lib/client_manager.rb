require 'json'
require 'open-uri'

class ClientManager
  attr_reader :clients

  def initialize(data)
    @clients = if data.is_a?(String)
                 if data.start_with?('http')
                   JSON.parse(URI.open(data).read)
                 elsif File.exist?(data)
                   JSON.parse(File.read(data))
                 else
                   raise ArgumentError, "Invalid data source: #{data}"
                 end
               else
                 data
               end
  rescue => e
    puts "Warning: #{e.message}"
    @clients = []
  end

  def search_by_name(query)
    return [] if query.to_s.strip.empty?

    normalized_query = query.downcase.strip
    @clients.select do |client|
      client['full_name'].to_s.downcase.include?(normalized_query)
    end
  end

  def find_duplicate_emails
    email_groups = @clients.each_with_object(Hash.new { |h, k| h[k] = [] }) do |client, hash|
      email = client['email'].to_s.downcase.strip
      hash[email] << client unless email.empty?
    end

    email_groups.select { |_, clients| clients.size > 1 }
  end

  private

  def load_data(source)
    if source.start_with?('http')
      JSON.parse(URI.open(source).read)
    elsif File.exist?(source)
      JSON.parse(File.read(source))
    else
      raise ArgumentError, "Invalid data source: #{source}"
    end
  end
end
