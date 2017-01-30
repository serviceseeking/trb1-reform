require "trb1-uber/inheritable_attr"

module Trb1
  module Reform
    # Define your form structure and its validations. Instantiate it with a model,
    # and then +validate+ this object graph.
    class Contract < Trb1::Disposable::Twin
      require "trb1-disposable/twin/composition" # Expose.
      include Expose

      feature Setup
      feature Setup::SkipSetter
      feature Default

      def self.default_nested_class
        Contract
      end

      def self.property(name, options={}, &block)
        if twin = options.delete(:form)
          options[:twin] = twin
        end

        if validates_options = options[:validates]
          validates name, validates_options
        end

        super
      end

      # FIXME: test me.
      def self.properties(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args.each { |name| property(name, options.dup) }
      end

      require "trb1-reform/contract/errors"
      require 'trb1-reform/contract/validate'
      include Trb1::Reform::Contract::Validate

      require "trb1-reform/validation"
      include Trb1::Reform::Validation # ::validates and #valid?

      # FIXME: this is only for #to_nested_hash, #sync shouldn't be part of Contract.
      require "trb1-disposable/twin/sync"
      include Trb1::Disposable::Twin::Sync



      # module ValidatesWarning
      #   def validates(*)
      #     raise "[Reform] Please include either Reform::Form::ActiveModel::Validations or Reform::Form::Lotus in your form class."
      #   end
      # end
      # extend ValidatesWarning

    private
      # DISCUSS: separate file?
      module Readonly
        def readonly?(name)
          options_for(name)[:writeable] == false
        end
        def options_for(name)
         self.class.options_for(name)
        end
      end

      def self.options_for(name)
        definitions.get(name)
      end
      include Readonly


      def self.clone # TODO: test. THIS IS ONLY FOR Trailblazer when contract gets cloned in suboperation.
        Class.new(self)
      end
    end
  end
end
