module Trb1
  module Reform
    class Form < Contract
      def self.default_nested_class
        Form
      end

      require "trb1-reform/form/validate"
      include Validate # override Contract#validate with additional behaviour.

      require "trb1-reform/form/populator"

      # called after populator: form.deserialize(params)
      # as this only included in the typed pipeline, it's not applied for scalars.
      Deserialize = ->(input, options) { input.deserialize(options[:fragment]) } # TODO: (result:, fragment:, **o) once we drop 2.0.

      module Property
        # Add macro logic, e.g. for :populator.
        def property(name, options={}, &block)
          definition = super # let representable sort out inheriting of properties, and so on.
          definition.merge!(deserializer: {}) unless definition[:deserializer] # always keep :deserializer per property.

          deserializer_options = definition[:deserializer]

          # Populators
          internal_populator = Populator::Sync.new(nil)
          if block = definition[:populate_if_empty]
            internal_populator = Populator::IfEmpty.new(block)
          end
          if block = definition[:populator] # populator wins over populate_if_empty when :inherit
            internal_populator = Populator.new(block)
          end
          definition.merge!(internal_populator: internal_populator) unless options[:internal_populator]
          external_populator = Populator::External.new

          # always compute a parse_pipeline for each property of the deserializer and inject it via :parse_pipeline.
          # first, let representable compute the pipeline functions by invoking #parse_functions.
          if definition[:nested]
            parse_pipeline = ->(input, options) do
              functions = options[:binding].send(:parse_functions)
              pipeline  = Trb1::Representable::Pipeline[*functions] # Pipeline[StopOnExcluded, AssignName, ReadFragment, StopOnNotFound, OverwriteOnNil, Collect[#<Trb1::Representable::Function::CreateObject:0xa6148ec>, #<Trb1::Representable::Function::Decorate:0xa6148b0>, Deserialize], Set]

              pipeline  = Trb1::Representable::Pipeline::Insert.(pipeline, external_populator,            replace: Trb1::Representable::CreateObject::Instance)
              pipeline  = Trb1::Representable::Pipeline::Insert.(pipeline, Trb1::Representable::Decorate,       delete: true)
              pipeline  = Trb1::Representable::Pipeline::Insert.(pipeline, Deserialize,                   replace: Trb1::Representable::Deserialize)
              pipeline  = Trb1::Representable::Pipeline::Insert.(pipeline, Trb1::Representable::SetValue,       delete: true) # FIXME: only diff to options without :populator
            end
          else
            parse_pipeline = ->(input, options) do
              functions = options[:binding].send(:parse_functions)
              pipeline  = Trb1::Representable::Pipeline[*functions] # Pipeline[StopOnExcluded, AssignName, ReadFragment, StopOnNotFound, OverwriteOnNil, Collect[#<Trb1::Representable::Function::CreateObject:0xa6148ec>, #<Trb1::Representable::Function::Decorate:0xa6148b0>, Deserialize], Set]

              # FIXME: this won't work with property :name, inherit: true (where there is a populator set already).
              pipeline  = Trb1::Representable::Pipeline::Insert.(pipeline, external_populator,            replace: Trb1::Representable::SetValue) if definition[:populator] # FIXME: only diff to options without :populator
              pipeline
            end
          end

          deserializer_options[:parse_pipeline] ||= parse_pipeline

          if proc = definition[:skip_if]
            proc = Trb1::Reform::Form::Validate::Skip::AllBlank.new if proc == :all_blank
            deserializer_options.merge!(skip_parse: proc) # TODO: same with skip_parse ==> External
          end


          # per default, everything should be writeable for the deserializer (we're only writing on the form). however, allow turning it off.
          deserializer_options.merge!(writeable: true) unless deserializer_options.has_key?(:writeable)

          definition
        end
      end
      extend Property

      require "trb1-disposable/twin/changed"
      feature Trb1::Disposable::Twin::Changed

      require "trb1-disposable/twin/sync"
      feature Trb1::Disposable::Twin::Sync
      feature Trb1::Disposable::Twin::Sync::SkipGetter

      require "trb1-disposable/twin/save"
      feature Trb1::Disposable::Twin::Save

      require "trb1-reform/form/prepopulate"
      include Prepopulate

      def skip!
        Trb1::Representable::Pipeline::Stop
      end
    end
  end
end
