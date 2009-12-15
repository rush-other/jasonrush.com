require 'acts_as_inactivatable'

ActiveRecord::Base.class_eval do
  include ActsAsInactivatable
end