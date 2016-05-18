require_relative 'find_by'
require_relative 'errors'
require 'csv'
class Udacidata

  @@header = ["id", "brand", "product", "price"]
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"
  # I read the introduction and testsuit many times, but I can't understand, althought the project is easy.
  #As you mentioned in Toy City 4 Prep ->features . maybe there are some subclasses ,such as Customer, Transation .
  # Why does Udacidata have to create object? Udacidata don't konw anything about subclass except virtual/override function
  # all of the subclass save to data.cvs? If so, I should save class type info to make sure unserialize correctly
  # all of the function of Udacidata is class method? I guess you want me to implement them using CSV. So it's true
  # that all the data save to data.cvs.
  # Maybe this will be better
  #Udacidata is a db layer,so some job like  where to save/
  #select /update /query /delete data /auto_inc_id should belong to Udacidata.
  # The initialize of Udacidata should take a filepath as parameter.
  # get_last_id is a function of Udacidata and should return Int value and @@count_class_instances should be priate to subclass
  # Udacidata support save function, and subclass call this function when we create an object. and
  # udacidata decide to save or not 
  # only create is class method, ADUQ(Add/Delete/Update/Query) depand on @data_path

  
  # Your code goes here!
  #def initalized(path)
  #  @data_path = File.dirname(__FILE__) + "/" + path
  #end

  
  def self.create(opts={})
    product = Product.new(opts)
    if opts[:id] == nil
      Udacidata.csv_helper("a+b") { |csv|
        csv << product.to_a
      }
    end
    return product
  end

  def self.all
    result = []
    Udacidata.csv_helper { |csv|
      csv.each{|data|
        if(data[0] != "id")
        #if(!csv.header_row?)
          result << create_by_data(data)
        end
      }
    }
    return result
  end
  #  I don't know why it's not work.
  #  all I got was :undefined method `first' for Product:Class
  #["first","last"].each{ |sym|
  #  self.class_eval(%Q{
  #    def self.#{name} (param = 0)
  #      Udacidata.csv_helper("r") { |csv|
  #        create_by_data(csv.read.send(sym,param+1))
  #      }
  #    end
  #  } % {name:sym})
  #}

  def self.first(n = nil)
    len = (n == nil ? 1 : n)
    get_range(1,len, n != nil)
  end
  def self.last(n = nil)
    len = (n == nil ? 1 : n)
    get_range(-len,len, n != nil)
  end

  #I don't like this. Is there a better way?
  def self.destroy(id)
    Udacidata.csv_updater {|table|
      result = nil
      table = table.delete_if{ |row| 
        is_eql = row[:id] == id
        if(is_eql)
          result = Product.new(row)
        end
        is_eql
      }
# how to Multiple Assignment ? 
# `table , result`
# will return an array
      [ table, result]
    }
  end
  def update(opts)
    csv_data = onchange(opts)
    new_row = CSV::Row.new(["id", "brand", "product", "price"], csv_data)
    Udacidata.csv_updater {|table|
      table = table.map{|row| 
      row[:id] == csv_data[0] ? new_row : row }
      [table, self]
    }
  end
  def self.find(id) 
    Udacidata.find_by_id(id)
  end
  Module::create_finder_methods("id", "brand", "name", "price")
  #["id", "brand", "name", "price"].each_with_index {|attr,idx|
  #  Udacidata.define_singleton_method("find_by_#{attr}".to_sym) { |value, is_as_arry = false|
  #    Udacidata.csv_helper { |csv|
  #      ret = create_by_data(csv.read.select{ |data| data[idx] ==  value.to_s })
  #      if ret.length == 1 && !is_as_arry
  #        ret = ret[0]
  #      end
  #      ret
  #    }
  #  }
  #}

  def self.where(opts)
    self.send("find_by_#{opts.keys[0]}".to_sym, opts.values[0], true)
  end

private
  def self.create_by_data(datas)
    if(datas[0].instance_of?(Array))
      datas.map{|data|
        create_by_data(data)
      }
    else
      if(datas.length > 0)
        Product.new(id:datas[0], brand:datas[1], name:datas[2], price:datas[3])
      else
        []
      end
    end
  end
  def self.csv_helper(mode = 'r', &block)
    CSV.open(@@data_path, mode) do |csv|
      block.call(csv)
    end
  end

  #it's really ugly. is there a better way?
  #CSV::Table/Row delete doesn't change the file
  def self.csv_updater(&block)
    (table, result) = block.call(CSV.table(@@data_path))

    CSV.open(@@data_path, "wb") do |csv|
      csv << @@header
      table.each{ |row| csv << row }
    end
    return result
  end

  # I think cvs.read is really not a good idea.
  # if dataset is big, we will get a big array.
  # csv.each is better, but bad in last(n)
  # maybe pos=() is the best .I have to count '\n" to get the right postion of row
  # X^X,so let's just move on ,OK?
  def self.get_range(start, length, is_return_array)
    ret = nil
    Udacidata.csv_helper { |csv|
      ret = create_by_data(csv.read[start,length])
    }
    if !is_return_array
      ret = ret[0]
    end
    ret
  end

end
