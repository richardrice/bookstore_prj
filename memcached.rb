require 'dalli'
require_relative './book_in_stock'
# options = { :namespace => "app_v1", :compress => true }
dc = Dalli::Client.new('localhost:11211')
isbn = '1234'
book = nil

version = dc.get "v_#{isbn}"
# Is book 1234 in the cache?
if version        
   serial = dc.get "#{version}_#{isbn}"
   book = BookInStock.from_cache serial
   book.price -= 2.0
   # Increment version and update cacheed book
   dc.set "#{version + 1}_#{book.isbn}", book.to_cache
   dc.set "v_#{book.isbn}",version+1
else   # Not in cache, so add it.
	 book = BookInStock.new '1234', 'Ruby Programming','Dave Thomas',
      'Programming',20.0,10
   dc.set "v_#{book.isbn}",1      # Create the version entry 
   dc.set "1_#{book.isbn}", book.to_cache
end
puts book