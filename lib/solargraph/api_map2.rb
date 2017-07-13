require 'rubygems'
require 'parser/current'
require 'yard'
require 'yaml'

module Solargraph
  class ApiMap
    autoload :Config, 'solargraph/api_map/config'

    KEYWORDS = [
        '__ENCODING__', '__LINE__', '__FILE__', 'BEGIN', 'END', 'alias', 'and',
        'begin', 'break', 'case', 'class', 'def', 'defined?', 'do', 'else',
        'elsif', 'end', 'ensure', 'false', 'for', 'if', 'in', 'module', 'next',
        'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return', 'self', 'super',
        'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 'yield'
    ]

    include NodeMethods

    attr_reader :workspace
    # no requirnments
    # parent stack could be build during node processing

    def initialize(workspace = nil)
      @workspace = workspace.gsub(/\\/, '/') unless workspace.nil?
      clear
      unless @workspace.nil?
        config = ApiMap::Config.new(@workspace)
        config.included.each { |f|
          unless config.excluded.include?(f)
            append_file f
          end
        }
      end
    end

    def clear
      @file_nodes = {}
      @file_comments = {}
      @namespaces = {}
    end

    def yard_map
      @yard_map ||= YardMap.new(required: required, workspace: workspace)
    end

    def append_file(filename)
      append_source File.read(filename), filename
    end

    def append_source(text, filename = nil)
      begin
        node, comments = Parser::CurrentRuby.parse_with_comments(text)
        append_node(node, comments, filename)
      rescue Parser::SyntaxError => e
        STDERR.puts "Error parsing '#{filename}': #{e.message}"
        nil
      end
    end

    def append_node(node, comments, filename = '(source)')
      @file_comments[filename] = associate_comments(node, comments)
      @file_nodes[filename] = node
      process_maps(filename)
      root
    end

    def associate_comments(node, comments)
      comment_hash = Parser::Source::Comment.associate_locations(node, comments)
      yard_hash = {}
      comment_hash.each_pair { |k, v|
        ctxt = ''
        num = nil
        started = false
        v.each { |l|
          # Trim the comment and minimum leading whitespace
          p = l.text.gsub(/^#/, '')
          if num.nil? and !p.strip.empty?
            num = p.index(/[^ ]/)
            started = true
          elsif started and !p.strip.empty?
            cur = p.index(/[^ ]/)
            num = cur if cur < num
          end
          if started
            ctxt += "#{p[num..-1]}\n"
          end
        }
        yard_hash[k] = YARD::Docstring.parser.parse(ctxt).to_docstring
      }
      yard_hash
    end

    def build_namespaces(node, filename)
      namespaces = ApiMapPreprocessor.new(node).namespaces
      namespaces.each do |namespace, node|
        if @namespaces[namespace].nil?
          @namespaces[namespace] = {}
        else
          @namespaces[namespace][filename] = node
        end
      end
    end

    def get_comment_for node
      filename = get_filename_for(node)
      return nil if @file_comments[filename].nil?
      @file_comments[filename][node.loc]
    end
  end
end
