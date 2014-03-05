module JSON5
  class Stringifier
# # JSON5 stringify will not quote keys where appropriate
# JSON5.stringify = function (obj, replacer, space)
    def initialize obj, replacer, space
      if (replacer && (typeof(replacer) != "function" && !isArray(replacer)))
        throw new Error('Replacer must be a function or an array')
      end
    end

    def getReplacedValueOrUndefined holder, key, isTopLevel
      value = holder[key]

      # Replace the value with its toJSON value first, if possible
      # if (value && value.toJSON && typeof value.toJSON === "function")
      if (value && value.responds_to?(:to_json))
          # value = value.toJSON
          value = value.to_json
      end

      # If the user-supplied replacer if a function, call it. If it's an array, check objects' string keys for
      # presence in the array (removing the key/value pair from the resulting JSON if the key is missing).
      if (typeof(replacer) === "function")
          return replacer.call(holder, key, value)
      elsif(replacer)
          if (isTopLevel || isArray(holder) || replacer.indexOf(key) >= 0)
              return value
          else
              return undefined
          end
      else
          return value
      end
    end

    def isWordChar(char)
      return (char >= 'a' && char <= 'z') ||
          (char >= 'A' && char <= 'Z') ||
          (char >= '0' && char <= '9') ||
          char === '_' || char === '$'
    end

    def isWordStart(char)
      return (char >= 'a' && char <= 'z') ||
          (char >= 'A' && char <= 'Z') ||
          char === '_' || char === '$'
    end

    def isWord(key)
      if (typeof key != 'string')
          return false
      end
      if (!isWordStart(key[0]))
          return false
      end
      i = 1, length = key.length
      while (i < length) do
          if (!isWordChar(key[i]))
              return false
          end
          i += 1
      end
      return true
    end

  #     # export for use in tests
  #     JSON5.isWord = isWord

  #     # polyfills
    def isArray(obj)
      if (Array.isArray)
          return Array.isArray(obj)
      else
          return Object.prototype.toString.call(obj) === '[object Array]'
      end
    end

    def isDate(obj)
      return Object.prototype.toString.call(obj) === '[object Date]'
    end

    # isNaN = isNaN || ->(val)
    #   return typeof val === 'number' && val != val
    # end

  #     objStack = []
  #     def checkForCircular(obj)
  #         for (i = 0; i < objStack.length; i++)
  #             if (objStack[i] === obj)
  #                 throw new TypeError("Converting circular structure to JSON")
  #             end
  #         end
  #     end

  #     def makeIndent(str, num, noNewLine)
  #         if (!str)
  #             return ""
  #         end
  #         # indentation no more than 10 chars
  #         if (str.length > 10)
  #             str = str.substring(0, 10)
  #         end

  #         indent = noNewLine ? "" : "\n"
  #         for (i = 0; i < num; i++)
  #             indent += str
  #         end

  #         return indent
  #     end

  #     indentStr
  #     if (space)
  #         if (typeof space === "string")
  #             indentStr = space
  #         elsif (typeof space === "number" && space >= 0)
  #             indentStr = makeIndent(" ", space, true)
  #         else
  #             # ignore space parameter
  #         end
  #     end

  #     # Copied from Crokford's implementation of JSON
  #     # See https://github.com/douglascrockford/JSON-js/blob/e39db4b7e6249f04a195e7dd0840e610cc9e941e/json2.js#L195
  #     # Begin
  #     cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
  #         escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
  #         meta = { # table of character substitutions
  #         '\b': '\\b',
  #         '\t': '\\t',
  #         '\n': '\\n',
  #         '\f': '\\f',
  #         '\r': '\\r',
  #         '"' : '\\"',
  #         '\\': '\\\\'
  #     end
  #     def escapeString(string)

  # # If the string contains no control characters, no quote characters, and no
  # # backslash characters, then we can safely slap some quotes around it.
  # # Otherwise we must also replace the offending characters with safe escape
  # # sequences.
  #         escapable.lastIndex = 0
  #         return escapable.test(string) ? '"' + string.replace(escapable, function (a)
  #             c = meta[a]
  #             return typeof c === 'string' ?
  #                 c :
  #                 '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4)
  #         end) + '"' : '"' + string + '"'
  #     end
  #     # End

  #     def internalStringify(holder, key, isTopLevel)
  #         buffer, res

  #         # Replace the value, if necessary
  #         obj_part = getReplacedValueOrUndefined(holder, key, isTopLevel)

  #         if (obj_part && !isDate(obj_part))
  #             # unbox objects
  #             # don't unbox dates, since will turn it into number
  #             obj_part = obj_part.valueOf
  #         end
  #         switch(typeof obj_part)
  #             when "boolean"
  #                 return obj_part.toString

  #             when "number"
  #                 if (isNaN(obj_part) || !isFinite(obj_part))
  #                     return "null"
  #                 end
  #                 return obj_part.toString

  #             when "string"
  #                 return escapeString(obj_part.toString)

  #             when "object"
  #                 if (obj_part === null)
  #                     return "null"
  #                 elsif (isArray(obj_part))
  #                     checkForCircular(obj_part)
  #                     buffer = "["
  #                     objStack.push(obj_part)

  #                     for (i = 0; i < obj_part.length; i++)
  #                         res = internalStringify(obj_part, i, false)
  #                         buffer += makeIndent(indentStr, objStack.length)
  #                         if (res === null || typeof res === "undefined")
  #                             buffer += "null"
  #                         else
  #                             buffer += res
  #                         end
  #                         if (i < obj_part.length-1)
  #                             buffer += ","
  #                         elsif (indentStr)
  #                             buffer += "\n"
  #                         end
  #                     end
  #                     objStack.pop
  #                     buffer += makeIndent(indentStr, objStack.length, true) + "]"
  #                 else
  #                     checkForCircular(obj_part)
  #                     buffer = "{"
  #                     nonEmpty = false
  #                     objStack.push(obj_part)
  #                     for (prop in obj_part)
  #                         if (obj_part.hasOwnProperty(prop))
  #                             value = internalStringify(obj_part, prop, false)
  #                             isTopLevel = false
  #                             if (typeof value != "undefined" && value != null)
  #                                 buffer += makeIndent(indentStr, objStack.length)
  #                                 nonEmpty = true
  #                                 key = isWord(prop) ? prop : escapeString(prop)
  #                                 buffer += key + ":" + (indentStr ? ' ' : '') + value + ","
  #                             end
  #                         end
  #                     end
  #                     objStack.pop
  #                     if (nonEmpty)
  #                         buffer = buffer.substring(0, buffer.length-1) + makeIndent(indentStr, objStack.length) + "}"
  #                     else
  #                         buffer = '{}'
  #                     end
  #                 end
  #                 return buffer
  #             else
  #                 # functions and undefined should be ignored
  #                 return undefined
  #         end
  #     end

  #     # special case...when undefined is used inside of
  #     # a compound object/array, return null.
  #     # but when top-level, return undefined
  #     topLevelHolder = {"":obj}
  #     if (obj === undefined)
  #         return getReplacedValueOrUndefined(topLevelHolder, '', true)
  #     end
  #     return internalStringify(topLevelHolder, '', true)
  # end
  end
end
