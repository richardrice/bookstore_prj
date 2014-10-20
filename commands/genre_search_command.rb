require_relative 'user_command'

class GenreSearchCommand < UserCommand

	def initialize (data_source)
		super (data_source)
		@genre = ''
	end

	def title 
		'Search by genre.'
	end

   def input
   	   puts 'Search by Genre.'
	   print "Genre? "   
	   @author = STDIN.gets.chomp  
   end

    def execute
       @data_source.genreSearch(@genre).each {|b| puts b }
	end

end