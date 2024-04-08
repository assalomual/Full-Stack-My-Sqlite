require 'csv'

class MySqliteRequest
  def initialize
    @table_name = nil
    @select_columns = []
    @where_conditions = []
    @join_table = nil
    @order_column = nil
    @order_direction = nil
    @insert_table = nil
    @insert_values = nil
    @update_table = nil
    @update_data = nil
    @delete_table = nil
  end

  def from(table_name)
    @table_name = table_name
    self
  end

  def select(columns)
    @select_columns = Array(columns)
    self
  end

  def where(column_name, criteria)
    @where_conditions << { column: column_name, criteria: criteria }
    self
  end

  def join(table_name, column_on_db_a, column_on_db_b)
    @join_table = { table_name: table_name, column_on_db_a: column_on_db_a, column_on_db_b: column_on_db_b }
    self
  end

  def order(order_direction, column_name)
    @order_direction = order_direction
    @order_column = column_name
    self
  end

  def insert_into(table_name)
    @insert_table = table_name
    self
  end

  def values(data)
    @insert_values = data
    self
  end

  def update(table_name)
    @update_table = table_name
    self
  end

  def set(data)
    @update_data = data
    self
  end

  def delete_from(table_name)
    @delete_table = table_name
    self
  end

  def run
    if @table_name.nil?
      raise ArgumentError, "Table name must be specified."
    elsif @select_columns.empty?
      raise ArgumentError, "At least one column must be specified for SELECT query."
    end

    if @insert_table.nil? && @update_table.nil? && @delete_table.nil?
      select_data
    elsif !@insert_table.nil?
      insert_data
    elsif !@update_table.nil?
      update_data
    elsif !@delete_table.nil?
      delete_data
    end
  end

  private

  def select_data
    data = []

    CSV.foreach(@table_name, headers: true) do |row|
      row_hash = row.to_h
      if @where_conditions.all? { |condition| row_hash[condition[:column]] == condition[:criteria] }
        data << @select_columns.map { |col| [col, row_hash[col]] }.to_h
      end
    end

    data.sort_by! { |row| row[@order_column] } if @order_column
    data.reverse! if @order_direction == :desc

    data
  end

  def insert_data
    CSV.open(@insert_table, 'a') do |csv|
      csv << @insert_values.values
    end
    "Row inserted successfully."
  end

  def update_data
    updated_rows = 0
    CSV.open(@update_table, 'r+') do |csv|
      headers = csv.readline
      updated_rows += csv.count do |row|
        if @where_conditions.all? { |condition| row[condition[:column]] == condition[:criteria] }
          @update_data.each { |key, value| row[key] = value }
          true
        else
          false
        end
      end
      csv.rewind
      csv.puts headers
    end
    "#{updated_rows} rows updated successfully."
  end

  def delete_data
    deleted_rows = 0
    CSV.open(@delete_table, 'r+') do |csv|
      headers = csv.readline
      deleted_rows += csv.count do |row|
        if @where_conditions.all? { |condition| row[condition[:column]] == condition[:criteria] }
          csv.delete(row)
          true
        else
          false
        end
      end
      csv.rewind
      csv.puts headers
    end
    "#{deleted_rows} rows deleted successfully."
  end
end
