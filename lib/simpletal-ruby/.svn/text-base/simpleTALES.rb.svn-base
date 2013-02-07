=begin
simpleTALES Implementation

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

The classes in this module implement the TALES specification, used
by the simpleTAL module.

Module Dependencies: logging
=end




begin
  require 'logging'
end
except
require 'DummyLogger as logging'
end
require 'simpletal'
require 'simpleTAL'

__version__ = simpletal.__version__

DEFAULTVALUE = "This represents a Default value."

class  PathNotFoundException.new(Exception)

end
class  ContextContentException.new(Exception)
  =begin This is raised when invalid content has been placed into the Context object.
  For example using non-ascii characters instead of Unicode strings.
  =end

end
PATHNOTFOUNDEXCEPTION = PathNotFoundException

class ContextVariable
  def initialize ( value = nil)
    @ourValue = value
  end
  def value ( currentPath=nil)
    if (ourValue).respond_to?( 'call' )
      return apply (@ourValue, )
    end
    return @ourValue
  end
  def rawValue
    return @ourValue
  end
  def to_s
    return @ourValue.to_s
  end
end
class  RepeatVariable.new(ContextVariable)
  =begin To be written=begin
  def initialize ( sequence)
    ContextVariable.__init__ ( 1)
    @sequence = sequence	
    @position = 0	
    @map = nil
  end
  def value ( currentPath=nil)
    if (@map is nil)
      @createMap
    end
    return @map
  end
  def rawValue
    return @value
  end
  def getCurrentValue
    return @sequence [@position]
  end
  def increment
    @position += 1
    if (@position == @sequence.length)
      raise  IndexError.new("Repeat Finished")
    end
  end
  def createMap
    @map = {}
    @map ['index'] = @getIndex
    @map ['number'] = @getNumber
    @map ['even'] = @getEven
    @map ['odd'] = @getOdd
    @map ['start'] = @getStart
    @map ['end'] = @getEnd
    # TODO: first and last need to be implemented.
    @map ['length'] = @sequence.length
  end
  @map ['letter'] = @getLowerLetter
  @map ['Letter'] = @getUpperLetter
  @map ['roman'] = @getLowerRoman
  @map ['Roman'] = @getUpperRoman
  # Repeat implementation goes here
  def getIndex
  end
  return @position
end
def getNumber
  return @position + 1
end
def getEven
  if ((@position % 2) != 0)
    return 0
  end
  return 1
end
def getOdd
  if ((@position % 2) == 0)
    return 0
  end
  return 1
end
def getStart
  if (@position == 0)
    return 1
  end
  return 0
end
def getEnd
  if (@position == @sequence.length - 1)
    return 1
  end
  return 0
end
def getLowerLetter
  result = ""
  nextCol = @position
  if (nextCol == 0)
    return 'a'
  end
  while (nextCol > 0)
    nextCol, thisCol = divmod (nextCol, 26)
    result = chr (ord ('a') + thisCol) + result
  end
  return result
end
def getUpperLetter
  return @getLowerLetter.upcase
end
def getLowerRoman
  romanNumeralList = (('m', 1000)						   ,('cm', 900)						   ,('d', 500)						   ,('cd', 400)						   ,('c', 100)						   ,('xc', 90)						   ,('l', 50)						   ,('xl', 40)						   ,('x', 10)						   ,('ix', 9)						   ,('v', 5)						   ,('iv', 4)						   ,('i', 1)						   )
  if (@position > 3999)
    # Roman numbers only supported up to 4000
    return ' '
  end
  num = @position + 1
  result = ""
  for roman, integer in romanNumeralList
    while (num >= integer)
      result += roman
      num -= integer
    end
  end
  return result
end
def getUpperRoman
  return @getLowerRoman.upcase
end
end
class  IteratorRepeatVariable.new(RepeatVariable)
  def initialize ( sequence)
    RepeatVariable.__init__ ( sequence)
    @curValue = nil
    @iterStatus = 0
  end
  def getCurrentValue
    if (@iterStatus == 0)
      @iterStatus = 1
      begin
        @curValue = @sequence.next
      end
    rescue StopIteration => e
      @iterStatus = 2
      raise  IndexError.new("Repeat Finished")
    end
  end
  return @curValue
end
def increment
  # Need this for the repeat variable functions.
  @position += 1
end
end
end
begin
end
end
end
@curValue = @sequence.next
end
end
end
rescue StopIteration => e
end
end
end
@iterStatus = 2
end
end
end
raise  IndexError.new("Repeat Finished")
end
def createMap
  @map = {}
  @map ['index'] = @getIndex
  @map ['number'] = @getNumber
  @map ['even'] = @getEven
  @map ['odd'] = @getOdd
  @map ['start'] = @getStart
  @map ['end'] = @getEnd
  # TODO: first and last need to be implemented.
  @map ['length'] = sys.maxint
end
@map ['letter'] = @getLowerLetter
@map ['Letter'] = @getUpperLetter
@map ['roman'] = @getLowerRoman
@map ['Roman'] = @getUpperRoman
end
def getEnd
  if (@iterStatus == 2)
    return 1
  end
  return 0
end
end
class  PathFunctionVariable.new(ContextVariable)
  def initialize ( func)
    ContextVariable.__init__ ( value = func)
    @func = func
  end
  def value ( currentPath=nil)
    if (currentPath is not nil)
      index, paths = currentPath
      result =  ContextVariable.new(apply (func, ('/'.join (paths[index..-1]),)))
      # Fast track the result
      raise result
    end
  end
end
end
class  CachedFuncResult.new(ContextVariable)
  def value ( currentPath=nil)
    begin
      return @cachedValue
    end
    except
    @cachedValue = ContextVariable.value
  end
  return @cachedValue
end
def clearCache
  begin
    del @cachedValue
  end
  except

end
end
end
class PythonPathFunctions
  def initialize ( context)
    @context = context
  end
  def path ( expr)
    return context.evaluatePath (expr)
  end
  def string ( expr)
    return context.evaluateString (expr)
  end
  def exists ( expr)
    return context.evaluateExists (expr)
  end
  def nocall ( expr)
    return context.evaluateNoCall (expr)
  end
  def test ( *arguments)
    if (arguments.length % 2)
      # We have an odd number of arguments - which means the last one is a default
      pairs = arguments[0..-1-1]
    end
  end
end
end
defaultValue = arguments[-1]
end
else
  # No default - so use None
  pairs = arguments
end
end
end
end
defaultValue = nil
end
index = 0
while (index < pairs.length)
  test = pairs[index]
  index += 1
  value = pairs[index]
  index += 1
  if (test)
    return value
  end
end
return defaultValue

end
end
class Context
  def initialize ( options=nil, allowPythonPath=0)
    @allowPythonPath = allowPythonPath
    @globals = {}
    @locals = {}
    @localStack = []
    @repeatStack = []
    populateDefaultVariables (options)
    @log = logging.getLogger ("simpleTALES.Context")
    @true = 1
    @false = 0
    @pythonPathFuncs = PythonPathFunctions
  end
  def addRepeat ( name, var, initialValue)
    # Pop the current repeat map onto the stack
    repeatStack.append (@repeatMap)
  end
end
end
@repeatMap = @repeatMap.copy
end
end
end
@repeatMap [name] = var
end
end
end
# Map this repeatMap into the global space
addGlobal ('repeat', @repeatMap)
end
end
end
# Add in the locals
@pushLocals
end
end
end
setLocal (name, initialValue)
end
def removeRepeat ( name)
  # Bring the old repeat map back
  @repeatMap = @repeatStack.pop
  # Map this repeatMap into the global space
  addGlobal ('repeat', @repeatMap)
end
end
def addGlobal ( name, value)
  @globals[name] = value
end
def pushLocals
  # Push the current locals onto a stack so that we can safely over-ride them.
  localStack.append (@locals)
end
end
end
@locals = @locals.copy
end
def setLocal ( name, value)
  # Override the current local if present with the new one
  @locals [name] = value
end
def popLocals
  @locals = @localStack.pop
end
def evaluate ( expr, originalAtts = nil)
  # Returns a ContextVariable
  #self.log.debug ("Evaluating %s" % expr)
  if (originalAtts is not nil)
    # Call from outside
    @globals['attrs'] = originalAtts
  end
end
end
suppressException = 1
end
end
end
else
end
end
end
suppressException = 0
# Supports path, exists, nocall, not, and string
expr = expr.strip 
end
end
end
end
begin
end
end
end
end
if expr.startswith ('path:')
end
end
end
end
return evaluatePath (expr[5..-1].lstrip )
end
end
end
end
elsif expr.startswith ('exists:')
end
end
end
end
return evaluateExists (expr[7..-1].lstrip)
end
end
end
end
elsif expr.startswith ('nocall:')
end
end
end
end
return evaluateNoCall (expr[7..-1].lstrip)
end
end
end
end
elsif expr.startswith ('not:')
end
end
end
end
return evaluateNot (expr[4..-1].lstrip)
end
end
end
end
elsif expr.startswith ('string:')
end
end
end
end
return evaluateString (expr[7..-1].lstrip)
end
end
end
end
elsif expr.startswith ('python:')
end
end
end
end
return evaluatePython (expr[7..-1].lstrip)
end
end
end
end
else
  # Not specified - so it's a path
  return evaluatePath (expr)
end
end
end
end
rescue PathNotFoundException => e
end
end
end
end
if (suppressException)
end
end
end
end
return nil
end
end
end
end
raise e
end
end
def evaluatePython ( expr)
  if (not @allowPythonPath)
    log.warn (sprintf( "Parameter allowPythonPath is false.  NOT Evaluating python expression %s", expr) )
    return @false
    #self.log.debug ("Evaluating python expression %s" % expr)
    globals={}
  end
end
for name, value in @globals.items
  if (isinstance (value, ContextVariable)): value = value.rawValue
    globals [name] = value
  end
  globals ['path'] = @pythonPathFuncs.path
  globals ['string'] = @pythonPathFuncs.string
  globals ['exists'] = @pythonPathFuncs.exists
  globals ['nocall'] = @pythonPathFuncs.nocall
  globals ['test'] = @pythonPathFuncs.test
  locals={}
  for name, value in @locals.items
    if (isinstance (value, ContextVariable)): value = value.rawValue
      locals [name] = value
    end
    begin
      result = eval(expr, globals, locals)
      if (isinstance (result, ContextVariable))
        return result.value
      end
      return result
    end
  rescue Exception => e
    # An exception occured evaluating the template, return the exception as text
    log.warn ("Exception occurred evaluating python path, exception: " + e.to_s)
  end
end
end
end
return sprintf( "Exception: %s", str ) (e)

end
end
def evaluatePath ( expr)
  #self.log.debug ("Evaluating path expression %s" % expr)
  allPaths = expr.split ('|')
end
end
end
if (allPaths.length > 1)
end
end
end
for path in allPaths
end
end
end
# Evaluate this path
begin
end
end
end
return evaluate (path.strip )
end
end
end
rescue PathNotFoundException => e
  # Path didn't exist, try the next one

end
end
end
end
# No paths evaluated - raise exception.
raise PATHNOTFOUNDEXCEPTION
end
end
end
end
else
end
end
end
end
# A single path - so let's evaluate it.
# This *can* raise PathNotFoundException
return traversePath (allPaths[0])
end
end
def evaluateExists ( expr)
  #self.log.debug ("Evaluating %s to see if it exists" % expr)
  allPaths = expr.split ('|')
end
end
end
# The first path is for us
# Return true if this first bit evaluates, otherwise test the rest
begin
end
end
end
result = traversePath (allPaths[0], canCall = 0)
end
end
end
return @true
end
end
end
rescue PathNotFoundException => e
end
end
end
# Look at the rest of the paths.

end
end
end
for path in allPaths[1..-1]
end
end
end
# Evaluate this path
begin
end
end
end
pathResult = evaluate (path.strip )
# If this is part of a "exists: path1 | exists: path2" path then we need to look at the actual result.
if (pathResult)
end
end
end
end
return @true
end
end
end
end
rescue PathNotFoundException => e
end
end
end
end

end
end
end
end
# If we get this far then there are *no* paths that exist.
return @false
end
end
def evaluateNoCall ( expr)
  #self.log.debug ("Evaluating %s using nocall" % expr)
  allPaths = expr.split ('|')
end
end
end
# The first path is for us
begin
end
end
end
return traversePath (allPaths[0], canCall = 0)
end
end
end
rescue PathNotFoundException => e
end
end
end
# Try the rest of the paths.

end
end
end
for path in allPaths[1..-1]
end
end
end
# Evaluate this path
begin
end
end
end
return evaluate (path.strip )
end
end
end
rescue PathNotFoundException => e
end
end
end

end
end
end
# No path evaluated - raise error
raise PATHNOTFOUNDEXCEPTION
end
def evaluateNot ( expr)
  #self.log.debug ("Evaluating NOT value of %s" % expr)
  # Evaluate what I was passed
  begin
  end
end
end
pathResult = evaluate (expr)
end
end
end
rescue PathNotFoundException => e
  # In SimpleTAL the result of "not: no/such/path" should be TRUE not FALSE.
  return @true
end
end
end
end
if (pathResult is nil)
end
end
end
end
# Value was Nothing
return @true
end
end
end
end
if (pathResult == DEFAULTVALUE)
end
end
end
end
return @false
end
end
end
end
begin
end
end
end
end
resultLen = pathResult.length
end
end
end
end
if (resultLen > 0)
end
end
end
end
return @false
end
end
end
end
else
end
end
end
end
return @true
end
end
end
end
except
end
end
end
end
# Not a sequence object.

end
end
end
end
if (not pathResult)
end
end
end
end
return @true
end
end
end
end
# Everything else is true, so we return false!
return @false
end
end
def evaluateString ( expr)
  #self.log.debug ("Evaluating String %s" % expr)
  result = ""
end
end
end
skipCount = 0
end
end
end
for position in xrange (0,expr.length)
end
end
end
if (skipCount > 0)
end
end
end
skipCount -= 1
end
end
end
else
end
end
end
if (expr[position] == '$')
end
end
end
begin
end
end
end
if (expr[position + 1] == '$')
  # Escaped $ sign
  result += '$'
end
end
end
end
skipCount = 1
end
end
end
end
elsif (expr[position + 1] == '{')
  # Looking for a path!
  endPos = expr.find ('}', position + 1)
end
end
end
end
end
if (endPos > 0)
end
end
path = expr[position + 2:endPos]
# Evaluate the path - missing paths raise exceptions as normal.
begin
end
end
end
end
pathResult = evaluate (path)
end
rescue PathNotFoundException => e
  # This part of the path didn't evaluate to anything - leave blank
  pathResult = u''
end
if (pathResult is not nil)
  if (isinstance (pathResult, types.Unicode))
    result += pathResult
  end
else
  # THIS IS NOT A BUG!
  # Use Unicode in Context if you aren't using Ascii!
  result += unicode (pathResult)
end
end
skipCount = endPos - position 
end
end
end
else
  # It's a variable
  endPos = expr.find (' ', position + 1)
end
end
end
end
if (endPos == -1)
end
endPos = expr.length
end
end
end
path = expr [position + 1:endPos]
# Evaluate the variable - missing paths raise exceptions as normal.
begin
end
pathResult = traversePath (path)
end
end
end
rescue PathNotFoundException => e
  # This part of the path didn't evaluate to anything - leave blank
  pathResult = u''
end
end
end
end
if (pathResult is not nil)
end
if (isinstance (pathResult, types.Unicode))
  result += pathResult
end
else
  # THIS IS NOT A BUG!
  # Use Unicode in Context if you aren't using Ascii!
  result += unicode (pathResult)
end
end
end
end
skipCount = endPos - position - 1
end
end
end
end
rescue IndexError => e
end
end
end
end
# Trailing $ sign - just suppress it
log.warn ("Trailing $ detected")
end
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
result += expr[position]
end
end
end
end
return result
end
end
def traversePath ( expr, canCall=1)
  # canCall only applies to the *final* path destination, not points down the path.
  # Check for and correct for trailing/leading quotes
  if (expr.startswith ('"') or expr.startswith ("'"))
  end
end
end
if (expr.end( 0 )swith ('"') or expr.end( 0 )swith ("'"))
end
end
end
expr = expr [1..-1-1]
end
end
end
else
end
end
end
expr = expr [1..-1]
end
end
end
elsif (expr.end( 0 )swith ('"') or expr.end( 0 )swith ("'"))
end
end
end
expr = expr [0..-1-1]
end
end
end
pathList = expr.split ('/')
end
end
end
path = pathList[0]
end
end
end
if path.startswith ('?')
end
end
end
path = path[1..-1]
end
end
end
if locals.has_key(path)
end
end
end
path = @locals[path]
end
end
end
if (isinstance (path, ContextVariable)): path = path.value
end
end
end
elsif (path).respond_to?( 'call' ):path = apply (path, )
end
end
end
elsif globals.has_key(path)
end
end
end
path = @globals[path]
end
end
end
if (isinstance (path, ContextVariable)): path = path.value
end
end
end
elsif (path).respond_to?( 'call' ):path = apply (path, )
end
end
end
#self.log.debug ("Dereferenced to %s" % path)
if locals.has_key(path)
end
end
end
val = @locals[path]
end
end
end
elsif globals.has_key(path)
end
end
end
val = @globals[path]  
end
end
end
else
end
end
end
# If we can't find it then raise an exception
raise PATHNOTFOUNDEXCEPTION
end
end
end
index = 1
end
end
end
for path in pathList[1..-1]
end
end
end
#self.log.debug ("Looking for path element %s" % path)
if path.startswith ('?')
end
end
end
path = path[1..-1]
end
end
end
if locals.has_key(path)
end
end
end
path = @locals[path]
end
end
end
if (isinstance (path, ContextVariable)): path = path.value
end
end
end
elsif (path).respond_to?( 'call' ):path = apply (path, )
end
end
end
elsif globals.has_key(path)
end
end
end
path = @globals[path]
end
end
end
if (isinstance (path, ContextVariable)): path = path.value
end
end
end
elsif (path).respond_to?( 'call' ):path = apply (path, )
end
end
end
#self.log.debug ("Dereferenced to %s" % path)
begin
end
end
end
if (isinstance (val, ContextVariable)): temp = val.value((index,pathList))
end
end
end
elsif (val).respond_to?( 'call' ):temp = apply (val, )
end
end
end
else: temp = val
end
end
end
rescue ContextVariable => e
end
end
end
# Fast path for those functions that return values
return e.value
end
end
end
if (hasattr (temp, path))
end
end
end
val = temp.method( path )
end
end
end
else
end
end
end
begin
end
end
end
begin
end
end
end
val = temp[path]
end
end
end
rescue TypeError
end
end
end
val = temp[path.to_i]
end
end
end
except
end
end
end
#self.log.debug ("Not found.")
raise PATHNOTFOUNDEXCEPTION
end
end
end
index = index + 1
end
end
end
#self.log.debug ("Found value %s" % str (val))
if (canCall)
end
end
end
begin
end
end
end
if (isinstance (val, ContextVariable)): result = val.value((index,pathList))
end
end
end
elsif (val).respond_to?( 'call' ):result = apply (val, )
end
end
end
else: result = val
end
end
end
rescue ContextVariable => e
end
end
end
# Fast path for those functions that return values
return e.value
end
end
end
else
end
end
end
if (isinstance (val, ContextVariable)): result = val.realValue
end
end
end
else: result = val
end
end
end
return result
end
def to_s
  return "Globals: " + @globals.to_s + "Locals: " + @locals.to_s
end
def populateDefaultVariables ( options)
  vars = {}
  @repeatMap = {}
  vars['nothing'] = nil
  vars['default'] = DEFAULTVALUE
  vars['options'] = options
  # To start with there are no repeats
  vars['repeat'] = @repeatMap	
end
vars['attrs'] = nil
# Add all of these to the global context
for name in vars.keys
end
end
end
end
addGlobal (name,vars[name])
end
end
end
end
# Add also under CONTEXTS
addGlobal ('CONTEXTS', vars)

end
end
end
