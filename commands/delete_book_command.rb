require_relative 'user_command'

class DeleteBookCommand < UserCommand
    
    
    def initialize(data_source)
        super (data_source)
        @isbn = ''
    end
    
    def title
        'Delete a book'
    end
    
    def input
        puts 'Delete a book.'
        print "ISBN? "
        @isbn = STDIN.gets.chomp
    end
    
    def execute
        @data_source.deleteBook(@isbn)
    end	
    
end