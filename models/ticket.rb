require('pg')
require_relative('../db/sql_runner.rb')


class Ticket

  attr_reader :id, :film_id, :customer_id

  def initialize(input)
    @id = input['id'].to_i if input['id']
    @film_id = input['film_id']
    @customer_id = input['customer_id']
    @screening_id = input['screening_id']
  end

  def save
    sql = "INSERT INTO tickets(film_id, customer_id, screening_id)
    VALUES($1, $2, $3)
    RETURNING *"
    values = [@film_id, @customer_id, @screening_id]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def self.find_all
    sql = "SELECT * FROM tickets"
    result = SqlRunner.run(sql)
    return result.map { |ticket| Ticket.new(ticket) }
  end

  def update
    sql = "UPDATE tickets
    SET (film_id, customer_id) = ($1, $2, $3)
    WHERE id = $4"
    values = [@film_id, @customer_id, @screening_id, @id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = "DELETE FROM tickets"
    SqlRunner.run(sql)
  end


end
