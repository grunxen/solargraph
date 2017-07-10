# describe Solargraph::ApiMap2 do
#   before :each do
#     code = %(
#       module Module1
#         class Module1Class
#           class Module1Class2
#           end
#           def module1class_method
#           end
#         end
#         def module1_method
#         end
#       end
#       class Class1
#         include Module1
#         attr_accessor :access_foo
#         attr_reader :read_foo
#         attr_writer :write_foo

#         @@cls_var = 1

#         def bar
#           @bar ||= 'bar'
#           @@def_cls = 'cls'
#         end
#         def self.baz
#           @baz = 'baz'
#           @@defs_cls = 's'
#         end
#         def bing
#           if x == y
#             @bing = z
#           end
#         end
#       end
#       class Class2 < Class1
#       end
#     )
#     @api_map = Solargraph::ApiMap.new
#     @api_map.append_source(code, 'file.rb')
#   end

#   it "finds instance methods" do
#     methods = @api_map.get_instance_methods("Class1")
#     expect(methods.map(&:to_s)).to include('bar')
#     expect(methods.map(&:to_s)).not_to include('baz')
#   end

#   it "finds included instance methods" do
#     methods = @api_map.get_instance_methods("Class1")
#     expect(methods.map(&:to_s)).to include('module1_method')
#   end

#   it "finds superclass instance methods" do
#     methods = @api_map.get_instance_methods("Class2")
#     expect(methods.map(&:to_s)).to include('bar')
#     expect(methods.map(&:to_s)).to include('module1_method')
#   end

#   it "finds singleton methods" do
#     methods = @api_map.get_methods("Class1")
#     expect(methods.map(&:to_s)).to include('baz')
#     expect(methods.map(&:to_s)).not_to include('bar')
#   end

#   it "finds instance variables" do
#     vars = @api_map.get_instance_variables("Class1")
#     expect(vars.map(&:to_s)).to include('@bar')
#     expect(vars.map(&:to_s)).not_to include('@baz')
#   end

#   it "finds instance variables inside blocks" do
#     vars = @api_map.get_instance_variables("Class1")
#     expect(vars.map(&:to_s)).to include('@bing')
#   end

#   it "finds class variables" do
#     vars = @api_map.get_class_variables("Class1")
#     expect(vars.map(&:to_s)).to include('@@cls_var', '@@def_cls', '@@defs_cls')
#   end

#   it "finds class instance variables" do
#     vars = @api_map.get_instance_variables("Class1", :class)
#     expect(vars.map(&:to_s)).to include('@baz')
#     expect(vars.map(&:to_s)).not_to include('@bar')
#   end

#   it "finds attr_read methods" do
#     methods = @api_map.get_instance_methods("Class1")
#     expect(methods.map(&:to_s)).to include('read_foo')
#     expect(methods.map(&:to_s)).not_to include('read_foo=')
#   end

#   it "finds attr_write methods" do
#     methods = @api_map.get_instance_methods("Class1")
#     expect(methods.map(&:to_s)).to include('write_foo=')
#     expect(methods.map(&:to_s)).not_to include('write_foo')
#   end

#   it "finds attr_accessor methods" do
#     methods = @api_map.get_instance_methods("Class1")
#     expect(methods.map(&:to_s)).to include('access_foo')
#     expect(methods.map(&:to_s)).to include('access_foo=')
#   end

#   it "finds root namespaces" do
#     namespaces = @api_map.namespaces_in('')
#     expect(namespaces.map(&:to_s)).to include("Class1")
#   end

#   it "finds included namespaces" do
#     namespaces = @api_map.namespaces_in('Class1')
#     expect(namespaces.map(&:to_s)).to include('Module1Class')
#   end

#   it "finds namespaces within namespaces" do
#     namespaces = @api_map.namespaces_in('Module1')
#     expect(namespaces.map(&:to_s)).to include('Module1Class')
#   end

#   it "excludes namespaces outside of scope" do
#     namespaces = @api_map.namespaces_in('')
#     expect(namespaces.map(&:to_s)).not_to include('Module1Class')
#   end

#   it "finds instance variables in scoped classes" do
#     methods = @api_map.get_instance_methods('Module1Class', 'Module1')
#     expect(methods.map(&:to_s)).to include('module1class_method')
#   end

#   it "finds namespaces beneath the current scope" do
#     expect(@api_map.namespace_exists?('Class1', 'Module1')).to be true
#   end

#   it "finds fully qualified namespaces" do
#     expect(@api_map.namespace_exists?('Module1::Module1Class')).to be true
#   end

#   it "finds partially qualified namespaces in specified scopes" do
#     expect(@api_map.namespace_exists?('Module1Class::Module1Class2', 'Module1')).to be true
#     expect(@api_map.namespace_exists?('Module1Class::Module1Class2', 'Class1')).to be false
#   end

#   it "infers instance variable classes" do
#     cls = @api_map.infer_instance_variable('@bar', 'Class1')
#     expect(cls).to eq('String')
#   end

#   it "finds filenames for nodes" do
#     nodes = @api_map.get_namespace_nodes('Class1')
#     expect(@api_map.get_filename_for(nodes.first)).to eq('file.rb')
#   end

#   it "infers local class from [Class].new method" do
#     cls = @api_map.infer_signature_type('Class1.new', '', scope: :class)
#     expect(cls).to eq('Class1')
#     cls = @api_map.infer_signature_type('Module1::Module1Class.new', '', scope: :class)
#     expect(cls).to eq('Module1::Module1Class')
#     cls = @api_map.infer_signature_type('Module1Class.new', 'Module1', scope: :class)
#     expect(cls).to eq('Module1::Module1Class')
#   end

#   it "infers core class from [Class].new method" do
#     cls = @api_map.infer_signature_type('String.new', '', scope: :class)
#     expect(cls).to eq('String')
#   end
# end
