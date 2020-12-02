# frozen_string_literal: true

# Used for building Language object from hash with following keys:
# ['Name', 'Designed by', Type].
# Used for parsing data.json
class LanguageBuilder
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  def build
    Language.new(
      name: @attributes['Name'],
      authors: @attributes['Designed by'].split(', '),
      tags: @attributes['Type'].split(', ')
    )
  end
end
