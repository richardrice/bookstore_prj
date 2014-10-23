require_relative 'user_command'

class AddBookCommand < UserCommand
    
    
    def initialize(data_source)
        super (data_source)
        @title  = ''
        @author = ''
        @isbn   = ''
        @genre = ''
        @price = 0
        @quantity = 0
    end
    
    def title
        'Add a book'
    end
    
    def input
        puts 'Add a book.'
        print 'Book title?'
        @title = STDIN.gets.chomp
        print "Author name? "
        @author = STDIN.gets.chomp
        print "ISBN? "
        @isbn = STDIN.gets.chomp
        print 'Genre?'
        $GENRE.each_index {|i| print " (#{i+1}) #{$GENRE[i]} "}
        response = STDIN.gets.chomp.to_i
        @genre = $GENRE[response - 1] if (1..$GENRE.length).member? response
        print 'Price?'
        @price = STDIN.gets.chomp
        print 'Quantity?'
        @quantity = STDIN.gets.chomp
    end
    
    def execute
        book = BookInStock.new(@isbn,@title,@author,@genre,@price,@quantity)
        @data_source.addBook book
        
    end
    
end