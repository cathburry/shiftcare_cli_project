require_relative 'client_manager'

class CLI
  def initialize(client_manager)
    @client_manager = client_manager
  end

  def run
    loop do
      display_menu
      handle_option(gets.chomp)
    end
  rescue Interrupt
    puts "\nExiting..."
  end

  private

  def display_menu
    puts "\nShiftCare Client Manager"
    puts "1. Search clients by name"
    puts "2. Find duplicate emails"
    puts "3. Exit"
    print "Choose an option (1-3): "
  end

  def handle_option(choice)
    case choice
    when '1' then handle_search
    when '2' then handle_duplicates
    when '3' then exit
    else puts "Invalid option"
    end
  end

  def handle_search
    print "Enter search query: "
    query = gets.chomp
    results = @client_manager.search_by_name(query)

    if results.empty?
      puts "No clients found matching '#{query}'"
    else
      puts "Found #{results.size} clients:"
      results.each { |client| display_client(client) }
    end
  end

  def handle_duplicates
    duplicates = @client_manager.find_duplicate_emails

    if duplicates.empty?
      puts "No duplicate emails found"
    else
      puts "Found #{duplicates.size} email(s) with duplicates:"
      duplicates.each do |email, clients|
        puts "\nEmail: #{email}"
        clients.each { |client| display_client(client) }
      end
    end
  end

  def display_client(client)
    puts "- #{client['full_name']} (ID: #{client['id']}, Email: #{client['email']})"
  end
end
