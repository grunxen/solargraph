require 'parser'
require 'set'

module Solargraph
  module Processors
    class VariableList < Parser::AST::Processor

      # *types can include :ivar, :cvar, :civar
      def initialize(node, *types)
        @vars = Set.new
        @scopes = []
        @types = *types
        process(node)
      end

      def on_class(node)
        @scopes.push(node.type)
        super(node)
        @scopes.pop
      end

      def on_sclass(node)
        @scopes.push(node.type)
        super(node)
        @scopes.pop
      end

      def on_module(node)
        @scopes.push(node.type)
        super
        @scopes.pop
      end

      def on_def(node)
        @scopes.push(node.type)
        super(node)
        @scopes.pop
      end

      def on_defs(node)
        @scopes.push(node.type)
        super(node)
        @scopes.pop
      end

      def on_cvar(node)
        add_var(node) if @types.include?(:cvar)
        super(node)
      end

      def on_ivar(node)
        if @types.include?(:ivar) && @scopes.last == :def
          add_var(node)
        elsif @types.include?(:civar) && [:defs, :class, :module].include?(@scope.last) 
          add_var(node)
        end
        super(node)
      end

      def on_ivasgn(node)
        if @types.include?(:ivar) && @scopes.last == :def
          add_var(node)
        elsif @types.include?(:civar) && [:defs, :class, :module].include?(@scopes.last)
          add_var(node)
        end
        super(node)
      end

      def on_cvasgn(node)
        add_var(node) if @types.include?(:cvar)
        super(node)
      end

      def vars
        @vars.to_a
      end

      private

      def add_var(node)
        @vars << node.children[0]
      end
    end
  end
end