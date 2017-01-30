require "trb1-disposable/twin/composition"

module Trb1::Reform::Form::Composition
  # Automatically creates a Composition object for you when initializing the form.
  def self.included(base)
    base.class_eval do
      # extend Trb1::Reform::Form::ActiveModel::ClassMethods # ::model.
      extend ClassMethods
      include Trb1::Disposable::Twin::Composition
    end
  end

  module ClassMethods
    # Same as ActiveModel::model but allows you to define the main model in the composition
    # using +:on+.
    #
    # class CoverSongForm < Trb1::Reform::Form
    #   model :song, on: :cover_song
    def model(main_model, options={})
      super

      composition_model = options[:on] || main_model

      # FIXME: this should just delegate to :model as in FB, and the comp would take care of it internally.
      [:persisted?, :to_key, :to_param].each do |method|
        define_method method do
          model[composition_model].send(method)
        end
      end

      self
    end
  end
end
