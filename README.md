## Usage

* Install deps: `gem install bundler && bundle install`.
* To run tests: `$ rspec` or `$ bin/console`.
* To run example: `$ ruby examples/from_json_file.rb`.
* To run console: `$ bin/console`
* To run ruby linter: `$ rubocop` or `$ rubocop path/to/file`

## Short intro
I thinked about to write more performant search with caching and maybe multithreading. But then I decided not to do it. Because this is just test task. And in real project we'd use some database instead of reimplementing it.

I decided to write lexer + parser for syntax tree for search query.
You can see app/query_parser.rb.
Search is implemented in app/search.rb.

I don't have much experience with writing syntax analyzers, parsers, code generation, tree traversal.
But I'd like to get experience in these things too.

I learned about PEG parsers and it looks interesting to me.
But as I needed to provide result to you as soon as possible I decided not implementing PEG by myself and used something like LL parser.

I decided that probably search at basic implementation, not needed to know sequens in original text query typed by user. So I just created 4 different arrays in Query model.

Also if you find some lack of testing, please forgive me, I have not fully specified a task.
