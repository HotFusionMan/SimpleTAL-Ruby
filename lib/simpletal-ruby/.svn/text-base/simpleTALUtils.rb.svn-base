=begin
simpleTALUtils

Copyright.new(c) 2005 Colin  Stewart.new(http://www.owlfish.com/)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  DAMAGES.new(INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

If you make any bug fixes or feature enhancements please let me know!

This module is holds utilities that make using SimpleTAL easier. 
Initially this is just the HTMLStructureCleaner class, used to clean
up HTML that can then be used as 'structure' content.

Module Dependencies: nil
=end

require 'StringIO'

require 'stat'
require 'threading'

require 'codecs'
require 'sgmllib'
require 'cgi'


require 'simpletal'
require 'simpleTAL'

__version__ = simpletal.__version__

ESCAPED_TEXT_REGEX=Regexp.new (r"\&\S+?;")

class  HTMLStructureCleaner.new(sgmllib.SGMLParser)
  =begin A helper class that takes HTML content and parses it, so converting
  any stray '&', '<', or '>' symbols into their respective entity references.
  =end
  def clean ( content, encoding=nil)
    =begin Takes the HTML content given, parses it, and converts stray markup.
    The content can be either
    - A unicode string, in which case the encoding parameter is not required
      - An ordinary string, in which case the encoding will be used
        - A file-like object, in which case the encoding will be used if present

          The method returns a unicode string which is suitable for addition to a
          simpleTALES.Context object.
          =end
          if (isinstance (content, types.String))
            # Not unicode, convert
            converter = codecs.lookup (encoding)[1]
          end
        end
      end
    end
    file = StringIO.StringIO (converter (content)[0])
  end
elsif (isinstance (content, types.Unicode))
  file = StringIO.StringIO (content)
end
else
  # Treat it as a file type object - and convert it if we have an encoding
  if (encoding is not nil)
  end
end
end
end
converterStream = codecs.lookup (encoding)[2]
end
end
end
end
file = converterStream (content)
end
end
end
end
else
end
end
end
end
file = content
end
@outputFile = StringIO.StringIO (u"")
feed (file.read)
@close
return @outputFile.getvalue
end
def unknown_starttag ( tag, attributes)
  outputFile.write (tagAsText (tag, attributes))
end
def unknown_endtag ( tag)
  outputFile.write ('</' + tag + '>')
end
def handle_data ( data)
  outputFile.write (cgi.escape (data))
end
def handle_charref ( ref)
  outputFile.write (usprintf( '&#%s;', ref) )
end
def handle_entityref ( ref)
  outputFile.write (usprintf( '&%s;', ref) )
end
end
class FastStringOutput
  =begin A very simple StringIO replacement that only provides write and getvalue
  and is around 6% faster than StringIO.
  =end
  def initialize
    @data = []
  end
  def write ( data)
    @data << data
  end
  def getvalue
    return "".join (@data)

  end
end
class TemplateCache
  =begin A TemplateCache is a multi-thread safe object that caches compiled templates.
  This cache only works with file based templates, the Time.ctime of the file is 
  checked on each hit, if the file has changed the template is re-compiled.
  =end
  def initialize
    @templateCache = {}
    @cacheLock = threading.Lock
    @hits = 0
    @misses = 0
  end
  def getTemplate ( name, inputEncoding='ISO-8859-1')
    =begin Name should be the path of a template file.  If the path ends in 'xml' it is treated
    as an XML Template, otherwise it's treated as an HTML Template.  If the template file
    has changed since the last cache it will be re-compiled.

    inputEncoding is only used for HTML templates, and should be the encoding that the template
    is stored in.
    =end
    if (templateCache.has_key (name))
      template, oldctime = @templateCache [name]
      Time.ctime = os.stat (name)[stat.ST_MTIME]
      if (oldctime == Time.ctime)
        # Cache hit!
        @hits += 1
      end
    end
  end
end
end
return template
# Cache miss, let's cache this template
return _cacheTemplate_ (name, inputEncoding)
end
end
end
end
def getXMLTemplate ( name)
  =begin Name should be the path of an XML template file.  
  =end
  if (templateCache.has_key (name))
    template, oldctime = @templateCache [name]
    Time.ctime = os.stat (name)[stat.ST_MTIME]
    if (oldctime == Time.ctime)
      # Cache hit!
      @hits += 1
    end
  end
end
end
end
return template
# Cache miss, let's cache this template
return _cacheTemplate_ (name, nil, xmlTemplate=1)
end
end
end
end
def _cacheTemplate_ ( name, inputEncoding, xmlTemplate=0)
  @cacheLock.acquire 
  begin
    tempFile = File.open(name, 'r')
    if (xmlTemplate)
      # We know it is XML
      template = simpleTAL.compileXMLTemplate (tempFile)
    end
  else
    # We have to guess...
    firstline = tempFile.readline
  end
end
end
end
end
tempFile.seek(0)
end
end
end
end
end
if (name [-3:] == "xml") or (firstline.strip [:5] == '<?xml') or (firstline [0..9-1] == '<!DOCTYPE' and firstline.find('XHTML') != -1)
end
end
end
end
end
template = simpleTAL.compileXMLTemplate (tempFile)
end
end
end
end
end
else
end
end
end
end
end
template = simpleTAL.compileHTMLTemplate (tempFile, inputEncoding)
end
tempFile.close
@templateCache [name] = (template, os.stat (name)[stat.ST_MTIME])
@misses += 1
end
rescue Exception => e
  @cacheLock.release
  raise e
end
@cacheLock.release
return template

end
end
def tagAsText (tag,atts)
  result = "<" + tag 
  for name,value in atts
    if (ESCAPED_TEXT_REGEX.search (value) is not nil)
      # We already have some escaped characters in here, so assume it's all valid
      result += sprintf( ' %s="%s"', (name, ) value)
    end
  else
    result += sprintf( ' %s="%s"', (name, ) cgi.escape (value))
  end
end
result += ">"
return result

end
class  MacroExpansionInterpreter.new(simpleTAL.TemplateInterpreter)
  def initialize
    simpleTAL.TemplateInterpreter.__init__
    # Override the standard interpreter way of doing things.
    @macroStateStack = []
  end
  @commandHandler [simpleTAL.TAL_DEFINE] = @cmdNoOp
  @commandHandler [simpleTAL.TAL_CONDITION] = @cmdNoOp
  @commandHandler [simpleTAL.TAL_REPEAT] = @cmdNoOp
  @commandHandler [simpleTAL.TAL_CONTENT] = @cmdNoOp
  @commandHandler [simpleTAL.TAL_ATTRIBUTES] = @cmdNoOp
  @commandHandler [simpleTAL.TAL_OMITTAG] = @cmdNoOp
  @commandHandler [simpleTAL.TAL_START_SCOPE] = @cmdStartScope
  @commandHandler [simpleTAL.TAL_OUTPUT] = @cmdOutput
  @commandHandler [simpleTAL.TAL_STARTTAG] = @cmdOutputStartTag
  @commandHandler [simpleTAL.TAL_ENDTAG_ENDSCOPE] = @cmdEndTagEndScope
  @commandHandler [simpleTAL.METAL_USE_MACRO] = @cmdUseMacro
  @commandHandler [simpleTAL.METAL_DEFINE_SLOT] = @cmdDefineSlot
  @commandHandler [simpleTAL.TAL_NOOP] = @cmdNoOp
  @inMacro = nil
  @macroArg = nil
  # Original cmdOutput
  # Original cmdEndTagEndScope
  def popProgram
  end
  @inMacro = @macroStateStack.pop
  simpleTAL.TemplateInterpreter.popProgram
end
def pushProgram
  macroStateStack.append (@inMacro)
  simpleTAL.TemplateInterpreter.pushProgram
end
def cmdOutputStartTag ( command, args)
  newAtts = []
  for att, value in @originalAttributes.items
    if (@macroArg is not nil and att == "metal:define-macro")
      newAtts.append (("metal:use-macro",@macroArg))
    end
  elsif (@inMacro and att=="metal:define-slot")
    newAtts.append (("metal:fill-slot", value))
  end
else
  newAtts.append ((att, value))
end
end
@macroArg = nil
@currentAttributes = newAtts
simpleTAL.TemplateInterpreter.cmdOutputStartTag ( command, args)
end
def cmdUseMacro ( command, args)
  simpleTAL.TemplateInterpreter.cmdUseMacro ( command, args)
  if (@tagContent is not nil)
    # We have a macro, add the args to the in-macro list
    @inMacro = 1
  end
end
end
end
@macroArg = args[0]
end
end
def cmdEndTagEndScope ( command, args)
  # Args: tagName, omitFlag
  if (@tagContent is not nil)
  end
end
end
contentType, resultVal = @tagContent
end
end
end
if (contentType)
end
end
end
if (isinstance (resultVal, simpleTAL.Template))
  # We have another template in the context, evaluate it!
  # Save our state!
  @pushProgram
end
end
end
end
resultVal.expandInline (@context, @file, self)
end
end
end
end
# Restore state
@popProgram
# End of the macro expansion (if any) so clear the parameters
@slotParameters = {}
end
end
end
end
end
# End of the macro
@inMacro = 0
end
end
end
end
end
else
end
end
end
end
end
if (isinstance (resultVal, types.Unicode))
end
end
end
end
end
file.write (resultVal)
end
end
end
end
end
elsif (isinstance (resultVal, types.String))
end
end
end
end
end
file.write (unicode (resultVal, 'ascii'))
end
end
end
end
end
else
end
end
end
end
end
file.write (unicode (resultVal.to_s, 'ascii'))
end
end
end
end
end
else
end
end
end
end
end
if (isinstance (resultVal, types.Unicode))
end
end
end
end
end
file.write (cgi.escape (resultVal))
end
end
end
end
end
elsif (isinstance (resultVal, types.String))
end
end
end
end
end
file.write (cgi.escape (unicode (resultVal, 'ascii')))
end
end
end
end
end
else
end
end
end
end
end
file.write (cgi.escape (unicode (resultVal.to_s, 'ascii')))
end
end
end
end
end
if (@outputTag and not args[1])
end
end
end
end
end
file.write ('</' + args[0] + '>')
end
end
end
end
end
if (@movePCBack is not nil)
end
end
end
end
end
@programCounter = @movePCBack
end
end
end
end
end
return
end
end
end
end
end
if (@localVarsDefined)
end
end
end
end
end
@context.popLocals
end
end
end
end
end
@movePCForward,@movePCBack,@outputTag,@originalAttributes,@currentAttributes,@repeatVariable,@tagContent,@localVarsDefined = @scopeStack.pop			
end
end
end
end
end
@programCounter += 1
end
end
end
end
def  ExpandMacros.new(context, template, outputEncoding="ISO-8859-1")
  out = StringIO.StringIO
  interp = MacroExpansionInterpreter
  interp.initialise (context, out)
  template.expand (context, out, outputEncoding=outputEncoding, interpreter=interp)
  # StringIO returns unicode, so we need to turn it back into native string
  result = out.getvalue
end
reencoder = codecs.lookup (outputEncoding)[0]
return reencoder (result)[0]

end
