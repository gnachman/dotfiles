import vim

def Normal(command):
  vim.command("normal %s" % command)

def Clean(command):
  return command.replace('"', '\\"')

def Echo(command):
  vim.command("echo \"%s\"" % Clean(command))

def Prompt(message, varname="cppinsert_noname"):
  clean_message = message.replace('"', '\\"')
  vim.command('let %s = input("%s: ")' % (varname, clean_message))
  return vim.eval("%s" % varname)

class NoResponse(Exception): pass

def PromptForMemberFunctionInfo():
  v = Prompt("Visiblity (Public/pRivate/prOtected)").lower()
  visibility = None
  if not v or v == 'p':
    visibility = "public"
  if v == "r":
    visibility = "private"
  if v == "o":
    visibility = "protected"
  if visibility is None:
    raise NoResponse()()

  type = Prompt("Return type")
  if not type:
    raise NoResponse()
  name = Prompt("Function name")
  if not name:
    raise NoResponse()
  params = []
  param = Prompt("Param")
  while param:
    params.append(param)
    param = Prompt("Param")

  Echo("%s: %s %s(%s)" % (visibility, type, name, ", ".join(params)))
  return visibility, type, name, params

class TokenString:
  def __init__(self, maxwidth):
    self._maxwidth = maxwidth
    self._tokens = []
    self._lines = []
    self._offsets = []
    self._relative_offsets = []
    self._current_offset = 0
    self._current_relative_offset = None
    self._overflow_offset = 2

  def Append(self, value, join=" "):
    self._offsets.append(self._current_offset)
    self._relative_offsets.append(self._current_relative_offset)
    self._tokens.append((value, join))

  def SetOffset(self, offset):
    self._current_offset = offset

  def SetRelativeOffset(self, offset):
    self._current_relative_offset = offset

  def _Spaces(self, total_offset):
    return "".join([" " for x in range(total_offset)])

  def Format(self):
    prev_start = 0
    line_offset = 0
    for vj, offset, relative_offset in zip(self._tokens, self._offsets,
        self._relative_offsets):
      value = vj[0]
      joiner = vj[1]
      total_offset = offset
      if self._lines:
        lastindex = len(self._lines) - 1
        current = self._lines[lastindex]
        if relative_offset is not None:
          total_offset += prev_start + relative_offset

        if len(current) + len(value) + 1 > self._maxwidth - total_offset:
          # Token too long to fit on current line
          if total_offset + len(value) > self._maxwidth:
            # Too long to use relative offset, if any
            self._lines.append(self._Spaces(offset + self._overflow_offset) + value)
            line_offset = offset
            prev_start = 0
          else:
            # Use normal offset for new line
            line_offset = offset
            self._lines.append(self._Spaces(total_offset) + value)
            prev_start = 0
        else:
          # Append to current line
          prev_start = len(self._lines[lastindex]) - line_offset
          self._lines[lastindex] = self._lines[lastindex] + joiner + value
      else:
        # First line
        self._lines.append(self._Spaces(total_offset) + value)
        line_offset = offset
        prev_start = 0

  def ToString(self):
    self.Format()
    return "\n".join(self._lines)

def AddMemberFunction():
  try:
    visibility, type, name, params = PromptForMemberFunctionInfo()
  except NoResponse:
    Echo("Aborted")
    return

  proto_str = GenerateMemberFunctionProto(visibility, type, name, params)
  print proto_str
  #Normal("o%s" % proto.ToString())

def GenerateMemberFunctionProto(visibility, type, name, params):
    proto = TokenString(80)
    proto.SetOffset(2)
    proto.Append(type)
    if params:
      params[len(params) - 1] += ");"
      proto.Append(name + "(")
      proto.SetRelativeOffset(len(name) + 2)
    else:
      need_term = True
      proto.Append(name + "();")
    i = 0
    n = len(params)
    joiner = ""
    for param in params:
      if (i < n - 1):
        proto.Append(param + ",", joiner)
      else:
        proto.Append(param, joiner)
      joiner = "#"
    proto.SetRelativeOffset(None)
    return proto.ToString()


#AddMemberFunction()
proto_str = GenerateMemberFunctionProto("public", "int", "foo",
["fdjsklafjdfjdkslafjdslkfjasdllkfajdslkfjdslkfajsdlkfjsdlkfjasdlkfjsdlkjfaldskjfldaskjfldsk fjkld"])
print proto_str
