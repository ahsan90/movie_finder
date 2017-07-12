require 'movie'
require 'support/string_extend'
class Guide

  class Config
    @@actions = ['list', 'find', 'add', 'quit']
    def self.actions; @@actions; end
  end

  def initialize(path=nil)
    #locate the movie tax file at path
    Movie.filepath = path
    #or create a new file
    if Movie.file_usable?
      puts "Found movie file."
    elsif Movie.create_file
      puts "Created movie file"
    else
      puts "Exiting..."
      exit!
    end
  end

  def launch!
    introduction
    result = nil
    until result == :quit
      action, args = get_atction
      result = do_action(action, args)
    end
    conclusion
  end

  def get_atction
    action = nil
    until Guide::Config.actions.include?(action)
      puts "Actions: " + Guide::Config.actions.join(", ")
      print "> "
      user_response = gets.chomp
      args = user_response.downcase.strip.split(' ')
      action = args.shift
    end
    return action, args
  end

  def do_action(action, args=[])
    case action
      when 'list'
        list(args)
      when 'find'
        keyword = args.shift
        find(keyword)
      when 'add'
        add
      when 'quit'
        return :quit
      else
        puts "\nInvalid command\n"
    end
  end

  def list(args=[])
    sort_order = args.shift
    sort_order = 'name' unless ['name', 'genre', 'price'].include?(sort_order)
    output_action_header("Listing movies")
    movies = Movie.saved_movies

    movies.sort! do |r1, r2|
      case sort_order
        when 'name'
          r1.name.downcase <=> r2.name.downcase
        when 'genre'
          r1.genre.downcase <=> r2.genre.downcase
        when 'price'
          r1.price.to_i <=> r2.price.to_i
      end
    end
    output_movie_table(movies)
    puts "Sort using: 'list genre'\n\n"
  end

  def find(keyword="")
    output_action_header("Find a movies")
    if keyword
      movies = Movie.saved_movies
      found = movies.select do |mov|
        mov.name.downcase.include?(keyword.downcase) ||
        mov.genre.downcase.include?(keyword.downcase) ||
        mov.price.to_i <= keyword.to_i
      end
      output_movie_table(found)
    else
      puts "Find using a key phrase to search the movie list"
      puts "Example: 'find Action' or 'find Romance'\n\n"
    end
  end

  def add
    output_action_header("Add a movies")
    movie = Movie.build_using_questions
    if movie.save
      puts "\nMovie Added\n\n"
    else
      puts "\nSave Error: Movie not added\n\n"
    end
  end

  def introduction
    puts "\n\n<<< Welcome to the Movie Finder >>>\n\n"
    puts "You will find your favourite movies/TV Series here!!!"
  end

  def conclusion
    puts "\n\n<<< Goodbye >>\n\n"
  end

  private
  def output_action_header(text)
    puts "\n#{text.upcase.center(60)}\n\n"
  end

  def output_movie_table(movies=[])
    print " " + "Name".ljust(30)
    print " " + "Genre".ljust(20)
    print " " + "Price".rjust(6) + "\n"
    puts "-" * 60
    movies.each do |mov|
      line = " " << mov.name.titleize.ljust(30)
      line << " " + mov.genre.titleize.ljust(20)
      line << " " + mov.formatted_price.rjust(6)
      puts line
    end
    puts "No listings found" if movies.empty?
    puts "-" * 60
  end
end