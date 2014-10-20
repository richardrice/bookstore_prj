require_relative 'book_in_stock'
require_relative 'database'
require 'dalli'

  class DataAccess 
  
    def initialize db_path
       @database = DataBase.new db_path
       @Remote_cache = Dalli::Client.new('localhost:11211')
       # Relevant data structure(s) for local cache
    end
    
    def start 
    	 @database.start 
    end

    def stop
    end

    def findISBN isbn
       @database.findISBN isbn       
    end

    def authorSearch(author)
       @database.authorSearch author
    end

    def updateBook book
       @database.updateBook book
    end
    def genreSearch(genre)
        @database.genreSearch genre
    end
    def addBook(add)
        @database.addBook add
    end
    def deleteBook(delete)
        @database.deleteBook delete
    end
end 