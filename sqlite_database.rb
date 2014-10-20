require 'sequel'
require 'sqlite3'
require 'logger'
require_relative 'book_in_stock'

  class SQLiteDataBase 

  def initialize (data_base)
      @data_base = data_base
      @DB = nil
   end

  def start 
       @DB = Sequel.sqlite(@data_base ) 
     @DB.loggers << Logger.new($stdout)
  end

  def stop
  end

  def findISBN isbn
     dataset = @DB[:books].where(:isbn => isbn)
     objects = object_relational_mapper dataset
     objects[0]
  end

  def authorSearch(author)
        dataset = @DB[:books].where(:author => author)
      object_relational_mapper dataset
  end
  
  def genreSearch(genre)
      dataset = @DB[:genre].where(:genre => genre)
      object_relational_mapper dataset
  end
private
  def object_relational_mapper dataset
    books = []
    dataset.each do |d|
      books << BookInStock.new(d[:isbn], d[:title],
                               d[:author],d[:genre],
                               d[:price], d[:quantity])
    end
    books
  end

end 