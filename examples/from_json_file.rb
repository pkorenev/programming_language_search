require_relative '../environment'

languages = LanguagesLoader.load_languages
query_string = "curly-bracket --imperative"
puts "query:\n#{query_string}"

query = QueryParser.new(query_string)
found_languages = Search.new(query, languages).perform
puts "Result:"
found_languages.each do |language|
  puts "Language: #{language.name}"
  puts "Authors: #{language.authors.join(', ')}"
  puts "Tags: #{language.tags.join(', ')}"
end