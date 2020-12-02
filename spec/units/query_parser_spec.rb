# frozen_string_literal: true

describe QueryParser do
  context '#parse' do
    it 'query with single word with spaces' do
      query = QueryParser.new(' procedural ').parse
      expect(query.includes).to eq(['procedural'])
    end

    it 'query with multiple words' do
      query = QueryParser.new(' procedural  iterative  reflective ').parse
      expect(query.includes).to eq(['procedural', 'iterative', 'reflective'])
    end

    it 'query with word and quoted strings' do
      query = QueryParser.new(' procedural iterative   "  object-oriented class-based  "').parse
      expect(query.includes).to eq(['procedural', 'iterative'])
      expect(query.exact_matches).to eq(['object-oriented class-based'])
    end

    it 'query with word and excluded words' do
      query = QueryParser.new(' procedural --reflective --metaprogramming').parse
      expect(query.includes).to eq(['procedural'])
      expect(query.excludes).to eq(['reflective', 'metaprogramming'])
    end

    it 'query with word and excluded quoted strings' do
      query = QueryParser.new(' procedural --"metaprogramming" --"Object-oriented class-based"').parse
      expect(query.includes).to eq(['procedural'])
      expect(query.excludes).to eq(['metaprogramming', 'Object-oriented class-based'])
    end

    it 'query with must-include words and quoted strings' do
      query = QueryParser.new(' +procedural +"metaprogramming" +"Object-oriented class-based"').parse
      expect(query.must_include).to eq(['procedural', 'metaprogramming', 'Object-oriented class-based'])
    end

    it 'complex query' do
      query_string = '  object abc   "  interpreted    procedural  " +metaprogramming +"Command line" reflective --array --"interactive mode"  '
      query = QueryParser.new(query_string).parse

      expect(query.includes).to eq(['object', 'abc', 'reflective'])
      expect(query.exact_matches).to eq(['interpreted procedural'])
      expect(query.excludes).to eq(['array', 'interactive mode'])
      expect(query.must_include).to eq(['metaprogramming', 'Command line'])
    end
  end
end