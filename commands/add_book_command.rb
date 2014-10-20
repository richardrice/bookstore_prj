require_relative 'user_command'

class AddBookCommand < UserCommand
    
    def initialize (data_source)
        super (data_source)
        @isbn = ''
    end
    
    def title
        'Add Book.'
    end
    
    def input
        puts 'Add Book.'
        print "ISBN? "
        @isbn = STDIN.gets.chomp
    end
    
    def execute
        book = @data_source.findISBN @isbn
        if book
            puts '[Hit <return> key to skip to next field]'
            print "Author (#{book.author}) ?"
            response = STDIN.gets.chomp
            book.author = response if response.length > 0
            print "Title (#{book.title}) ?"
            response = STDIN.gets.chomp
            book.title = response if response.length > 0
            puts "Genre (#{book.genre})."
            $GENRE.each_index {|i| print " (#{i+1}) #{$GENRE[i]} "}
            print ' ? '
            response = STDIN.gets.chomp.to_i
            book.genre = $GENRE[response - 1] if (1..$GENRE.length).member? response
            @data_source.addBook book
            else
            puts 'Invalid ISBN'
        end
    end 
    
end
