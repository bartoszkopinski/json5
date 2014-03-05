require 'json5/version'
require 'json5/parser'
require 'json5/stringifier'

module JSON5
  def self.parse source, reviver = nil
    Parser.new(source, reviver).run
  end

  def self.stringify obj, replacer, space
    Stringifier.new(obj, replacer, space).run
  end
end
