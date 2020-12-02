# frozen_string_literal: true

# Represents language item
class Language
  attr_reader :name, :authors, :tags

  def initialize(name:, authors:, tags:)
    @name = name
    @authors = authors
    @tags = tags
  end
end
