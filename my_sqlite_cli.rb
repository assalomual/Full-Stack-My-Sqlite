require_relative 'my_sqlite_request'

class MySqliteCLI
  def initialize(database)
    @database = database
    @request = nil
  end

  def start
    puts "MySQLite version 0.1 #{Time.now.strftime('%Y-%m-%d')}"
    loop do
      print "my_sqlite_cli>"
      input = gets.chomp
      break if input.downcase == 'quit'

      execute_command(input)
    end
  end

  private

  def execute_command(input)
    command, *args = input.split(' ')
    case command.downcase
    when 'select'
      execute_select(args)
    when 'insert'
      execute_insert(args)
    when 'update'
      execute_update(args)
    when 'delete'
      execute_delete(args)
    else
      puts "Invalid command: #{command}"
    end
  end

  def execute_select(args)
    table_name = args[1]
    @request = MySqliteRequest.new
    result = @request.from(table_name).select('*').run
    display_result(result)
  end

  def execute_insert(args)
    table_name = args[2]
    values = args[4..-1].join(' ').split(',').map(&:strip)
    data = {}
    values.each_with_index do |value, index|
      data[index] = value
    end
    @request = MySqliteRequest.new.insert_into(table_name).values(data)
    result = @request.run
    puts result
  end

  def execute_update(args)
    table_name = args[1]
    column_values = args[3..-1].join(' ').split(',')
    data = {}
    column_values.each do |cv|
      column, value = cv.split('=').map(&:strip)
      data[column] = value
    end
    @request = MySqliteRequest.new.update(table_name).set(data)
    result = @request.run
    puts result
  end

  def execute_delete(args)
    table_name = args[2]
    @request = MySqliteRequest.new.delete_from(table_name)
    result = @request.where(args[3], args[4]).run
    puts result
  end

  def display_result(result)
    result.each do |row|
      puts row.values.join('|')
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  database = ARGV[0]
  cli = MySqliteCLI.new(database)
  cli.start
end
