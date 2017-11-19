require('pg')

class Screening
  attr_reader :id

  def initialize(input)
    @id = input['id'].to_i if input['id']
    @film_id = input['film_id']
    @start_time = input['start_time']
    @empty_seats = input['empty_seats']
  end

  def save
    sql = "INSERT INTO screenings(film_id, start_time, empty_seats)
    VALUES ($1, $2, $3)
    RETURNING *"
    values = [@film_id, @start_time, @empty_seats]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def update
    sql = "UPDATE screenings
    SET (start_time, empty_seats) = ($1, $2)
    WHERE id = $3"
    values = [@start_time, @empty_seats, @id]
    SqlRunner.run(sql, values)
  end

  def find_film
    sql = "SELECT * FROM films
    WHERE id = $1"
    values = [@film_id]
    result = SqlRunner.run(sql, values)
    return Film.new(result[0])
  end

  def seat_validation(number_tickets)
    return false if number_tickets.to_i == 0
    return false if number_tickets.to_i > @empty_seats
    @empty_seats -= number_tickets.to_i
  end

  def self.most_popular
    sql = "SELECT COUNT(*), f.title, s.start_time FROM tickets t
    INNER JOIN films f
    ON f.id = t.film_id
    INNER JOIN screenings s
    ON s.id = t.screening_id
    GROUP BY f.title, s.start_time
    ORDER BY COUNT(*) DESC"
    result = SqlRunner.run(sql)
    return result.values[0]
  end

end
