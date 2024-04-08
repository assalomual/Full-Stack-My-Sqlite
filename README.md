# MySQLite Request
*This library provides a simple interface to interact with SQLite-like databases using CSV files.
# Installation
*To install the library, simply download the `my_sqlite_request.rb` file and place it in your project directory.
# Usage
*Create a `MySqliteRequest` object:
    ```ruby
    request = MySqliteRequest.new
    ```
*Specify the table name using the `from` method:
    ```ruby
    request.from('data.csv')
    ```

*Build your query by chaining method calls:
    - `select`: Specify columns to select.
    - `where`: Apply conditions.
    - `join`: Perform a join operation.
    - `order`: Order the results.
    - `insert_into`: Specify the table for insertion.
    - `values`: Provide data for insertion.
    - `update`: Specify the table for update operation.
    - `set`: Set values for update.
    - `delete_from`: Specify the table for deletion.

*Execute the query using the `run` method:
    ```ruby
    result = request.run
    ```
# Example Usage
```ruby
require 'my_sqlite_request'
# Select query
request = MySqliteRequest.new
result = request.from('data.csv').select('name', 'age').where('age', '>=', 18).run
# Insert query
request = MySqliteRequest.new
result = request.insert_into('data.csv').values({ 'name' => 'John', 'age' => 25 }).run
# Update query
request = MySqliteRequest.new
result = request.update('data.csv').set({ 'age' => 30 }).where('name', 'John').run
# Delete query
request = MySqliteRequest.new
result = request.delete_from('data.csv').where('name', 'John').run
