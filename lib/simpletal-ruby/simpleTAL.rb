=begin
simpleTAL Interpreter

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


The classes in this module implement the TAL language, expanding
both XML and HTML templates.

Module Dependencies: logging, simpleTALES, simpleTALTemplates
=end

begin
  require 'logging'
end
except
require 'DummyLogger as logging'
end
require 'xml.sax'
require 'cgi'
require 'StringIO'
require 'codecs'

require 'sgmlentitynames'

require 'simpletal'
require 'copy'

require 'FixedHTMLParser'

__version__ = simpletal.__version__

begin
  # Is PyXML's LexicalHandler available? 
  require 'xml/sax/saxlib/LexicalHandler'
end
end
use_lexical_handler = 1
end
rescue ImportError
  use_lexical_handler = 0
  class LexicalHandler


  end
end
begin
  # Is PyXML's DOM2SAX available?
  require 'xml.dom.ext.Dom2Sax'
end
end
use_dom2sax = 1
end
rescue ImportError
  use_dom2sax = 0

end
require 'simpleTALES'

METAL_NAME_URI="http://xml.zope.org/namespaces/metal"
TAL_NAME_URI="http://xml.zope.org/namespaces/tal"
TAL_DEFINE = 1
TAL_CONDITION = 2
TAL_REPEAT = 3
TAL_CONTENT = 4
TAL_REPLACE = 5
TAL_ATTRIBUTES = 6
TAL_OMITTAG = 7
TAL_START_SCOPE = 8
TAL_OUTPUT = 9
TAL_STARTTAG = 10
TAL_ENDTAG_ENDSCOPE = 11
TAL_NOOP = 13

METAL_USE_MACRO = 14
METAL_DEFINE_SLOT=15
METAL_FILL_SLOT=16
METAL_DEFINE_MACRO=17
METAL_NAME_REGEX = Regexp.new ("[a-zA-Z_][a-zA-Z0-9_]*")
SINGLETON_XML_REGEX = Regexp.new ('^<[^\s/>]+(?..\s*[^=>]+="[^">-1]+")*\s*/>')
ENTITY_REF_REGEX = Regexp.new (r'(?:&[a-zA-Z][\-\.a-zA-Z0-9]*[^\-\.a-zA-Z0-9])|(?..&#[xX]?[a-eA-E0-9]*[^0-9a-eA-E-1])')

HTML_FORBIDDEN_ENDTAG = {'AREA': 1, 'BASE': 1, 'BASEFONT': 1, 'BR': 1, 'COL': 1						,'FRAME': 1, 'HR': 1, 'IMG': 1, 'INPUT': 1, 'ISINDEX': 1						,'LINK': 1, 'META': 1, 'PARAM': 1}
HTML_BOOLEAN_ATTS = {'AREA:NOHREF': 1, 'IMG:ISMAP': 1, 'OBJECT:DECLARE': 1									, 'INPUT:CHECKED': 1, 'INPUT:DISABLED': 1, 'INPUT:READONLY': 1, 'INPUT:ISMAP': 1									, 'SELECT:MULTIPLE': 1, 'SELECT:DISABLED': 1									, 'OPTGROUP:DISABLED': 1									, 'OPTION:SELECTED': 1, 'OPTION:DISABLED': 1									, 'TEXTAREA:DISABLED': 1, 'TEXTAREA:READONLY': 1									, 'BUTTON:DISABLED': 1, 'SCRIPT:DEFER': 1}

class TemplateInterpreter
  def initialize
    @programStack = []
    @commandList = nil
    @symbolTable = nil
    @slotParameters = {}
    @commandHandler  = {}
    @commandHandler [TAL_DEFINE] = @cmdDefine
    @commandHandler [TAL_CONDITION] = @cmdCondition
    @commandHandler [TAL_REPEAT] = @cmdRepeat
    @commandHandler [TAL_CONTENT] = @cmdContent
    @commandHandler [TAL_ATTRIBUTES] = @cmdAttributes
    @commandHandler [TAL_OMITTAG] = @cmdOmitTag
    @commandHandler [TAL_START_SCOPE] = @cmdStartScope
    @commandHandler [TAL_OUTPUT] = @cmdOutput
    @commandHandler [TAL_STARTTAG] = @cmdOutputStartTag
    @commandHandler [TAL_ENDTAG_ENDSCOPE] = @cmdEndTagEndScope
    @commandHandler [METAL_USE_MACRO] = @cmdUseMacro
    @commandHandler [METAL_DEFINE_SLOT] = @cmdDefineSlot
    @commandHandler [TAL_NOOP] = @cmdNoOp
  end
  def tagAsText ( (tag,atts), singletonFlag=0)
    =begin This returns a tag as text.
    =end
    result = ["<"]
    result << tag
    for attName, attValue in atts
      result.append (' ')
      result << attName
      result.append ('="')
      result.append (cgi.escape (attValue, quote=1))
      result.append ('"')
    end
    if (singletonFlag)
      result.append (" />")
    end
  else
    result.append (">")
  end
  return "".join (result)
end
def initialise ( context, outputFile)
  @context = context
  @file = outputFile
end
def cleanState
  @scopeStack = []
  @programCounter = 0
  @movePCForward = nil
  @movePCBack = nil
  @outputTag = 1
  @originalAttributes = {}
  @currentAttributes = []
  # Used in repeat only.
  @repeatAttributesCopy = []
end
@currentSlots = {}
@repeatVariable = nil
@tagContent = nil
# tagState flag as to whether there are any local variables to pop
@localVarsDefined = 0
end
end
end
end
# Pass in the parameters
@currentSlots = @slotParameters
end
end
def popProgram
  vars, @commandList, @symbolTable = @programStack.pop
  @programCounter,@scopeStack,@slotParameters,@currentSlots, @movePCForward,@movePCBack,@outputTag,@originalAttributes,@currentAttributes,@repeatVariable,@tagContent,@localVarsDefined = vars
end
def pushProgram
  vars = (@programCounter					 ,@scopeStack		       ,@slotParameters		       ,@currentSlots					 ,@movePCForward					 ,@movePCBack					 ,@outputTag					 ,@originalAttributes					 ,@currentAttributes					 ,@repeatVariable					 ,@tagContent					 ,@localVarsDefined)
  programStack.append ((vars,@commandList, @symbolTable))

end
def execute ( template)
  @cleanState
  @commandList, @programCounter, programLength, @symbolTable = template.getProgram
  cmndList = @commandList
  while (@programCounter < programLength)
    cmnd = cmndList [@programCounter]
    #print "PC: %s  -  Executing command: %s" % (str (self.programCounter), str (cmnd))
    commandHandler[cmnd[0]] (cmnd[0], cmnd[1])
  end
end
end
def cmdDefine ( command, args)
  =begin args: [(isLocalFlag (Y/n), variableName, variablePath),...]
  Define variables in either the local or global context
  =end
  foundLocals = 0
  for isLocal, varName, varPath in args
    result = context.evaluate (varPath, @originalAttributes)
    if (isLocal)
      if (not foundLocals)
        foundLocals = 1
        @context.pushLocals 
      end
      context.setLocal (varName, result)
    end
  else
    context.addGlobal (varName, result)
  end
end
@localVarsDefined = foundLocals
@programCounter += 1
end
def cmdCondition ( command, args)
  =begin args: expression, endTagSymbol
  Conditionally continues with execution of all content contained
  by it.
  =end
  result = context.evaluate (args[0], @originalAttributes)
  #~ if (result is None or (not result)):
  conditionFalse = 0
end
if (result is nil)
  conditionFalse = 1
end
else
  if (not result): conditionFalse = 1
    begin
      temp = result.length
      if (temp == 0): conditionFalse = 1
      end
      except
      # Result is not a sequence.

    end
  end
  if (conditionFalse)
    # Nothing to output - evaluated to false.
    @outputTag = 0
  end
end
end
end
@tagContent = nil
end
end
end
end
@programCounter = @symbolTable[args[1]]
end
end
end
end
return
end
@programCounter += 1
end
def cmdRepeat ( command, args)
  =begin args: (varName, expression, endTagSymbol)
  Repeats anything in the cmndList
  =end		
  if (@repeatVariable is not nil)
    # We are already part way through a repeat
    # Restore any attributes that might have been changed.
    if (@currentAttributes != @repeatAttributesCopy)
    end
  end
end
end
@currentAttributes = copy.copy (@repeatAttributesCopy)
end
end
end
end
@outputTag = 1
end
end
end
end
@tagContent = nil
end
end
end
end
@movePCForward = nil
end
end
end
end
begin
end
end
end
end
@repeatVariable.increment
end
end
end
end
context.setLocal (args[0], @repeatVariable.getCurrentValue)
end
end
end
end
@programCounter += 1
end
end
end
end
return
end
end
end
end
rescue IndexError => e
end
end
end
end
# We have finished the repeat
@repeatVariable = nil
end
end
end
end
context.removeRepeat (args[0])
# The locals were pushed in context.addRepeat
@context.popLocals
end
end
end
end
end
@movePCBack = nil
end
end
end
end
end
# Suppress the final close tag and content
@tagContent = nil
end
end
end
end
end
@outputTag = 0
end
end
end
end
end
@programCounter = @symbolTable [args[2]]
# Restore the state of repeatAttributesCopy in case we are nested.
@repeatAttributesCopy = @scopeStack.pop
end
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
end
# The first time through this command
result = context.evaluate (args[1], @originalAttributes)
end
end
end
if (result is not nil and result == simpleTALES.DEFAULTVALUE)
  # Leave everything un-touched.
  @programCounter += 1
end
end
end
end
return
end
begin
  # We have three options, either the result is a natural sequence, an iterator., or something that can produce an iterator.
  isSequence = result.length
end
end
end
end
if (isSequence)
end
end
end
end
# Only setup if we have a sequence with length
@repeatVariable = simpleTALES.RepeatVariable (result)
end
end
end
end
else
end
end
end
end
# Delete the tags and their contents
@outputTag = 0
end
end
end
end
@programCounter = @symbolTable [args[2]]
end
end
end
end
return
end
except
# Not a natural sequence, can it produce an iterator?
if (hasattr (result, "__iter__") and result.__iter__).respond_to?( 'call' )
end
end
end
end
# We can get an iterator!
@repeatVariable = simpleTALES.IteratorRepeatVariable (result.__iter__)
end
end
end
end
elsif (hasattr (result, "next") and result.next).respond_to?( 'call' )
end
end
end
end
# Treat as an iterator
@repeatVariable = simpleTALES.IteratorRepeatVariable (result)
end
end
end
end
else
end
end
end
end
# Just a plain object, let's not loop
# Delete the tags and their contents
@outputTag = 0
end
end
end
end
@programCounter = @symbolTable [args[2]]
end
end
end
end
return
end
begin
  curValue = @repeatVariable.getCurrentValue
end
rescue IndexError => e
  # The iterator ran out of values before we started - treat as an empty list
  @outputTag = 0
end
end
end
end
@repeatVariable = nil
end
end
end
end
@programCounter = @symbolTable [args[2]]
end
end
end
end
return
end
end
end
end
# We really do want to repeat - so lets do it
@movePCBack = @programCounter
end
context.addRepeat (args[0], @repeatVariable, curValue)
# We keep the old state of the repeatAttributesCopy for nested loops
scopeStack.append (@repeatAttributesCopy)
end
end
end
end
# Keep a copy of the current attributes for this tag
@repeatAttributesCopy = copy.copy (@currentAttributes)
end
@programCounter += 1
end
def cmdContent ( command, args)
  =begin args: (replaceFlag, structureFlag, expression, endTagSymbol)
  Expands content
  =end		
  result = context.evaluate (args[2], @originalAttributes)
  if (result is nil)
    if (args[0])
      # Only output tags if this is a content not a replace
      @outputTag = 0
      # Output none of our content or the existing content, but potentially the tags
      @movePCForward = @symbolTable [args[3]]
    end
  end
  @programCounter += 1
  return
end
elsif (not result == simpleTALES.DEFAULTVALUE)
  # We have content, so let's suppress the natural content and output this!
  if (args[0])
  end
end
end
end
@outputTag = 0
end
end
end
end
@tagContent = (args[1], result)
end
end
end
end
@movePCForward = @symbolTable [args[3]]
end
end
end
end
@programCounter += 1
end
end
end
end
return
end
else
  # Default, let's just run through as normal
  @programCounter += 1
end
end
end
end
return
end
end
def cmdAttributes ( command, args)
  =begin args: [(attributeName, expression)]
  Add, leave, or remove attributes from the start tag
  =end
  attsToRemove = {}
  newAtts = []
  for attName, attExpr in args
    resultVal = context.evaluate (attExpr, @originalAttributes)
    if (resultVal is nil)
      # Remove this attribute from the current attributes
      attsToRemove [attName]=1
    end
  elsif (not resultVal == simpleTALES.DEFAULTVALUE)
    # We have a value - let's use it!
    attsToRemove [attName]=1
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
escapedAttVal = resultVal
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
# THIS IS NOT A BUG!
# Use Unicode in the Context object if you are not using Ascii
escapedAttVal = unicode (resultVal, 'ascii')
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
# THIS IS NOT A BUG!
# Use Unicode in the Context object if you are not using Ascii
escapedAttVal = unicode (resultVal)
end
end
end
end
end
newAtts.append ((attName, escapedAttVal))
end
end
end
end
end
# Copy over the old attributes 
for oldAttName, oldAttValue in @currentAttributes
end
if (not attsToRemove.has_key (oldAttName))
  newAtts.append ((oldAttName, oldAttValue))
end
end
@currentAttributes = newAtts
# Evaluate all other commands
@programCounter += 1
end
end
def cmdOmitTag ( command, args)
  =begin args: expression
  Conditionally turn off tag output
  =end
  result = context.evaluate (args, @originalAttributes)
  if (result is not nil and result)
    # Turn tag output off
    @outputTag = 0
  end
  @programCounter += 1
end
def cmdOutputStartTag ( command, args)
  # Args: tagName
  tagName, singletonTag = args
end
end
end
if (@outputTag)
end
end
end
if (@tagContent is nil and singletonTag)
  file.write (@tagAsText ((tagName, @currentAttributes), 1))
end
end
end
else
  file.write (@tagAsText ((tagName, @currentAttributes)))
end
end
end
if (@movePCForward is not nil)
end
end
end
@programCounter = @movePCForward
end
end
end
return
end
end
end
@programCounter += 1
end
end
end
return
end
def cmdEndTagEndScope ( command, args)
  # Args: tagName, omitFlag, singletonTag
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
if (isinstance (resultVal, Template))
  # We have another template in the context, evaluate it!
  # Save our state!
  @pushProgram
end
end
end
end
resultVal.expandInline (@context, @file, self)
end
# Restore state
@popProgram
# End of the macro expansion (if any) so clear the parameters
@slotParameters = {}
end
end
end
end
else
end
end
end
end
if (isinstance (resultVal, types.Unicode))
end
end
end
end
file.write (resultVal)
end
end
end
end
elsif (isinstance (resultVal, types.String))
end
end
end
end
# THIS IS NOT A BUG!
# Use Unicode in the Context object if you are not using Ascii
file.write (unicode (resultVal, 'ascii'))
end
end
end
end
else
end
end
end
end
# THIS IS NOT A BUG!
# Use Unicode in the Context object if you are not using Ascii
file.write (unicode (resultVal))
end
end
end
end
else
end
end
end
end
if (isinstance (resultVal, types.Unicode))
end
end
end
end
file.write (cgi.escape (resultVal))
end
end
end
end
elsif (isinstance (resultVal, types.String))
end
end
end
end
# THIS IS NOT A BUG!
# Use Unicode in the Context object if you are not using Ascii
file.write (cgi.escape (unicode (resultVal, 'ascii')))
end
end
end
end
else
end
end
end
end
# THIS IS NOT A BUG!
# Use Unicode in the Context object if you are not using Ascii
file.write (cgi.escape (unicode (resultVal)))
end
end
end
end
if (@outputTag and not args[1])
end
end
end
end
# Do NOT output end tag if a singleton with no content
if not (args[2] and @tagContent is nil)
end
end
end
end
file.write ('</' + args[0] + '>')
end
end
end
end
if (@movePCBack is not nil)
end
end
end
end
@programCounter = @movePCBack
end
end
end
end
return
end
end
end
end
if (@localVarsDefined)
end
end
end
end
@context.popLocals
end
end
end
end
@movePCForward,@movePCBack,@outputTag,@originalAttributes,@currentAttributes,@repeatVariable,@tagContent,@localVarsDefined = @scopeStack.pop			
end
end
end
end
@programCounter += 1
end
end
def cmdOutput ( command, args)
  file.write (args)
  @programCounter += 1
end
def cmdStartScope ( command, args)
  =begin args: (originalAttributes, currentAttributes)
  Pushes the current state onto the stack, and sets up the new state
  =end
  scopeStack.append ((@movePCForward								,@movePCBack								,@outputTag								,@originalAttributes								,@currentAttributes								,@repeatVariable								,@tagContent								,@localVarsDefined))

  @movePCForward = nil
  @movePCBack = nil
  @outputTag = 1
  @originalAttributes = args[0]
  @currentAttributes = args[1]
  @repeatVariable = nil
  @tagContent = nil
  @localVarsDefined = 0
  @programCounter += 1				
end
def cmdNoOp ( command, args)
  @programCounter += 1
end
def cmdUseMacro ( command, args)
  =begin args: (macroExpression, slotParams, endTagSymbol)
  Evaluates the expression, if it resolves to a SubTemplate it then places
  the slotParams into currentSlots and then jumps to the end tag
  =end
  value = context.evaluate (args[0], @originalAttributes)
  if (value is nil)
    # Don't output anything
    @outputTag = 0
    # Output none of our content or the existing content
    @movePCForward = @symbolTable [args[2]]
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
end
return
end
end
if (not value == simpleTALES.DEFAULTVALUE and isinstance (value, SubTemplate))
  # We have a macro, so let's use it
  @outputTag = 0
end
end
end
end
@slotParameters = args[1]
end
end
end
end
@tagContent = (1, value)
# NOTE: WE JUMP STRAIGHT TO THE END TAG, NO OTHER TAL/METAL COMMANDS ARE EVALUATED.
@programCounter = @symbolTable [args[2]]
end
end
end
end
end
return
end
end
else
  # Default, let's just run through as normal
  @programCounter += 1
end
end
end
end
return
end
end
def cmdDefineSlot ( command, args)
  =begin args: (slotName, endTagSymbol)
  If the slotName is filled then that is used, otherwise the original conent
  is used.
  =end
  if (currentSlots.has_key (args[0]))
    # This slot is filled, so replace us with that content
    @outputTag = 0
  end
end
end
end
@tagContent = (1, @currentSlots [args[0]])
end
end
end
end
# Output none of our content or the existing content
# NOTE: NO FURTHER TAL/METAL COMMANDS ARE EVALUATED
@programCounter = @symbolTable [args[1]]
end
end
end
end
return
end
end
end
end
# Slot isn't filled, so just use our own content
@programCounter += 1
end
return
end
end
class  HTMLTemplateInterpreter.new(TemplateInterpreter)
  def initialize ( minimizeBooleanAtts = 0)
    TemplateInterpreter.__init__
    @minimizeBooleanAtts = minimizeBooleanAtts
    if (minimizeBooleanAtts)
      # Override the tagAsText method for this instance
      @tagAsText = @tagAsTextMinimizeAtts
    end
  end
  def tagAsTextMinimizeAtts ( (tag,atts), singletonFlag=0)
    =begin This returns a tag as text.
    =end
    result = ["<"]
    result << tag
    upperTag = tag.upcase
    for attName, attValue in atts
      if (HTML_BOOLEAN_ATTS.has_key (sprintf( '%s:%s', (upperTag, ) attName.upcase)))
        # We should output a minimised boolean value
        result.append (' ')
      end
    end
  end
end
end
result << attName
end
else
  result.append (' ')
  result << attName
  result.append ('="')
  result.append (cgi.escape (attValue, quote=1))
  result.append ('"')
end
end
if (singletonFlag)
  result.append (" />")
end
else
  result.append (">")
end
return "".join (result)
end
end
class Template
  def initialize ( commands, macros, symbols, doctype = nil)
    @commandList = commands
    @macros = macros
    @symbolTable = symbols
    @doctype = doctype
    # Setup the macros
    for macro in @macros.values
    end
  end
end
end
macro.setParentTemplate
end
end
end
end
# Setup the slots
for cmnd, arg in @commandList
end
end
end
end
if (cmnd == METAL_USE_MACRO)
  # Set the parent of each slot
  slotMap = arg[1]
end
end
end
end
end
for slot in slotMap.values
end
end
end
end
end
slot.setParentTemplate

end
end
end
def expand ( context, outputFile, outputEncoding=nil, interpreter=nil)
  =begin This method will write to the outputFile, using the encoding specified,
  the expanded version of this template.  The context ed in is used to resolve
  all expressions with the template.
  =end
  # This method must wrap outputFile if required by the encoding, and write out
  # any template pre-amble (DTD, Encoding, etc)
  expandInline (context, outputFile, interpreter)
end
end
def expandInline ( context, outputFile, interpreter=nil)
  =begin Internally used when expanding a template that is part of a context.=begin
  if (interpreter is nil)
    ourInterpreter = TemplateInterpreter
    ourInterpreter.initialise (context, outputFile)
  end
else
  ourInterpreter = interpreter
end
begin
  ourInterpreter.execute
end
rescue UnicodeError => unierror
  logging.error ("UnicodeError caused by placing a non-Unicode string in the Context object.")
  raise simpleTALES.ContextContentException ("Found non-unicode string in Context!")
end
end
def getProgram
  =end Returns a tuple of (commandList, startPoint, endPoint, symbolTable) =end
  return (@commandList, 0, @commandList.length, @symbolTable)
end
def to_s
  result = "Commands:\n"
  index = 0
  for cmd in @commandList
    if (cmd[0] != METAL_USE_MACRO)
      result = result + sprintf( "\n[%s] %s", (str ) (index), cmd.to_s)
    end
  else
    result = result + sprintf( "\n[%s] %s, (%s{", (str ) (index), cmd[0].to_s, cmd[1][0].to_s)
    for slot in cmd[1][1].keys
      result = result + sprintf( "%s: %s", (slot, ) cmd[1][1][slot].to_s)
    end
    result = result + sprintf( "}, %s)", str ) (cmd[1][2])
  end
  index += 1
end
result = result + "\n\nSymbols:\n"
for symbol in @symbolTable.keys
  result = result + "Symbol: " + symbol.to_s + " points to: " + @symbolTable[symbol].to_s + ", which is command: " + @commandList[@symbolTable[symbol]].to_s + "\n"	
end
result = result + "\n\nMacros:\n"
for macro in @macros.keys
  result = result + "Macro: " + macro.to_s + " value of: " + @macros[macro].to_s
end
return result
end
end
class  SubTemplate.new(Template)
  =begin A SubTemplate is part of another template, and is used for the METAL implementation.
  The two uses for this class are
  1 - metal:define-macro results in a SubTemplate that is the macro
  2 - metal:fill-slot results in a SubTemplate that is a parameter to metal:use-macro
  =end
  def initialize ( startRange, endRangeSymbol)
    =begin The parentTemplate is the template for which we are a sub-template.
    The startRange and endRange are indexes into the parent templates command list, 
    and defines the range of commands that we can execute
    =end
    Template.__init__ ( [], {}, {})
    @startRange = startRange
    @endRangeSymbol = endRangeSymbol
  end
  def setParentTemplate ( parentTemplate)
    @parentTemplate = parentTemplate
    @commandList = parentTemplate.commandList
    @symbolTable = parentTemplate.symbolTable
  end
  def getProgram
    =begin Returns a tuple of (commandList, startPoint, endPoint, symbolTable) =begin
    return (@commandList, @startRange, @symbolTable[@endRangeSymbol]+1, @symbolTable)
  end
  def to_s
    endRange = @symbolTable [@endRangeSymbol]
    result = sprintf( "SubTemplate from %s to %s\n", (str ) (@startRange), endRange.to_s)
    return result
  end
end
class  HTMLTemplate.new(Template)
  =endA specialised form of a template that knows how to output HTML
  =begin
  def initialize ( commands, macros, symbols, doctype = nil, minimizeBooleanAtts = 0)
    @minimizeBooleanAtts = minimizeBooleanAtts
    Template.__init__ ( commands, macros, symbols, doctype = nil)
  end
  def expand ( context, outputFile, outputEncoding="ISO-8859-1",interpreter=nil)
    =end This method will write to the outputFile, using the encoding specified,
    the expanded version of this template.  The context ed in is used to resolve
    all expressions with the template.
    =begin
    # This method must wrap outputFile if required by the encoding, and write out
    # any template pre-amble (DTD, Encoding, etc)
    encodingFile = codecs.lookup (outputEncoding)[3](outputFile, 'replace')
  end
  expandInline (context, encodingFile, interpreter)
end
def expandInline ( context, outputFile, interpreter=nil)
  =end Ensure we use the HTMLTemplateInterpreter=end
  if (interpreter is nil)
    ourInterpreter =  HTMLTemplateInterpreter.new(minimizeBooleanAtts = @minimizeBooleanAtts)
    ourInterpreter.initialise (context, outputFile)
  end
else
  ourInterpreter = interpreter
end
Template.expandInline ( context, outputFile, ourInterpreter)
end
end
class  XMLTemplate.new(Template)
  =beginA specialised form of a template that knows how to output XML
  =end
  def initialize ( commands, macros, symbols, doctype = nil)
    Template.__init__ ( commands, macros, symbols)
    @doctype = doctype
  end
  def expand ( context, outputFile, outputEncoding="iso-8859-1", docType=nil, suppressXMLDeclaration=0,interpreter=nil)
    =begin This method will write to the outputFile, using the encoding specified,
    the expanded version of this template.  The context ed in is used to resolve
    all expressions with the template.
    =end
    # This method must wrap outputFile if required by the encoding, and write out
    # any template pre-amble (DTD, Encoding, etc)
    # Write out the XML prolog
    encodingFile = codecs.lookup (outputEncoding)[3](outputFile, 'replace')
  end
  if (not suppressXMLDeclaration)
    if (outputEncoding.downcase != "utf-8")
      encodingFile.write (sprintf( '<?xml version="1.0" encoding="%s"?>\n', outputEncoding.downcase) )
    end
  else
    encodingFile.write ('<?xml version="1.0"?>\n')
  end
end
if not docType and @doctype
  docType = @doctype
end
if docType
  encodingFile.write (docType)
  encodingFile.write ('\n')
end
expandInline (context, encodingFile, interpreter)
end
end
class TemplateCompiler
  def initialize
    =begin Initialise a template compiler.
    =end
    @commandList = []
    @tagStack = []
    @symbolLocationTable = {}
    @macroMap = {}
    @endTagSymbol = 1

    @commandHandler  = {}
    @commandHandler [TAL_DEFINE] = @compileCmdDefine
    @commandHandler [TAL_CONDITION] = @compileCmdCondition
    @commandHandler [TAL_REPEAT] = @compileCmdRepeat
    @commandHandler [TAL_CONTENT] = @compileCmdContent
    @commandHandler [TAL_REPLACE] = @compileCmdReplace
    @commandHandler [TAL_ATTRIBUTES] = @compileCmdAttributes
    @commandHandler [TAL_OMITTAG] = @compileCmdOmitTag
    # Metal commands
    @commandHandler [METAL_USE_MACRO] = @compileMetalUseMacro
  end
  @commandHandler [METAL_DEFINE_SLOT] = @compileMetalDefineSlot
  @commandHandler [METAL_FILL_SLOT] = @compileMetalFillSlot
  @commandHandler [METAL_DEFINE_MACRO] = @compileMetalDefineMacro
  # Default namespaces
  setTALPrefix ('tal')
end
@tal_namespace_prefix_stack = []
@metal_namespace_prefix_stack = []
tal_namespace_prefix_stack.append ('tal')
setMETALPrefix ('metal')
metal_namespace_prefix_stack.append ('metal')
@log = logging.getLogger ("simpleTAL.TemplateCompiler")
end
def setTALPrefix ( prefix)
  @tal_namespace_prefix = prefix
  @tal_namespace_omittag = sprintf( '%s:omit-tag', @tal_namespace_prefix )
  @tal_attribute_map = {}
  @tal_attribute_map [sprintf( '%s:attributes', prefix] ) = TAL_ATTRIBUTES
  @tal_attribute_map [sprintf( '%s:content', prefix]= ) TAL_CONTENT
  @tal_attribute_map [sprintf( '%s:define', prefix] ) = TAL_DEFINE
  @tal_attribute_map [sprintf( '%s:replace', prefix] ) = TAL_REPLACE
  @tal_attribute_map [sprintf( '%s:omit-tag', prefix] ) = TAL_OMITTAG
  @tal_attribute_map [sprintf( '%s:condition', prefix] ) = TAL_CONDITION
  @tal_attribute_map [sprintf( '%s:repeat', prefix] ) = TAL_REPEAT
end
def setMETALPrefix ( prefix)
  @metal_namespace_prefix = prefix
  @metal_attribute_map = {}
  @metal_attribute_map [sprintf( '%s:define-macro', prefix] ) = METAL_DEFINE_MACRO
  @metal_attribute_map [sprintf( '%s:use-macro', prefix] ) = METAL_USE_MACRO
  @metal_attribute_map [sprintf( '%s:define-slot', prefix] ) = METAL_DEFINE_SLOT
  @metal_attribute_map [sprintf( '%s:fill-slot', prefix] ) = METAL_FILL_SLOT
end
def popTALNamespace
  newPrefix = @tal_namespace_prefix_stack.pop
  setTALPrefix (newPrefix)
end
def popMETALNamespace
  newPrefix = @metal_namespace_prefix_stack.pop
  setMETALPrefix (newPrefix)
end
def tagAsText ( (tag,atts), singletonFlag=0)
  =begin This returns a tag as text.
  =end
  result = ["<"]
  result << tag
  for attName, attValue in atts
    result.append (' ')
    result << attName
    result.append ('="')
    result.append (cgi.escape (attValue, quote=1))
    result.append ('"')
  end
  if (singletonFlag)
    result.append (" />")
  end
else
  result.append (">")
end
return "".join (result)
end
def getTemplate
  template =  Template.new(@commandList, @macroMap, @symbolLocationTable)
  return template
end
def addCommand ( command)
  if (command[0] == TAL_OUTPUT and (@commandList.length > 0) and @commandList[-1][0] == TAL_OUTPUT)
    # We can combine output commands
    @commandList[-1] = (TAL_OUTPUT, @commandList[-1][1] + command[1])
  end
else
  @commandList << command
end
end
def addTag ( tag, tagProperties={})
  =begin Used to add a tag to the stack.  Various properties can be ed in the dictionary
  as being information required by the tag.
  Currently supported properties are
  'command'         -  The.new(command,args) tuple associated with this command
  'originalAtts'    - The original attributes that include any metal/tal attributes
  'endTagSymbol'    - The symbol associated with the end tag for this element
  'popFunctionList' - A list of functions to execute when this tag is popped
  'singletonTag'    - A boolean to indicate that this is a singleton flag
  =end
  # Add the tag to the tagStack (list of tuples (tag, properties, useMacroLocation))
  log.debug (sprintf( "Adding tag %s to stack", tag[0]) )
end
command = tagProperties.get ('command',nil)
originalAtts = tagProperties.get ('originalAtts', nil)
singletonTag = tagProperties.get ('singletonTag', 0)
if (command is not nil)
  if (command[0] == METAL_USE_MACRO)
    tagStack.append ((tag, tagProperties, @commandList.length+1))
  end
else
  tagStack.append ((tag, tagProperties, nil))
end
end
else
  tagStack.append ((tag, tagProperties, nil))
end
if (command is not nil)
  # All tags that have a TAL attribute on them start with a 'start scope'
  addCommand((TAL_START_SCOPE, (originalAtts, tag[1])))
end
end
end
end
# Now we add the TAL command
addCommand(command)
end
else
  # It's just a straight output, so create an output command and append it
  addCommand((TAL_OUTPUT, @tagAsText (tag, singletonTag)))
end
end
def popTag ( tag, omitTagFlag=0)
  =begin omitTagFlag is used to control whether the end tag should be included in the
  output or not.  In HTML 4.01 there are several tags which should never have
end tags, this flag allows the template compiler to specify that these
should not be output.
=end
while (@tagStack.length > 0)
  oldTag, tagProperties, useMacroLocation = @tagStack.pop
  endTagSymbol = tagProperties.get ('endTagSymbol', nil)
  popCommandList = tagProperties.get ('popFunctionList', [])
  singletonTag = tagProperties.get ('singletonTag', 0)
  for func in popCommandList
    apply (func, )
  end
  log.debug (sprintf( "Popped tag %s off stack", oldTag[0]) )
  if (oldTag[0] == tag[0])
    # We've found the right tag, now check to see if we have any TAL commands on it
    if (endTagSymbol is not nil)
    end
  end
end
end
end
# We have a command (it's a TAL tag)
# Note where the end tag symbol should point (i.e. the next command)
@symbolLocationTable [endTagSymbol] = @commandList.length
end
end
end
end
end
# We need a "close scope and tag" command
addCommand((TAL_ENDTAG_ENDSCOPE, (tag[0], omitTagFlag, singletonTag)))
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
elsif (omitTagFlag == 0 and singletonTag == 0)
end
end
end
end
end
# We are popping off an un-interesting tag, just add the close as text
addCommand((TAL_OUTPUT, '</' + tag[0] + '>'))
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
else
end
end
end
end
end
# We are suppressing the output of this tag, so just return
return
end
else
  # We have a different tag, which means something like <br> which never closes is in 
  # between us and the real tag.
  # If the tag that we did pop off has a command though it means un-balanced TAL tags!
  if (endTagSymbol is not nil)
  end
end
end
end
end
# ERROR
msg = sprintf( "TAL/METAL Elements must be balanced - found close tag %s expecting %s", (tag[0], ) oldTag[0])
end
end
end
end
end
log.error (msg)
end
end
end
end
end
raise  TemplateParseException.new(tagAsText(oldTag), msg)
end
end
log.error (sprintf( "Close tag %s found with no corresponding open tag.", tag[0]) )
raise  TemplateParseException.new(sprintf( "</%s>", tag[0], ) "Close tag encountered with no corresponding open tag.")
end
def parseStartTag ( tag, attributes, singletonElement=0)
  # Note down the tag we are handling, it will be used for error handling during
  # compilation
  @currentStartTag = (tag, attributes)

end
end
end
# Look for tal/metal attributes
foundTALAtts = []
end
end
end
foundMETALAtts = []
end
end
end
foundCommandsArgs = {}
end
end
end
cleanAttributes = []
end
end
end
originalAttributes = {}
end
end
end
tagProperties = {}
end
end
end
popTagFuncList = []
end
end
end
TALElementNameSpace = 0
end
end
end
prefixToAdd = ""
end
end
end
tagProperties ['singletonTag'] = singletonElement
end
end
end
# Determine whether this element is in either the METAL or TAL namespace
if (tag.find (':') > 0)
  # We have a namespace involved, so let's look to see if its one of ours
  namespace = tag[0:tag.find (':')]
end
end
end
end
if (namespace == @metal_namespace_prefix)
end
end
end
end
TALElementNameSpace = 1
end
end
end
end
prefixToAdd = @metal_namespace_prefix +":"
end
end
end
end
elsif (namespace == @tal_namespace_prefix)
end
end
end
end
TALElementNameSpace = 1
end
end
end
end
prefixToAdd = @tal_namespace_prefix +":"
end
end
end
end
if (TALElementNameSpace)
end
end
end
end
# We should treat this an implicit omit-tag
foundTALAtts << TAL_OMITTAG
end
end
end
end
# Will go to default, i.e. yes
foundCommandsArgs [TAL_OMITTAG] = ""
end
end
end
end
for att, value in attributes
end
end
end
end
originalAttributes [att] = value
end
end
end
end
if (TALElementNameSpace and not att.find (':') > 0)
  # This means that the attribute name does not have a namespace, so use the prefix for this tag.
  commandAttName = prefixToAdd + att
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
commandAttName = att
end
end
end
end
end
log.debug (sprintf( "Command name is now %s", commandAttName) )
end
end
end
end
end
if (att[0..5-1] == "xmlns")
end
end
end
end
end
# We have a namespace declaration.
prefix = att[6..-1]
end
end
end
end
end
if (value == METAL_NAME_URI)
end
end
end
end
end
# It's a METAL namespace declaration
if (prefix.length > 0)
end
end
end
end
end
metal_namespace_prefix_stack.append (@metal_namespace_prefix)
end
end
end
end
end
setMETALPrefix (prefix)
end
end
end
end
end
# We want this function called when the scope ends
popTagFuncList.append (@popMETALNamespace)
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
# We don't allow METAL/TAL to be declared as a default
msg = "Can not use METAL name space by default, a prefix must be provided."
end
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
end
end
end
elsif (value == TAL_NAME_URI)
end
end
end
end
end
# TAL this time
if (prefix.length > 0)
end
end
end
end
end
tal_namespace_prefix_stack.append (@tal_namespace_prefix)
end
end
end
end
end
setTALPrefix (prefix)
end
end
end
end
end
# We want this function called when the scope ends
popTagFuncList.append (@popTALNamespace)
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
# We don't allow METAL/TAL to be declared as a default
msg = "Can not use TAL name space by default, a prefix must be provided."
end
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
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
# It's nothing special, just an ordinary namespace declaration
cleanAttributes.append ((att, value))
end
end
end
end
end
elsif (tal_attribute_map.has_key (commandAttName))
end
end
end
end
end
# It's a TAL attribute
cmnd = @tal_attribute_map [commandAttName]
end
end
end
end
end
if (cmnd == TAL_OMITTAG and TALElementNameSpace)
end
end
end
end
end
log.warn ("Supressing omit-tag command present on TAL or METAL element")
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
foundCommandsArgs [cmnd] = value
end
end
end
end
end
foundTALAtts << cmnd
end
end
end
end
end
elsif (metal_attribute_map.has_key (commandAttName))
end
end
end
end
end
# It's a METAL attribute
cmnd = @metal_attribute_map [commandAttName]
end
end
end
end
end
foundCommandsArgs [cmnd] = value
end
end
end
end
end
foundMETALAtts << cmnd
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
cleanAttributes.append ((att, value))
end
end
end
end
end
tagProperties ['popFunctionList'] = popTagFuncList

end
end
end
end
end
# This might be just content
if ((foundTALAtts.length + foundMETALAtts.length) == 0)
end
end
end
end
end
# Just content, add it to the various stacks
addTag ((tag, cleanAttributes), tagProperties)
end
end
end
end
end
return
end
# Create a symbol for the end of the tag - we don't know what the offset is yet
@endTagSymbol += 1
end
end
end
end
tagProperties ['endTagSymbol'] = @endTagSymbol
end
end
end
end
# Sort the METAL commands
foundMETALAtts.sort
end
end
end
end
# Sort the tags by priority
foundTALAtts.sort
end
end
end
end
# We handle the METAL before the TAL
allCommands = foundMETALAtts + foundTALAtts
end
end
end
end
firstTag = 1
end
end
end
end
for talAtt in allCommands
end
end
end
end
# Parse and create a command for each 
cmnd = @commandHandler [talAtt](foundCommandsArgs[talAtt])
end
end
end
end
if (cmnd is not nil)
end
end
end
end
if (firstTag)
end
end
end
end
# The first one needs to add the tag
firstTag = 0
end
end
end
end
tagProperties ['originalAtts'] = originalAttributes
end
end
end
end
tagProperties ['command'] = cmnd
end
end
end
end
addTag ((tag, cleanAttributes), tagProperties)
end
end
end
end
else
end
end
end
end
# All others just append
addCommand(cmnd)
end
end
end
end
if (firstTag)
end
end
end
end
tagProperties ['originalAtts'] = originalAttributes
end
end
end
end
tagProperties ['command'] = (TAL_STARTTAG, (tag, singletonElement))
end
end
end
end
addTag ((tag, cleanAttributes), tagProperties)
end
end
end
end
else
end
end
end
end
# Add the start tag command in as a child of the last TAL command
addCommand((TAL_STARTTAG, (tag,singletonElement)))
end
end
def parseEndTag ( tag)
  =begin Just pop the tag and related commands off the stack. =begin
  popTag ((tag,nil))
end
def parseData ( data)
  # Just add it as an output
  addCommand((TAL_OUTPUT, data))
end
def compileCmdDefine ( argument)
  # Compile a define command, resulting argument is:
  # [(isLocalFlag (Y/n), variableName, variablePath),...]
  # Break up the list of defines first
  commandArgs = []
  # We only want to match semi-colons that are not escaped
  argumentSplitter =  Regexp.new ('(?<!;);(?!;)')
end
end
end
end
for defineStmt in argumentSplitter.split (argument)
  #  remove any leading space and un-escape any semi-colons
  defineStmt = defineStmt.lstrip.replace (';;', ';')
  # Break each defineStmt into pieces "[local|global] varName expression"
  stmtBits = defineStmt.split (' ')
end
end
end
end
end
end
isLocal = 1
end
end
end
end
end
end
if (stmtBits.length < 2)
end
end
end
end
end
end
# Error, badly formed define command
msg = sprintf( "Badly formed define command '%s'.  Define commands must be of the form: '[local|global] varName expression[;[local|global] varName expression]'", argument )
end
end
end
end
end
end
log.error (msg)
end
end
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
end
end
end
end
# Assume to start with that >2 elements means a local|global flag
if (stmtBits.length > 2)
end
end
end
end
end
end
if (stmtBits[0] == 'global')
end
end
end
end
end
end
isLocal = 0
end
end
end
end
end
end
varName = stmtBits[1]
end
end
end
end
end
end
expression = ' '.join (stmtBits[2..-1])
end
end
end
end
end
end
elsif (stmtBits[0] == 'local')
end
end
end
end
end
end
varName = stmtBits[1]
end
end
end
end
end
end
expression = ' '.join (stmtBits[2..-1])
end
end
end
end
end
end
else
  # Must be a space in the expression that caused the >3 thing
  varName = stmtBits[0]
end
end
end
end
end
end
end
expression = ' '.join (stmtBits[1..-1])
end
end
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
end
end
# Only two bits
varName = stmtBits[0]
end
end
end
end
end
end
end
expression = ' '.join (stmtBits[1..-1])
end
end
end
end
end
end
end
commandArgs.append ((isLocal, varName, expression))
end
end
end
end
end
end
end
return (TAL_DEFINE, commandArgs)
end
end
end
end
end
def compileCmdCondition ( argument)
  # Compile a condition command, resulting argument is:
  # path, endTagSymbol
  # Sanity check
  if (argument.length == 0)
  end
end
end
# No argument passed
msg = "No argument ed!  condition commands must be of the form: 'path'"
end
end
end
log.error (msg)
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
end
return (TAL_CONDITION, (argument, @endTagSymbol))
end
def compileCmdRepeat ( argument)
  # Compile a repeat command, resulting argument is:
  # (varname, expression, endTagSymbol)
  attProps = argument.split (' ')
end
end
end
if (attProps.length < 2)
end
end
end
# Error, badly formed repeat command
msg = sprintf( "Badly formed repeat command '%s'.  Repeat commands must be of the form: 'localVariable path'", argument )
end
end
end
log.error (msg)
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
end
varName = attProps [0]
end
end
end
expression = " ".join (attProps[1..-1])
end
end
end
return (TAL_REPEAT, (varName, expression, @endTagSymbol))
end
def compileCmdContent ( argument, replaceFlag=0)
  # Compile a content command, resulting argument is
  # (replaceFlag, structureFlag, expression, endTagSymbol)
  # Sanity check
  if (argument.length == 0)
  end
end
end
# No argument passed
msg = "No argument ed!  content/replace commands must be of the form: 'path'"
end
end
end
log.error (msg)
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)

end
end
end
structureFlag = 0
end
end
end
attProps = argument.split (' ')
end
end
end
if (attProps.length > 1)
end
end
end
if (attProps[0] == "structure")
end
end
end
structureFlag = 1
end
end
end
express = " ".join (attProps[1..-1])
end
end
end
elsif (attProps[1] == "text")
end
end
end
structureFlag = 0
end
end
end
express = " ".join (attProps[1..-1])
end
end
end
else
  # It's not a type selection after all - assume it's part of the path
  express = argument
end
end
end
end
else
end
end
end
end
express = argument
end
end
end
end
return (TAL_CONTENT, (replaceFlag, structureFlag, express, @endTagSymbol))
end
end
def compileCmdReplace ( argument)
  return compileCmdContent (argument, replaceFlag=1)
end
def compileCmdAttributes ( argument)
  # Compile tal:attributes into attribute command
  # Argument: [(attributeName, expression)]
  # Break up the list of attribute settings first
  commandArgs = []
  # We only want to match semi-colons that are not escaped
  argumentSplitter =  Regexp.new ('(?<!;);(?!;)')
end
end
end
end
for attributeStmt in argumentSplitter.split (argument)
  #  remove any leading space and un-escape any semi-colons
  attributeStmt = attributeStmt.lstrip.replace (';;', ';')
end
end
end
end
end
# Break each attributeStmt into name and expression
stmtBits = attributeStmt.split (' ')
end
end
end
end
end
if (stmtBits.length < 2)
end
# Error, badly formed attributes command
msg = sprintf( "Badly formed attributes command '%s'.  Attributes commands must be of the form: 'name expression[;name expression]'", argument )
end
end
end
end
log.error (msg)
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
end
end
attName = stmtBits[0]
end
end
end
end
attExpr = " ".join (stmtBits[1..-1])
end
end
end
end
commandArgs.append ((attName, attExpr))
end
end
end
end
return (TAL_ATTRIBUTES, commandArgs)
end
end
def compileCmdOmitTag ( argument)
  # Compile a condition command, resulting argument is:
  # path
  # If no argument is given then set the path to default
  if (argument.length == 0)
  end
end
end
expression = "default"
end
end
end
else
end
end
end
expression = argument
end
end
end
return (TAL_OMITTAG, expression)
end
end
end
# METAL compilation commands go here
def compileMetalUseMacro ( argument)
end
end
end
# Sanity check
if (argument.length == 0)
end
end
end
# No argument passed
msg = "No argument ed!  use-macro commands must be of the form: 'use-macro: path'"
end
end
end
log.error (msg)
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
end
cmnd = (METAL_USE_MACRO, (argument, {}, @endTagSymbol))
end
end
end
log.debug (sprintf( "Returning METAL_USE_MACRO: %s", str ) (cmnd))
end
end
end
return cmnd
end
def compileMetalDefineMacro ( argument)
  if (argument.length == 0)
    # No argument passed
    msg = "No argument ed!  define-macro commands must be of the form: 'define-macro: name'"
  end
end
end
end
log.error (msg)
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
# Check that the name of the macro is valid
if (METAL_NAME_REGEX.match (argument).end( 0 ) != argument.length)
end
end
end
end
end
msg = sprintf( "Macro name %s is invalid.", argument )
end
end
end
end
end
log.error (msg)
end
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
if (macroMap.has_key (argument))
  msg = sprintf( "Macro name %s is already defined!", argument )
  log.error (msg)
  raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
  # The macro starts at the next command.
  macro =  SubTemplate.new(@commandList.length, @endTagSymbol)
end
end
@macroMap [argument] = macro
return nil
end
def compileMetalFillSlot ( argument)
  if (argument.length == 0)
    # No argument passed
    msg = "No argument ed!  fill-slot commands must be of the form: 'fill-slot: name'"
  end
end
end
end
log.error (msg)
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
# Check that the name of the macro is valid
if (METAL_NAME_REGEX.match (argument).end( 0 ) != argument.length)
end
end
end
end
end
msg = sprintf( "Slot name %s is invalid.", argument )
end
end
end
end
end
log.error (msg)
end
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
# Determine what use-macro statement this belongs to by working through the list backwards
ourMacroLocation = nil
end
end
end
location = @tagStack.length - 1
while (ourMacroLocation is nil)
  macroLocation = @tagStack[location][2]
  if (macroLocation is not nil)
    ourMacroLocation = macroLocation
  end
else
  location -= 1
  if (location < 0)
    msg = "metal:fill-slot must be used inside a metal:use-macro call"
    log.error (msg)
    raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
    # Get the use-macro command we are going to adjust
    cmnd, args = @commandList [ourMacroLocation]
  end
end
end
end
log.debug (sprintf( "Use macro argument: %s", str ) (args))
macroName, slotMap, endSymbol = args
# Check that the name of the slot is valid
if (METAL_NAME_REGEX.match (argument).end( 0 ) != argument.length)
end
end
end
end
msg = sprintf( "Slot name %s is invalid.", argument )
end
end
end
end
log.error (msg)
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
if (slotMap.has_key (argument))
  msg = sprintf( "Slot %s has already been filled!", argument )
  log.error (msg)
  raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
  # The slot starts at the next command.
  slot =  SubTemplate.new(@commandList.length, @endTagSymbol)
end
end
slotMap [argument] = slot
# Update the command
@commandList [ourMacroLocation] = (cmnd, (macroName, slotMap, endSymbol))
end
return nil
end
def compileMetalDefineSlot ( argument)
  if (argument.length == 0)
    # No argument passed
    msg = "No argument ed!  define-slot commands must be of the form: 'name'"
  end
end
end
end
log.error (msg)
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
# Check that the name of the slot is valid
if (METAL_NAME_REGEX.match (argument).end( 0 ) != argument.length)
end
end
end
end
end
msg = sprintf( "Slot name %s is invalid.", argument )
end
end
end
end
end
log.error (msg)
end
end
end
end
end
raise  TemplateParseException.new(tagAsText (@currentStartTag), msg)
end
end
return (METAL_DEFINE_SLOT, (argument, @endTagSymbol))

end
end
class  TemplateParseException.new(Exception)
  def initialize ( location, errorDescription)
    @location = location
    @errorDescription = errorDescription
  end
  def to_s
    return "[" + @location + "] " + @errorDescription


  end
end
class  HTMLTemplateCompiler.new(TemplateCompiler, FixedHTMLParser.HTMLParser)
  def initialize
    TemplateCompiler.__init__
    FixedHTMLParser.HTMLParser.__init__
    @log = logging.getLogger ("simpleTAL.HTMLTemplateCompiler")
  end
  def parseTemplate ( file, encoding="iso-8859-1", minimizeBooleanAtts = 0)
    encodedFile = codecs.lookup (encoding)[2](file, 'replace')
    @encoding = encoding
    @minimizeBooleanAtts = minimizeBooleanAtts
    feed (encodedFile.read)
    @close
  end
  def tagAsText ( (tag,atts), singletonFlag=0)
    =end This returns a tag as text.
    =begin
    result = ["<"]
    result << tag
    upperTag = tag.upcase
    for attName, attValue in atts
      if (@minimizeBooleanAtts and HTML_BOOLEAN_ATTS.has_key (sprintf( '%s:%s', (upperTag, ) attName.upcase)))
        # We should output a minimised boolean value
        result.append (' ')
      end
    end
  end
end
end
result << attName
end
else
  result.append (' ')
  result << attName
  result.append ('="')
  result.append (cgi.escape (attValue, quote=1))
  result.append ('"')
end
end
if (singletonFlag)
  result.append (" />")
end
else
  result.append (">")
end
return "".join (result)
end
def handle_startendtag ( tag, attributes)
  handle_starttag (tag, attributes)
  if not (HTML_FORBIDDEN_ENDTAG.has_key (tag.upcase))
    handle_endtag(tag)
  end
end
def handle_starttag ( tag, attributes)
  log.debug ("Recieved Start Tag: " + tag + " Attributes: " + attributes.to_s)
  atts = []
  for att, attValue in attributes
    # We need to spot empty tal:omit-tags 
    if (attValue is nil)
    end
  end
end
end
if (att == @tal_namespace_omittag)
end
end
end
end
atts.append ((att, u""))
end
end
end
end
else
end
end
end
end
atts.append ((att, att))
end
end
end
end
else
  # Expand any SGML entity references or char references
  goodAttValue = []
end
end
end
end
end
last = 0
end
end
end
end
end
match = ENTITY_REF_REGEX.search (attValue)
end
end
end
end
end
while (match)
end
end
end
end
end
goodAttValue.append (attValue[last..match.start-1])
end
end
end
end
end
ref = attValue[match.start..match.end( 0 )-1]
end
end
end
end
end
if (ref.startswith ('&#'))
end
end
end
end
end
# A char reference
if (ref[2] in ['x', 'X'])
end
end
end
end
end
# Hex
refValue = int (ref[3..-1-1], 16)
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
refValue =ref[2..-1-1].to_i
end
end
end
end
end
goodAttValue.append (unichr (refValue))
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
# A named reference.
goodAttValue.append (unichr (sgmlentitynames.htmlNameToUnicodeNumber.get (ref[1..-1-1], 65533)))
end
end
end
end
end
last = match.end( 0 )
end
end
end
end
end
match = ENTITY_REF_REGEX.search (attValue, last)
end
end
end
end
end
goodAttValue.append (attValue [last..-1])
end
end
end
end
end
atts.append ((att, u"".join (goodAttValue)))
end
end
if (HTML_FORBIDDEN_ENDTAG.has_key (tag.upcase))
  # This should have no end tag, so we just do the start and suppress the end
  parseStartTag (tag, atts)
end
end
end
end
log.debug ("End tag forbidden, generating close tag with no output.")
end
end
end
end
popTag ((tag, nil), omitTagFlag=1)
end
else
  parseStartTag (tag, atts)
end
end
def handle_endtag ( tag)
  log.debug ("Recieved End Tag: " + tag)
  if (HTML_FORBIDDEN_ENDTAG.has_key (tag.upcase))
    log.warn (sprintf( "HTML 4.01 forbids end tags for the %s element", tag) )
  end
else
  # Normal end tag
  popTag ((tag, nil))
end
end
def handle_data ( data)
  parseData (cgi.escape (data))
  # These two methods are required so that we expand all character and entity references prior to parsing the template.
  def handle_charref ( ref)
  end
  log.debug ("Got Ref: %s", ref)
  parseData (unichr (ref)).to_i
end
def handle_entityref ( ref)
  log.debug ("Got Ref: %s", ref)
  # Use handle_data so that <&> are re-encoded as required.
  handle_data( unichr (sgmlentitynames.htmlNameToUnicodeNumber.get (ref, 65533)))
end
end
end
end
# Handle document type declarations
def handle_decl ( data)
end
parseData (usprintf( '<!%s>', data) )
# Pass comments through un-affected.
def handle_comment ( data)
end
parseData (usprintf( '<!--%s-->', data) )

end
def handle_pi ( data)
  log.debug ("Recieved processing instruction.")
  parseData (usprintf( '<?%s>', data) )
end
def report_unbalanced ( tag)
  log.warn ("End tag %s present with no corresponding open tag.")
end
def getTemplate
  template =  HTMLTemplate.new(@commandList, @macroMap, @symbolLocationTable, minimizeBooleanAtts = @minimizeBooleanAtts)
  return template
end
end
class  XMLTemplateCompiler.new(TemplateCompiler, xml.sax.handler.ContentHandler, xml.sax.handler.DTDHandler, LexicalHandler)
  def initialize
    TemplateCompiler.__init__
    xml.sax.handler.ContentHandler.__init__
    @doctype = nil
    @log = logging.getLogger ("simpleTAL.XMLTemplateCompiler")
    @singletonElement = 0
  end
  def parseTemplate ( file)
    @ourParser = xml.sax.make_parser
    log.debug ("Setting features of parser")
    begin
      ourParser.setFeature (xml.sax.handler.feature_external_ges, 0)
    end
    except

  end
  if use_lexical_handler
    ourParser.setProperty(xml.sax.handler.property_lexical_handler, self) 

  end
  @ourParser.setContentHandler
  @ourParser.setDTDHandler
  ourParser.parse (file)
end
def parseDOM ( dom)
  if (not use_dom2sax)
    log.critical ("PyXML is not available, DOM can not be parsed.")
  end
  @ourParser = xml.dom.ext.Dom2Sax.Dom2SaxParser
  log.debug ("Setting features of parser")
  if use_lexical_handler
    ourParser.setProperty(xml.sax.handler.property_lexical_handler, self) 
  end
  @ourParser.setContentHandler
  @ourParser.setDTDHandler
  ourParser.parse (dom)

end
def startDTD( name, public_id, system_id)
  log.debug ("Recieved DOCTYPE: " + name + " public_id: " + public_id + " system_id: " + system_id)
  if public_id
    @doctype = sprintf( '<!DOCTYPE %s PUBLIC "%s" "%s">', (name, ) public_id, system_id,)
  end
else
  @doctype = sprintf( '<!DOCTYPE %s SYSTEM "%s">', (name, ) system_id,)

end
end
def startElement ( tag, attributes)
  log.debug ("Recieved Real Start Tag: " + tag + " Attributes: " + attributes.to_s)
  begin
    xmlText = ourParser.getProperty (xml.sax.handler.property_xml_string)
    if (SINGLETON_XML_REGEX.match (xmlText))
      # This is a singleton!
      @singletonElement=1
    end
  end
rescue xml.sax.SAXException => e
  # Parser doesn't support this property

end
end
end
end
# Convert attributes into a list of tuples
atts = []
end
for att in attributes.getNames
  log.debug (sprintf( "Attribute name %s has value %s", (att, ) attributes[att]))
  atts.append ((att, attributes [att]))
end
parseStartTag (tag, atts, singletonElement=@singletonElement)
end
def endElement ( tag)
  log.debug ("Recieved Real End Tag: " + tag)
  parseEndTag (tag)
  @singletonElement = 0
end
def characters ( data)
  #self.log.debug ("Recieved Real Data: " + data)
  # Escape any data we recieve - we don't want any: <&> in there.
  parseData (cgi.escape (data))
end
def processingInstruction ( target, data)
  log.debug ("Recieved processing instruction.")
  parseData (usprintf( '<?%s %s?>', (target, ) data))
end
def comment ( data)
  # This is only called if your XML parser supports the LexicalHandler interface.
  parseData (usprintf( '<!--%s-->', data) )
end
def getTemplate
  template =  XMLTemplate.new(@commandList, @macroMap, @symbolLocationTable, @doctype)
  return template
end
end
def compileHTMLTemplate (template, inputEncoding="ISO-8859-1", minimizeBooleanAtts = 0)
  =end Reads the templateFile and produces a compiled template.
  To use the resulting template object call
  template.expand (context, outputFile)
  =begin
  if (isinstance (template, types.String) or isinstance (template, types.Unicode))
    # It's a string!
    templateFile = StringIO.StringIO (template)
  end
else
  templateFile = template
end
compiler = HTMLTemplateCompiler
compiler.parseTemplate (templateFile, inputEncoding, minimizeBooleanAtts)
return compiler.getTemplate

end
def compileXMLTemplate (template)
  =end Reads the templateFile and produces a compiled template.
  To use the resulting template object call
  template.expand (context, outputFile)
  =begin
  if (isinstance (template, types.String))
    # It's a string!
    templateFile = StringIO.StringIO (template)
  end
else
  templateFile = template
end
compiler = XMLTemplateCompiler
compiler.parseTemplate (templateFile)
return compiler.getTemplate

end
def compileDOMTemplate (template)
  =end Traverses the DOM and produces a compiled template.
  To use the resulting template object call
  template.expand (context, outputFile)
  =begin
  compiler = XMLTemplateCompiler 
  compiler.parseDOM (template)
  return compiler.getTemplate
end
