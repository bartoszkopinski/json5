class JSON5
  def initialize
    @at   = nil
    @ch   = nil
    @text = nil
  end

  def error(m)
    error = SyntaxError.new("#{m} at #{@at}: #{@text}")
    raise error
  end

  def get_next c = nil
    if (c && c != @ch)
      error("Expected '" + c + "' instead of '" + @ch + "'")
    end

    # Get the next character. When there are no more characters,
    # return the empty string.

    # ch = text.charAt(at)
    @ch = @text[@at]
    @at += 1
    return @ch
  end

  ESCAPEE = {
    "'" =>  "'",
    '"' =>  '"',
    '\\' => '\\',
    '/' =>  '/',
    "\n" => '',       # Replace escaped newlines in strings w/ empty string
    'b' => '\b',
    'f' => '\f',
    'n' => "\n",
    'r' => '\r',
    't' => '\t',
  }


  def identifier
    # Parse an identifier. Normally, reserved words are disallowed here, but we
    # only use this for unquoted object keys, where reserved words are allowed,
    # so we don't check for those here. References:
    # - http://es5.github.com/#x7.6
    # - https://developer.mozilla.org/en/Core_JavaScript_1.5_Guide/Core_Language_Features#Variables
    # - http://docstore.mik.ua/orelly/webprog/jscript/ch02_07.htm
    # TODO Identifiers can have Unicode "letters" in them; add support for those.

    key = @ch

    # Identifiers must start with a letter, _ or $.
    if ((@ch != '_' && @ch != '$') && (@ch < 'a' || @ch > 'z') && (@ch < 'A' || @ch > 'Z'))
      error("Bad identifier")
    end

    # Subsequent characters can contain digits.
    while (get_next && (
      @ch == '_' || @ch == '$' ||
      (@ch >= 'a' && @ch <= 'z') ||
      (@ch >= 'A' && @ch <= 'Z') ||
      (@ch >= '0' && @ch <= '9'))) do
      key += @ch
    end

    return key
  end

  def number
    # Parse a number value.
    number = nil
    sign   = ''
    string = ''
    base   = 10

    if (@ch == '-' || @ch == '+')
      sign = string = @ch
      get_next(@ch)
    end

    # support for Infinity (could tweak to allow other words):
    if (@ch == 'I')
      number = word
      if (number.is_a?(Integer))
        error('Unexpected word for number')
      end
      return (sign == '-') ? -number : number
    end

    # support for NaN
    if (@ch == 'N' )
      number = word
      if (!isNaN(number))
        error('expected word to be NaN')
      end
      # ignore sign as -NaN also is NaN
      return number
    end

    if (@ch == '0')
      string += @ch
      get_next
      if (@ch == 'x' || @ch == 'X')
        string += @ch
        get_next
        base = 16
      elsif (@ch >= '0' && @ch <= '9')
        error('Octal literal')
      end
    end

    # https://github.com/aseemk/json5/issues/36
    if (base == 16 && !sign.empty?)
      error('Signed hexadecimal literal')
    end

    case (base)
    when 10
      while (@ch >= '0' && @ch <= '9' ) do
        string += @ch
        get_next
      end
      if (@ch == '.')
        string += '.'
        while (get_next && @ch >= '0' && @ch <= '9') do
          string += @ch
        end
      end
      if (@ch == 'e' || @ch == 'E')
        string += @ch
        get_next
        if (@ch == '-' || @ch == '+')
          string += @ch
          get_next
        end
        while (@ch >= '0' && @ch <= '9') do
          string += @ch
          get_next
        end
      end
    when 16
      while (@ch >= '0' && @ch <= '9' || @ch >= 'A' && @ch <= 'F' || @ch >= 'a' && @ch <= 'f') do
        string += @ch
        get_next
      end
    end

    string.chomp!('.')
    begin
      if string.include?('.') || string.include?('e-')
        Float(string).to_f
      else
        Float(string).to_i
      end
    rescue
      error("Bad number")
    end
  end

  def string
    # Parse a string value.

    hex     = nil
    i       = nil
    string  = ''
    delim   = nil      # double quote or single quote
    uffff   = nil

    # When parsing for string values, we must look for ' or " and \ characters

    if (@ch == '"' || @ch == "'")
      delim = @ch
      while (get_next) do
        if (@ch == delim)
          get_next
          return string
        elsif (@ch == '\\')
          get_next
          if (@ch == 'u')
            uffff = 0
                # for (i = 0; i < 4; i += 1) do
                for i in 0...4 do
                  hex = parseInt(get_next, 16)
                  if (!isFinite(hex))
                    break
                  end
                  uffff = uffff * 16 + hex
                end
                string += String.fromCharCode(uffff)
              elsif ESCAPEE.has_key? @ch
                string += ESCAPEE[@ch]
              else
                break
              end
            elsif (@ch == "\n")
            # unescaped newlines are invalid; see:
            # https://github.com/aseemk/json5/issues/24
            # TODO this feels special-cased; are there other
            # invalid unescaped chars?
            break
          else
            string += @ch
          end
        end
      end
      error("Bad string")
    end

    def inlineComment
    # Skip an inline comment, assuming this is one. The current character should
    # be the second / character in the # pair that begins this inline comment.
    # To finish the inline comment, we look for a newline or the end of the text.

    if (@ch != '/')
      error("Not an inline comment")
    end

    begin
      get_next
      if (@ch == "\n")
        get_next("\n")
        return
      end
    end while (@ch)
  end

  def blockComment

  # Skip a block comment, assuming this is one. The current @character should be
  # the * @character in the /* pair that begins this block comment.
  # To finish the block comment, we look for an ending */ pair of @characters,
  # but we also wat@ch for the end of text before the comment is terminated.

  if (@ch != '*')
    error("Not a block comment")
  end

  begin
    get_next
    while (@ch == '*') do
      get_next('*')
      if (@ch == '/')
        get_next('/')
        return
      end
    end
  end while (@ch)

  error("Unterminated block comment")
end

def comment
    # Skip a comment, whether inline or block-level, assuming this is one.
    # Comments always begin with a / @character.

    if (@ch != '/')
      error("Not a comment")
    end

    get_next('/')

    if (@ch == '/')
      inlineComment
    elsif (@ch == '*')
      blockComment
    else
      error("Unrecognized comment")
    end
  end

  def white
    # Skip whitespace and comments.
    # Note that we're detecting comments by only a single / @character.
    # This works since regular expressions are not valid JSON(5), but this will
    # break if there are other valid values that begin with a / @character

    while (@ch) do
      if (@ch == '/')
        comment
      elsif (@ch <= ' ')
        get_next
      else
        return
      end
    end
  end

  def word
    # true, false, or null.

    case (@ch)
    when 't'
      get_next('t')
      get_next('r')
      get_next('u')
      get_next('e')
      return true
    when 'f'
      get_next('f')
      get_next('a')
      get_next('l')
      get_next('s')
      get_next('e')
      return false
    when 'n'
      get_next('n')
      get_next('u')
      get_next('l')
      get_next('l')
      return nil
    when 'I'
      get_next('I')
      get_next('n')
      get_next('f')
      get_next('i')
      get_next('n')
      get_next('i')
      get_next('t')
      get_next('y')
      return Float::INFINITY
    when 'N'
      get_next( 'N' )
      get_next( 'a' )
      get_next( 'N' )
      return Float::NAN
    end
    error("Unexpected '" + @ch + "'")
  end

  def array
    # Parse an array value.

    array = []

    if (@ch == '[')
      get_next('[')
      white
      while (@ch) do
        if (@ch == ']')
          get_next(']')
            return array;   # Potentially empty array
          end
        # ES5 allows omitting elements in arrays, e.g. [,] and
        # [,null]. We don't allow this in JSON5.
        if (@ch == ',')
          error("Missing array element")
        else
          array.push(value)
        end
        white
        # If there's no comma after this value, this needs t
        # be the end of the array.
        if (@ch != ',')
          get_next(']')
          return array
        end
        get_next(',')
        white
      end
    end
    error("Bad array")
  end

  def object
    # Parse an object value.
    key = nil
    object = {}

    if (@ch == '{')
      get_next('{')
      white
      while (@ch) do
        if (@ch == '}')
          get_next('}')
          return object;   # Potentially empty object
        end

        # Keys can be unquoted. If they are, they need to b
        # valid JS identifiers.
        if (@ch == '"' || @ch == "'")
          key = string
        else
          key = identifier
        end

        white
        get_next(':')

        if (object.has_key? key)
          error('Duplicate key "' + key + '"')
        end
        object[key] = value
        white
        # If there's no comma after this pair, this needs to b
        # the end of the object.
        if (@ch != ',')
          get_next('}')
          return object
        end
        get_next(',')
        white
      end
    end
    error("Bad object")
  end

  def value
    # Parse a JSON value. It could be an object, an array, a string, a number,
    # or a word.

    white
    case (@ch)
    when '{'
      return object
    when '['
      return array
    when '"',  "'"
      return string
    when '-', '+', '.'
      return number
    else
      return @ch >= '0' && @ch <= '9' ? number : word
    end
  end

  def parse source, reviver = nil
    result = nil

    @text = source
    @at = 0
    @ch = ' '
    result = value
    white
    if (@ch)
      error("Syntax error")
    end

    # If there is a reviver function, we recursively walk the new structure,
    # passing each name/value pair to the reviver function for possible
    # transformation, starting with a temporary root object that holds the result
    # in an empty key. If there is not a reviver function, we simply return the
    # result.

    walk = ->(holder, key) do
      k, v, value = holder[key]
      if (value)
        value.each do |k|
          if (Object.prototype.hasOwnProperty.call(value, k))
            v = walk(value, k)
            if (v != undefined)
              value[k] = v
            else
              delete value[k]
            end
          end
        end
      end
      return reviver.call(holder, key, value)
    end

    return reviver ? walk.call({ '' => result }, '') : result
  end
end
