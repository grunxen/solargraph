require 'parser'

module Solargraph
  module Processors
  
    class ApiMapPreprocessor < Parser::AST::Processor

      def initialize(node)
        @required = []
        @namespaces_stack = []
        @namespaces = []
        @namespace_holders_stack = []
        process(node)
      end

      def on_send(node)
        # send "map_#{}"
      end

      def add_const(node, holder)
        namespace = const_namespace(node)
        if namespace.start_with?('::') # global namespace, insert without '::'
          namespace[0, 2] = ''
        else
          prev_namespace = @namespaces_stack.last.to_s
          prev_namespace += '::' if prev_namespace != ''
          namespace.insert(0,  prev_namespace)
        end
        @namespaces_stack << namespace
        @namespaces << [namespace, @namespace_holders_stack.last]
      end

      def on_namespace(node)
        @namespace_holders_stack << node
        add_const(node.children[0], node)
        process_regular_node(node)
        @namespaces_stack.pop
        @namespace_holders_stack.pop
      end

      alias_method :on_class, :on_namespace
      alias_method :on_module, :on_namespace

      def namespaces
        if @namespaces.is_a? Array
          hash = {}
          @namespaces.each do |n|
            hash[n[0]] = n[1]
          end
          @namespaces = hash
        end
        @namespaces
      end

      private

      def const_namespace(node)
        if node.nil?
          ''
        elsif node.type == :cbase
          '::'
        elsif node.type == :const
          const_namespace(node.children[0]) + node.children[1].to_s
        else
          ''
        end
      end
    end
  end
end