class Movie < ActiveRecord::Base
  def self.ratings
    %w(G PG PG-13 R)
  end
end
