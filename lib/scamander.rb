# frozen_string_literal: true

require "scamander/version"
require "parser/current"

module Scamander
  class Newt
    def scan(directory)
      Dir["#{directory}/**/*.rb"].each do |filename|
        check(filename)
      end
    end

    def check(filename)
      firstline = File.open(filename) {|f| f.readline}.strip
      magic_comment = firstline == "# frozen_string_literal: true"
      buffer = Parser::Source::Buffer.new(filename)
      buffer.read
      parser = Parser::CurrentRuby.new
      ast = parser.parse(buffer)
      scanner = AstScanner.new
      scanner.check_strings = !magic_comment
      scanner.process(ast)
      if scanner.offense_default_argument || scanner.offense_default_argument
        # TODO: print line number(s)
        puts "Found #{offenses_to_s(scanner)} in #{filename}"
      end
    end

    def offenses_to_s(scanner)
      offenses = []
      if scanner.offense_default_argument
        offenses.push("hash as default argument")
      end
      if scanner.offense_unfrozen_string
        offenses.push("unfrozen string literals")
      end
      offenses.join(", ")
    end

    class AstScanner < Parser::AST::Processor
      attr_accessor :offense_default_argument,
        :offense_unfrozen_string,
        :check_strings

      def on_def(node)
        if check_strings
          self.offense_unfrozen_string = self.offense_unfrozen_string || look_for_strings(node)
        end
        self.offense_default_argument = self.offense_default_argument || look_for_hash_defaults(node)
      end

      def on_send(node)
        if check_strings
          self.offense_unfrozen_string = self.offense_unfrozen_string || look_for_strings(node)
        end
      end

      def look_for_strings(node)
        if node.nil?
          false
        elsif node.respond_to?(:type) && node.type == :str
          true
        elsif node.respond_to?(:children) && node.children
          node.children.any?{ |x| look_for_strings(x) }
        elsif node.is_a?(Array)
          node.any?{ |x| look_for_strings(x) }
        else
          false
        end
      end

      def look_for_hash_defaults(node)
        args = node.children[1]
        args.children.any? do |arg|
          name, type = arg.children
          !type.nil? && type.type == :hash
        end
      end
    end
  end
end
