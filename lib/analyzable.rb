module Analyzable
  # Your code goes here!
  def print_report(products)
    products.reduce(""){ |result ,product| result + product.to_s }
  end
  def average_price(products)
    ("%02f" % (products.reduce(0) {|sum ,product| sum + product.price} / products.length)).to_f
  end
  def count_by_brand(products)
    products.reduce
  end
  ["brand", "name"].each{ |attr|
    define_method("count_by_#{attr}".to_sym) { |products|
      ret = {}
      if(products.length >0)
        attr_value = products[0].instance_variable_get("@#{attr}")
        ret[attr_value] =  products.length
      end
      ret
    }
  }
end
