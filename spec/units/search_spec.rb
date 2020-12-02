# frozen_string_literal: true

describe Search do
  context '#perform' do
    before do
      @languages = []
      @languages << Language.new(
        name: 'ActionScript',
        tags: ['Compiled', 'Curly-bracket', 'Procedural', 'Reflective', 'Scripting', 'Object-oriented class-based'],
        authors: ['Gary Grossman']
      )
      @languages << Language.new(
        name: 'AWK',
        tags: ['Curly-bracket', 'Scripting'],
        authors: ['Alfred Aho', 'Peter Weinberger', 'Brian Kernighan']
      )
      @languages << Language.new(
        name: 'B',
        tags: ['Curly-bracket'],
        authors: ['Ken Thompson']
      )
      @languages << Language.new(
        name: 'bash',
        tags: ['Command line interface', 'Scripting'],
        authors: ['Brian Fox']
      )
      @languages << Language.new(
        name: 'BASIC',
        tags: ['Imperative', 'Compiled', 'Procedural', 'Interactive mode', 'Interpreted'],
        authors: ['John George Kemeny', 'Thomas Eugene Kurtz']
      )
      @languages << Language.new(
        name: 'C',
        tags: ['Compiled', 'Curly-bracket', 'Imperative', 'Procedural'],
        authors: ['Dennis Ritchie']
      )
      @languages << Language.new(
        name: 'Chapel',
        tags: ['Array'],
        authors: ['David Callahan', 'Hans Zima', 'Brad Chamberlain', 'John Plevyak']
      )
      @languages << Language.new(
        name: 'Cilk',
        tags: ['Curly-bracket'],
        authors: ['MIT']
      )
    end

    it 'query with single includes' do
      query = Query.new(includes: ['actionscript'])
      language_names = Search.new(query, @languages).perform.map(&:name)
      expect(language_names).to eq(['ActionScript'])
    end

    it 'query with excludes' do
      query = Query.new(excludes: ['array', 'Curly-bracket'])
      language_names = Search.new(query, @languages).perform.map(&:name)
      expect(language_names).to eq(['bash', 'BASIC'])
    end

    it 'query with exact matches' do
      query = Query.new(exact_matches: ['imperative', 'procedural'])
      language_names = Search.new(query, @languages).perform.map(&:name)
      expect(language_names).to eq(['BASIC', 'C'])
    end

    it 'query with must-includes' do
      query = Query.new(must_include: ['imperative', 'procedural'])
      language_names = Search.new(query, @languages).perform.map(&:name)
      expect(language_names).to eq(['BASIC', 'C'])
    end

    it 'complex query' do
      query = Query.new(must_include: ['curly-bracket'], excludes: ['gary'], includes: ['scripting'])
      language_names = Search.new(query, @languages).perform.map(&:name)
      expect(language_names).to eq(['AWK'])
    end
  end
end