require('pg')
require_relative('../db/sql_runner.rb')

class Film

  attr_reader :id, :title, :price

  def initialize(input)
    @id = input['id'].to_i if input['id']
    @title = input['title']
    @price = input['price'].to_f
  end

  def save
    sql = "INSERT INTO films(title, price)
    VALUES ($1, $2)
    RETURNING *"
    values = [@title, @price]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def self.find_all
    sql = "SELECT * FROM films"
    result = SqlRunner.run(sql)
    return result.map { |film| Film.new(film) }
  end

  def update
    sql = "UPDATE films
    SET (title, price) = ($1, $2)
    WHERE id = $3"
    values = [@title, @price, @id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = "DELETE FROM films"
    SqlRunner.run(sql)
  end

  def find_film_customers
    sql = "SELECT c.name FROM films f
    INNER JOIN tickets t
    ON f.id = t.film_id
    INNER JOIN customers c
    ON t.customer_id = c.id
    WHERE f.id = $1"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.map{ |customer| Customer.new(customer) }
  end

  def film_check
    sql = "SELECT COUNT(*), f.title FROM tickets t
    INNER JOIN films f
    ON f.id = t.film_id
    WHERE film_id = $1
    GROUP BY f.title"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.values
  end


end
