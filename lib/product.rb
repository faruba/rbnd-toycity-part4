require_relative 'udacidata'

class Product < Udacidata
  attr_reader :id, :price, :brand, :name
  @@products = []
  def initialize(opts={})

     # class 

    # Get last ID from the database if ID exists
    get_last_id
    # Set the ID if it was passed in, otherwise use last existing ID
    @id = opts[:id] ? opts[:id].to_i : @@count_class_instances
    # Increment ID by 1
    auto_increment if !opts[:id]
    # Set the brand, name, and price normally
    init_attr(opts)
    end

  def to_a
    [@id, @brand, @name, @price]
  end
  def onchange(opts)
    init_attr(opts)
    to_a
  end
  def to_s
    "Product:<id:#{@id}, brand:#{@brand}, name:#{name}, price:#{price}\n"
  end
private

  def init_attr(opts)
    @brand = opts[:brand]      if opts[:brand]
    @name  = opts[:name]       if opts[:name]
    @price = opts[:price].to_f if opts[:price]
  end
  # Reads the last line of the data file, and gets the id if one exists
  # If it exists, increment and use this value
  # Otherwise, use 0 as starting ID number
  def get_last_id
    file = File.dirname(__FILE__) + "/../data/data.csv"
    last_id = File.exist?(file) ? CSV.read(file).last[0].to_i + 1 : nil
    @@count_class_instances = last_id || 0
  end

  def auto_increment
    @@count_class_instances += 1
  end

end
