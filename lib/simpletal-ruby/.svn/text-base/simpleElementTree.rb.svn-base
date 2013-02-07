=begin
ElementTree integration for SimpleTAL 

Copyright.new(c) 2004 Colin  Stewart.new(http://www.owlfish.com/)
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

The parseFile function in this module will return a Element object that
implements simpleTALES.ContextVariable and makes XML documents available
with the following path logic
- Accessing Element directly returns the Element.text value
- Accessing Element/find and Element/findall es the text
(up to attribute accessor) to the corresponding Element function
- Accessing the Element@name access the attribute "name"
- Accessing Element/anotherElement is a short-cut for 
Element/find/anotherElement

Module Dependencies: simpleTALES, elementtree
=end

require 'elementtree/ElementTree'
require 'simpleTALES'

class  SimpleElementTreeVar.new(ElementTree._ElementInterface, simpleTALES.ContextVariable)
  def initialize( tag, attrib)
    ElementTree._ElementInterface.__init__( tag, attrib)
    simpleTALES.ContextVariable.__init__
  end
  def value ( pathInfo = nil)
    if (pathInfo is not nil)
      pathIndex, paths = pathInfo
      ourParams = paths[pathIndex..-1]
      attributeName = nil
      if (ourParams.length > 0)
        # Look for attribute index
        if (ourParams[-1].startswith ('@'))
          # Attribute lookup
          attributeName = ourParams [-1][1..-1]
        end
      end
    end
  end
end
ourParams = ourParams [0..-1-1]
end
end
end
end
end
# Do we do a find?
activeElement = self
end
if ourParams.length > 0
  # Look for a find or findall first
  if (ourParams [0] == 'find')
    # Find the element if possible
    activeElement = find ("/".join (ourParams [1..-1]))
  end
end
end
end
end
end
elsif (ourParams [0] == 'findall')
end
end
end
end
end
end
# Short cut this
raise simpleTALES.ContextVariable (findall ("/".join (ourParams[1..-1])))
end
end
end
end
end
end
else
  # Assume that we wanted to use find
  activeElement = find ("/".join (ourParams))
  # Did we find an element and are we looking for an attribute?
  if (attributeName is not nil and activeElement is not nil)
  end
end
end
end
end
end
end
end
attrValue = activeElement.attrib.get (attributeName, nil)
end
end
end
end
end
end
end
end
raise simpleTALES.ContextVariable (attrValue)
end
end
end
end
end
end
end
end
# Just return the element
if (activeElement is nil)
end
end
end
end
end
end
end
end
# Wrap it
raise simpleTALES.ContextVariable (nil)
end
end
end
end
raise activeElement
end
else
  return self
end
end
def __unicode__
  return @text
end
def to_s
  return @text.to_s

end
end
def parseFile (file)
  treeBuilder = ElementTree.TreeBuilder (element_factory = SimpleElementTreeVar)
  xmlTreeBuilder = ElementTree.XMLTreeBuilder (target=treeBuilder)
  if (not hasattr (file, 'read'))
    ourFile = File.open(file)
    xmlTreeBuilder.feed (ourFile.read)
    ourFile.close
  end
else
  xmlTreeBuilder.feed (file.read)
end
return xmlTreeBuilder.close
