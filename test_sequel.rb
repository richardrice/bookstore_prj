require 'sequel'
require 'sqlite3'

# Connect to database
DB = Sequel.sqlite('bookShop.sqlite' )
# Select all records from the 'books' table
bks = DB[:books]
bks.count
# Select books with 'Dave Thomas' as the author
bks = DB[:books].where({:author => 'Dave Thomas'})
bks.class
    bks.each do |d|
    puts d.class
        puts d
    end