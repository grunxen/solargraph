module Solargraph
  module Processors
    module BeforeRunner
      def before(method_names=[], method)
        to_prepend = Module.new do
          method_names.each do |name| 
            define_method(name) do |*args, &block|
              send(method, *args, &block)
              super(*args,&block)
            end
          end
        end
        prepend to_prepend
      end
    end
  end
end