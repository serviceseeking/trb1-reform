module Trb1::Reform::Form::Mongoid
  def self.included(base)
    base.class_eval do
      register_feature Trb1::Reform::Form::Mongoid
      include Trb1::Reform::Form::ActiveModel
      include Trb1::Reform::Form::ORM
      extend ClassMethods
    end
  end

  module ClassMethods
    def validates_uniqueness_of(attribute, options={})
      options = options.merge(:attributes => [attribute])
      validates_with(UniquenessValidator, options)
    end
    def i18n_scope
      :mongoid
    end
  end


  def self.mongoid_namespace
    if mongoid_is_4_or_more?
      'Validatable'
    else
      'Validations'
    end
  end

  def self.mongoid_is_4_or_more?
    Mongoid::VERSION.split('.').first.to_i >= 4
  end

  UniquenessValidator = Class.new("::Mongoid::#{mongoid_namespace}::UniquenessValidator".constantize) do
    include Trb1::Reform::Form::ORM::UniquenessValidator
  end
end
