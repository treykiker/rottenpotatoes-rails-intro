class Movie < ActiveRecord::Base
  def self.all_ratings
    a = Array.new
    self.select("rating").uniq.each {|y| a.push(y.rating)}
    a.sort.uniq
  end
end
