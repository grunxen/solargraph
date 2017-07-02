module Solargraph
  module Processors
    module NamespaceBuilder

      def const_name(node)
        if node.nil?
          ''
        elsif node.type == :cbase
          '::'
        elsif node.type == :const
          const_name(node.children[0]) + node.children[1].to_s
        else
          ''
        end
      end
    end
  end
end