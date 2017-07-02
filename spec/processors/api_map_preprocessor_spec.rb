require 'spec_helper'
require 'parser/current'

describe Solargraph::Processors::ApiMapPreprocessor do

  context 'namespace' do
    let(:ast) do
      code = %(
        class A
          def a
          end
        end
        module M
          class A
          end
          module ::G
          end
        end
      )
      Parser::CurrentRuby.parse(code)
    end

    let(:namespaces) { Solargraph::Processors::ApiMapPreprocessor.new(ast).namespaces }

    shared_examples 'contains namespace' do |name, type|
      it name do
        expect(namespaces[name]).not_to be_nil
        expect(namespaces[name].type).to eq(type)
      end
    end

    include_examples 'contains namespace', 'A', :class
    include_examples 'contains namespace', 'M', :module
    include_examples 'contains namespace', 'M::A', :class
    include_examples 'contains namespace', 'G', :module
  end
end