require('pg')
require_relative('../db/sql_runner.rb')
require_relative('ticket.rb')

class Customer

  attr_reader :id, :name, :funds

  def initialize(input)
    @id = input['id'].to_i if input['id']
    @name = input['name']
    @funds = input['funds']
  end

  def save
    sql = "INSERT INTO customers(name, funds)
    VALUES ($1, $2)
    RETURNING *"
    values = [@name, @funds]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def self.find_all
    sql = "SELECT * FROM customers"
    result = SqlRunner.run(sql)
    return result.map { |customer| Customer.new(customer) }
  end

  def update
    sql = "UPDATE customers
    SET (name, funds) = ($1, $2)
    WHERE id = $3"
    values = [@name, @funds, @id]
    SqlRunner.run(sql, values)
  end

  def delete
    sql = "DELETE FROM customers
    WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run(sql)
  end

  def find_customer_films
    sql = "SELECT f.title, f.price FROM customers c
    INNER JOIN tickets t
    ON c.id = t.customer_id
    INNER JOIN films f
    ON t.film_id = f.id
    WHERE c.id = $1"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.map{ |film| Film.new(film) }
  end

  def buy_ticket(number_tickets, screening)
    return if screening.seat_validation(number_tickets) == false
    screening.update
    film = screening.find_film
    count = 1
    while (count <= number_tickets.to_i)
      purchase = Ticket.new( {'customer_id' => @id, 'film_id' => film.id, 'screening_id' => screening.id} )
      purchase.save
      count += 1
    end
    @funds -= (number_tickets.to_f * film.price)
  end

  def ticket_check
    sql = "SELECT COUNT(*), c.name FROM tickets t
    INNER JOIN customers c
    ON c.id = t.customer_id
    WHERE customer_id = $1
    GROUP BY c.name"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.values
  end

end
