module Solargraph
  module Processors

    MAPPABLE_METHODS = [
        :include, :extend, :require, :autoload,
        :attr_reader, :attr_writer, :attr_accessor,
        :private, :public, :protected
    ]

    def map_include

    end
  end
end