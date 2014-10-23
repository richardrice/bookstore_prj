require_relative 'book_in_stock'
require_relative 'database'
require 'dalli'


class DataAccess
    
    def initialize db_path
        @database = DataBase.new db_path
        @Remote_cache = Dalli::Client.new('localhost:11211')
        @Local_cache = Hash.new
    end
    
    def start
        @database.start
    end
    
    def stop
    end
    
    def addBook book
        @database.addBook book
    end
    
    def deleteBook isbn
        version = @Remote_cache.get "v_#{isbn}"
        if version
            @Remote_cache.delete "v_#{isbn}"
            @Remote_cache.delete "#{version}_#{isbn}"
            if @Local_cache["v_#{isbn}"]
                
                counter = @Local_cache["v_#{isbn}"]
                @Local_cache.delete("v_#{isbn}")
                while counter >= 1 do
                    @Local_cache.delete("#{counter}_#{isbn}")
                    counter = counter - 1
                end
                end
            end
            
            @database.deleteBook isbn
        end
        
        
        
        def findISBN  isbn
            version = @Remote_cache.get "v_#{isbn}"
            if @Local_cache["v_#{isbn}"]
                localVersion = @Local_cache["v_#{isbn}"]
                if localVersion == version
                    getFromLocalCache(isbn,version)
                    else
                    book = getFromRemoteCache(isbn,version)
                    addToLocalCache(book,version)
                end
                elsif   version
                book = getFromRemoteCache(isbn,version)
                addToLocalCache(book,version)
                
                else
                book = @database.findISBN isbn
                if book
                    addToRemoteCache book
                    addToLocalCache(book,version)
                end
            end
        end
        
        
        def authorSearch author
            books = @database.authorSearch author
            if ! @Remote_cache.get"bks_#{author}"
                
                if   books.count >=2
                    buildComplexData(author,books)
                    else
                    books
                end
                
                elsif @Remote_cache.get"bks_#{author}"
                isbns = @Remote_cache.get"bks_#{author}"
                isbns = isbns.split(',')
                bookIsbns = Array.new()
                books.each{|book| bookIsbns.push(book.isbn)}
                if isbns.sort == bookIsbns.sort
                    authorKey = buildAuthorKey author
                    if ! @Remote_cache.get "#{authorKey}"
                        puts "Data is stale - rebuild complex data"
                        buildComplexData(author,books)
                        
                        else
                        puts "Returning complex data from remote cache"
                        complexData =  @Remote_cache.get "#{authorKey}"
                    end
                    else
                    buildComplexData(author,books)
                end
                
                else
                books
                
            end
        end
        
        def updateBook book
            @database.updateBook book
            current_version = @Remote_cache.get "v_#{book.isbn}"
            if current_version
                @Remote_cache.set "v_#{book.isbn}" , current_version + 1
                @Remote_cache.set "#{current_version + 1}_#{book.isbn}", book.to_cache
                addToLocalCache(book, current_version+1)
                puts "Book Updated"
                else
                addToRemoteCache book
                addToLocalCache book
            end
            
            
        end
        
        def addToRemoteCache book
            @Remote_cache.set "v_#{book.isbn}", 1      # Create the version entry
            @Remote_cache.set "1_#{book.isbn}", book.to_cache
        end
        
        
        def addToLocalCache(book,version = 1)
            @Local_cache["v_#{book.isbn}"] = version
            @Local_cache["#{version}_#{book.isbn}"] = book.to_cache
            puts 'Modify local cache'
            book
        end
        
        
        def getFromRemoteCache(isbn,version)
            serial = @Remote_cache.get "#{version}_#{isbn}"
            book = BookInStock.from_cache serial
            puts "Pulled from remote cache version = " + "#{version}"
            book
            
        end
        
        def getFromLocalCache(isbn,version)
            serial = @Local_cache ["#{version}_#{isbn}"]
            book = BookInStock.from_cache serial
            puts "Pulled from local cache version = " + "#{version}"
            book
            
        end
        
        def buildAuthorKey author
            authorKey = "#{author}"
            authorsISBN = @Remote_cache.get"bks_#{author}"
            authorsISBN = authorsISBN.split(",")
            authorsISBN.each do |isbn|
                isbn_version = @Remote_cache.get "v_#{isbn}"
                authorKey += "_#{isbn}_#{isbn_version}"
            end
            authorKey
            
            
        end  
        
        def buildComplexData(author,books)
            concatIsbn = ""
            complexData = ""
            
            books.each do |book|
                addToRemoteCache(book)
                complexData += book.to_cache + "--"
                concatIsbn += "#{book.isbn}"+ ","
                
            end
            
            @Remote_cache.set"bks_#{author}" , concatIsbn
            authorKey = buildAuthorKey author
            @Remote_cache.set"#{authorKey}" , complexData
            puts "Returning complex data from remote cache"
            complexData =  @Remote_cache.get "#{authorKey}"
            
        end  
        
        
    end