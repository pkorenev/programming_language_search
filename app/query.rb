# frozen_string_literal: true

# Represents query object. Has options for search.
# TODO: Think whether we need both `must_include` and `exact_matches` options.
#   Probably they are the same? If so, we can remove one.
#
class Query
  attr_accessor :exact_matches, :excludes, :includes, :must_include

  def initialize(exact_matches: [], excludes: [], includes: [], must_include: [])
    @exact_matches = exact_matches
    @excludes = excludes
    @includes = includes
    @must_include = must_include
  end

  def empty?
    exact_matches.empty? && excludes.empty? && includes.empty? && must_include.empty?
  end
end
