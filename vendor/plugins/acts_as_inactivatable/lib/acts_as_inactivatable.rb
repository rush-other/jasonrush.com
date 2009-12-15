#Extends active record to include an active flag instead of
# allowing deletion
module ActsAsInactivatable
  #Provide the acts_as class method
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  #Class Methods
  module ClassMethods
    #Class method to extend active record
    def acts_as_inactivatable
      include ActsAsInactivatable::InstanceMethods
      extend ActsAsInactivatable::SingletonMethods
    end
  end
  
  #Instance Methods
  module InstanceMethods
    #Inactivation
    def inactivate
      self.active = false
    end
  end
  
  module SingletonMethods
    #Return only the active records
    def find_active(options = {})
      if options[:conditions].blank? || options[:conditions] == ""
        #There is no condition yet, add condition for active = 1
        options[:conditions] = table_name + ".active = 1"
      elsif options[:conditions].kind_of? String
        #There is already a condition set up, and it is in the 
        # string format.  Include a conjunctive condition for
        # active = 1
        options[:conditions] = "(" + options[:conditions] + ") and " + table_name + ".active = 1"
      elsif options[:conditions].kind_of? Array
        #There is already a condition set up, and it is in the
        # array format.  Include a conjunction on it for active
        # = ?, then append the value of 1 on the end of the array
        options[:conditions][0] = "(" + options[:conditions][0] + ") and " + table_name + ".active = ?"
        options[:conditions] << 1
      end
      find(:all, options)
    end
  end
end