# frozen_string_literal: true

# Provides ability to search across languages.
# Search#perform does the following:
# 1. If query is empty returns all languages
# 2. Filters languages if one more of the following options provided: must_include, exact_matches, excludes.
# 3. If includes is empty returns filtered languages
# 4. Else calculates relevance points for language based on how many matches found.
#   It looks in all 3 fields: name, tags, authors.
#   Rejects languages with 0 points from search result.

# TODO: Think how logic should work.
# TODO: Consider must_include and exact_matches options. Probably we don't need both of them.

class Search
  attr_reader :query, :languages

  # query - Query's instance
  # languages - array of Language's instances
  def initialize(query, languages)
    @query = query
    @languages = languages
  end

  def perform
    languages = self.languages

    if query.empty?
      return languages
    end

    if query.must_include.any?
      languages = must_include_filter(languages, query.must_include)
    end

    if query.exact_matches.any?
      languages = must_include_filter(languages, query.exact_matches)
    end

    if query.excludes.any?
      languages = excludes_filter(languages, query.excludes)
    end

    if query.includes.any?
      languages = order_languages_by_relevance(languages, query.includes)
    end

    languages
  end

  private

  def matches_string?(data_string, input_string)
    !(data_string.downcase =~ /\b#{input_string.downcase}\b/).nil?
  end

  def matches_string_in_array?(data_array_of_strings, input_string)
    data_array_of_strings.any? { |data_string| matches_string?(data_string, input_string) }
  end

  def must_include_filter(languages, must_include_strings)
    languages.select do |language|
      must_include_strings.all? do |input_string|
        matches_string?(language.name, input_string) ||
          matches_string_in_array?(language.authors, input_string) ||
          matches_string_in_array?(language.tags, input_string)
      end
    end
  end

  def excludes_filter(languages, excludes_strings)
    languages.select do |language|
      excludes_strings.none? do |input_string|
        matches_string?(language.name, input_string) ||
            matches_string_in_array?(language.authors, input_string) ||
            matches_string_in_array?(language.tags, input_string)
      end
    end
  end

  def order_languages_by_relevance(languages, includes)
    languages.map do |language|
      [calculate_points_for_language(language, includes) * -1, language]
    end.sort_by(&:first).reject { |arr| arr.first == 0 }.map(&:last)
  end

  def calculate_points_for_language(language, includes)
    points = 0
    name_multiplier = 3
    tag_multiplier = 2
    author_multiplier = 1

    includes.each do |word|
      points += name_multiplier if matches_string?(language.name, word)
      points += tag_multiplier if matches_string_in_array?(language.tags, word)
      points += author_multiplier if matches_string_in_array?(language.authors, word)
    end

    points
  end
end
