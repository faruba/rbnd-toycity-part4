class Module
  def create_finder_methods(*attributes)
    # Your code goes here!
    # Hint: Remember attr_reader and class_eval
    attributes.each_with_index {|attr_name,idx|
    #Udacidata.define_singleton_method("find_by_#{attr}".to_sym) { |value, is_as_arry = false|

      str = "def self.find_by_#{attr_name}(value, is_as_arry = false)
        csv_helper { |csv|
          ret = create_by_data(csv.read.select{ |data| data[#{idx}] ==  value.to_s })
          if ret.length == 1 && !is_as_arry
            ret = ret[0]
          end
          ret
        }
      end"
      Udacidata.class_eval(str)
    }
  end
end
