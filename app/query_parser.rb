# frozen_string_literal: true

# QueryParser actually performs different functions:
# 1. Breaks query string to lexical atoms like quote, operators, words. See QueryParser#to_token.
# 2. Converts tokens from previous step to syntax tree. See QueryParser#build_tree
# 3. Builds Query's instance which represents search options.

# TODO: refactor subclasses and submodules. Maybe move them to other files.
# TODO: rewrite method QueryParser#to_token. Probably it'd be better to implement logic in Nodes' classes.
#   That way code will be more independent.
# TODO: rewrite method QueryParser#build_subtree!. Also, probably, we can move logic to Nodes' classes.
# TODO: Think whether we can move logic from QueryParser#build_query to somewhere to avoid cohesion.
#
class QueryParser
  module SYMBOLS
    QUOTE = '"'
    EXCLUDES_OPERATOR = '--'
    MUST_INCLUDE_OPERATOR = '+'
  end

  module TOKENS
    QUOTE = :quote
    EXCLUDES_OPERATOR = :excludes
    MUST_INCLUDE_OPERATOR = :must_include
    TEXT = :text
  end

  module Nodes
    class Node
      attr_accessor :children, :parent
      alias value children
      alias value= children=

      def initialize(children = [], parent = nil)
        @children = children
        @parent = parent
      end

      def <<(node)
        node.parent = self if node.is_a?(Node)
        @children << node
      end

      def add_children(nodes)
        @children += nodes
      end

      def inspect
        "(<#{self.class.name.split('::').last}: #{pretty_value}>"
      end

      def pretty_value
        children.inspect
      end
    end

    class Root < Node

    end

    class String < Node
      def value
        children.map(&:value).join(' ')
      end

      def value=(value)
        if value.is_a?(::String)
          self.children = [value]
        else
          super
        end
      end
    end

    class Excludes < Node
      def value
        children.first.is_a?(Nodes::String) ? children.first.value : children.first
      end

      def value=(value)
        self.children = Array.wrap(value)
      end
    end

    class Includes < Node

    end

    class MustInclude < Node
      def value
        children.first.is_a?(Nodes::String) ? children.first.value : children.first
      end

      def value=(value)
        self.children = Array.wrap(value)
      end
    end

    class Text < Node
      def value
        children.first
      end

      def value=(value)
        self.children = Array.wrap(value)
      end

      def pretty_value
        value.inspect
      end
    end
  end

  def initialize(query)
    @query = query
  end

  # for now this is not used
  def registered_node_types
    [Nodes::String, Nodes::Excludes, Nodes::MustInclude, Nodes::Text]
  end

  def parse
    tokens = []
    @query.split(' ').each { |string| tokens += to_token(string) }
    tree = build_tree(tokens)
    build_query(tree)
  end

  private

  def to_token(string)
    return [] if string.empty?

    if string == SYMBOLS::QUOTE
      [{ type: TOKENS::QUOTE }]
    elsif (quote_index = string.index(SYMBOLS::QUOTE))
      [
        *to_token(string[0, quote_index]),
        { type: TOKENS::QUOTE },
        *to_token(string[quote_index + 1, string.length])
      ]
    elsif string.start_with?(SYMBOLS::EXCLUDES_OPERATOR)
      token = { type: TOKENS::EXCLUDES_OPERATOR, value: string[SYMBOLS::EXCLUDES_OPERATOR.length, string.length] }
      token.delete(:value) if token[:value].empty?
      [token]
    elsif string.start_with?(SYMBOLS::MUST_INCLUDE_OPERATOR)
      token = {
        type: TOKENS::MUST_INCLUDE_OPERATOR,
        value: string[SYMBOLS::MUST_INCLUDE_OPERATOR.length, string.length]
      }
      token.delete(:value) if token[:value].empty?
      [token]
    else
      [{ type: TOKENS::TEXT, value: string }]
    end
  end

  def build_tree(tokens)
    root = Nodes::Root.new
    build_subtree!(tokens, root)
  end

  # it modifies node
  def build_subtree!(tokens, node)
    context = node
    quote_opened = false
    excludes_opened = false
    must_include_opened = false

    tokens.map do |token|
      if token[:type] == TOKENS::QUOTE
        if !quote_opened
          quote_opened = true
          string_node = Nodes::String.new
          context << string_node
          context = string_node
        else
          quote_opened = false
          if excludes_opened
            excludes_opened = false
            context = context.parent.parent
          elsif must_include_opened
            must_include_opened = false
            context = context.parent.parent
          else
            context = context.parent
          end
        end

      elsif token[:type] == TOKENS::EXCLUDES_OPERATOR
        if !token[:value]
          excludes_opened = true
          excludes_node = Nodes::Excludes.new
          context << excludes_node
          context = excludes_node
        else
          excludes_node = Nodes::Excludes.new([token[:value]], context)
          context << excludes_node
        end

      elsif token[:type] == TOKENS::MUST_INCLUDE_OPERATOR
        if !token[:value]
          must_include_opened = true
          must_include_node = Nodes::MustInclude.new
          context << must_include_node
          context = must_include_node
        else
          must_include_node = Nodes::MustInclude.new([token[:value]], context)
          context << must_include_node
        end

      elsif token[:type] == TOKENS::TEXT
        text_node = Nodes::Text.new([token[:value]], context)
        context << text_node
      end
    end

    node
  end

  def build_query(tree)
    query = Query.new
    nodes = tree.children
    query.exact_matches = nodes.select { |node| node.is_a?(Nodes::String) }.map(&:value)
    query.excludes = nodes.select { |node| node.is_a?(Nodes::Excludes) }.map(&:value)
    query.must_include = nodes.select { |node| node.is_a?(Nodes::MustInclude) }.map(&:value)
    query.includes = nodes.select { |node| node.is_a?(Nodes::Text) }.map(&:value)

    query
  end
end
