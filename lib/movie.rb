require 'support/number_helper'
class Movie
  include NumberHelper
	@@filepath = nil

	def self.filepath=(path=nil)
		@@filepath = File.join(APP_ROOT, path)
  end

  attr_accessor :name, :genre, :price

	def self.file_exists?
		# class should know if the movie file is exitss
		if @@filepath && File.exists?(@@filepath)
		  return true
		else
		  return false
		end
  end

  def self.file_usable?
    return false unless @@filepath
    return false unless File.exists?(@@filepath)
    return false unless File.readable?(@@filepath)
    return false unless File.writable?(@@filepath)
    return true
  end

	def self.create_file
		# create the movie file
    File.open(@@filepath, 'w') unless file_exists?
    return file_usable?
	end

	def self.saved_movies
		# read the movie file
		# return instance of the movie
    movies = []
    if file_usable?
      file = File.new(@@filepath, 'r')
      file.each_line do |line|
        movies << Movie.new.import_line(line.chomp)
      end
      file.close
    end
    return movies
  end

  def self.build_using_questions
    args = {}
    print "Movie name: "
    args[:name] = gets.chomp.strip

    print "Genre type: "
    args[:genre] = gets.chomp.strip

    print "Average price: "
    args[:price] = gets.chomp.strip

    return self.new(args)
  end

  def initialize(args={})
    @name  = args[:name]   || ""
    @genre = args[:genre]  || ""
    @price = args[:price]  || ""
  end

  def import_line(line)
    line_array = line.split("\t")
    @name, @genre, @price = line_array
    return self
  end

  def save
    return false unless Movie.file_usable?
    File.open(@@filepath, 'a') do |file|
      file.puts "#{[@name, @genre, @price].join("\t")}\n"
    end
    return true
  end

  def formatted_price
    number_to_currency(@price)
  end
end