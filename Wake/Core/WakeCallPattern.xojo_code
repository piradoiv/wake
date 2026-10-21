#tag Module
Protected Module WakeCallPattern
	#tag Method, Flags = &h21
		Private Function AddressPattern(script As String, quiet As Boolean) As Patterns
		  // What a sed or awk address asks for: two line numbers are a line range, a range with a
		  // pattern at either end is a section, and one pattern on its own (printing only what it
		  // matches) is a search.
		  Var position As Integer
		  Var firstIsPattern, secondIsPattern As Boolean
		  If Not ReadAddress(script, position, firstIsPattern) Then Return Patterns.Run
		  
		  Var rest As String = script.Middle(position).TrimLeft
		  If rest.BeginsWith(",") Then
		    rest = rest.Middle(1).TrimLeft
		    position = 0
		    If ReadAddress(rest, position, secondIsPattern) Then
		      If firstIsPattern Or secondIsPattern Then Return Patterns.Section
		      Return Patterns.LineRange
		    End If
		    Return Patterns.Run
		  End If
		  
		  If Not firstIsPattern Then Return Patterns.LineRange
		  If quiet Then Return Patterns.Search
		  Return Patterns.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Advice(key As String) As String
		  // One sentence on what a group of calls suggests, worded for any project.
		  Select Case key
		  Case kKeyLineRange
		    Return "Reads by line number suggest the agent can't ask for a symbol or section by name. A tool or index that returns one function or section by name would send less."
		  Case kKeySection
		    Return "Sections cut out between two patterns suggest the agent knows what it wants but has to find where it ends. A tool that returns a named section or symbol would send less."
		  Case kKeyWholeFile
		    Return "Whole files sent at once. An outline first, then only the parts needed, would send less."
		  Case kKeySearch
		    Return "Search results can be long. A narrower pattern, a filter on file names or a limit on matches would send less."
		  Case kKeyListing
		    Return "File listings sent in full. A filter, a depth limit or a short note on the project's layout would send less."
		  Case kKeyEdit
		    Return "Edits send the changed text and often the file around it. Small, targeted edits send less than rewriting whole files."
		  Case kKeyWeb
		    Return "Web pages and search results are often long. Asking for a summary or one part of the page would send less."
		  Case kKeyRun
		    Return "Output of builds, tests and other commands. Quieter options, or keeping only failures and the end of the output, would send less."
		  Case kKeyReread
		    Return "The same file read again in a session. It is already in the context, so guidance or a cache can avoid it."
		  Else
		    Return "Other tools. The calls below show what their results contain."
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function AwkPattern(arguments() As String) As Patterns
		  // The awk program is the first word that isn't an option, or the value of -f, -F or -v.
		  Var script As String
		  Var i As Integer
		  While i <= arguments.LastIndex
		    Var word As String = arguments(i)
		    If word = "-F" Or word = "-v" Or word = "-f" Then
		      i = i + 2
		      Continue
		    End If
		    If Not word.BeginsWith("-") Then
		      script = word
		      Exit
		    End If
		    i = i + 1
		  Wend
		  
		  If script.IndexOf("NR") >= 0 Then Return Patterns.LineRange
		  Return AddressPattern(script.Trim, True)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Classify(e As WakeEvent) As Patterns
		  // What a tool call was trying to get, from the shape of the call: which tool or program it
		  // used and how it asked. Never from the language, file type or project.
		  If e Is Nil Or Not e.IsToolCall Then Return Patterns.Other
		  If e.Kind = WakeEvent.Kinds.FileEdit Then Return Patterns.Edit
		  If e.Kind = WakeEvent.Kinds.ShellCommand Then Return ShellPattern(e.ShellArguments)
		  
		  Select Case e.ToolName
		  Case "Read"
		    If HasLineRange(e.ToolInputJSON) Then Return Patterns.LineRange
		    Return Patterns.WholeFile
		  Case "Grep"
		    Return Patterns.Search
		  Case "Glob", "LS"
		    Return Patterns.Listing
		  Case "Edit", "MultiEdit", "Write", "NotebookEdit"
		    Return Patterns.Edit
		  Case "WebFetch", "WebSearch"
		    Return Patterns.Web
		  End Select
		  
		  Var name As String = e.ToolName.Lowercase
		  If name.IndexOf("browser") >= 0 Or name.IndexOf("chrome") >= 0 Then Return Patterns.Web
		  Return Patterns.Other
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HasLineRange(toolInputJSON As String) As Boolean
		  If toolInputJSON = "" Then Return False
		  Try
		    Var toolInput As Dictionary = WakeCore.AsDictionary(ParseJSON(toolInputJSON))
		    Return toolInput <> Nil And (toolInput.HasKey("offset") Or toolInput.HasKey("limit"))
		  Catch err As JSONException
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsRead(pattern As Patterns) As Boolean
		  // Whether a call of this pattern reads a file's content.
		  Return pattern = Patterns.LineRange Or pattern = Patterns.Section Or pattern = Patterns.WholeFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Key(pattern As Patterns) As String
		  // The name the index stores for a pattern.
		  Select Case pattern
		  Case Patterns.LineRange
		    Return kKeyLineRange
		  Case Patterns.Section
		    Return kKeySection
		  Case Patterns.WholeFile
		    Return kKeyWholeFile
		  Case Patterns.Search
		    Return kKeySearch
		  Case Patterns.Listing
		    Return kKeyListing
		  Case Patterns.Edit
		    Return kKeyEdit
		  Case Patterns.Web
		    Return kKeyWeb
		  Case Patterns.Run
		    Return kKeyRun
		  End Select
		  Return kKeyOther
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Label(key As String) As String
		  // The name shown for a pattern's key, or for kKeyReread.
		  Select Case key
		  Case kKeyLineRange
		    Return "Line range"
		  Case kKeySection
		    Return "Section"
		  Case kKeyWholeFile
		    Return "Whole file"
		  Case kKeySearch
		    Return "Search"
		  Case kKeyListing
		    Return "Listing"
		  Case kKeyEdit
		    Return "Edit"
		  Case kKeyWeb
		    Return "Web"
		  Case kKeyRun
		    Return "Run"
		  Case kKeyReread
		    Return "Re-read"
		  End Select
		  Return "Other"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LedNowhereAdvice() As String
		  // What reads that led nowhere suggest, worded for any project.
		  Return "Reading to understand a task is normal, and some reads rule things out. Look at the files read " + _
		  "in full again and again without being used: a short note on what they hold, or an outline, would send less."
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReadAddress(script As String, ByRef position As Integer, ByRef isPattern As Boolean) As Boolean
		  // Reads one sed or awk address at position: a /pattern/, or a line number, $ or first~step.
		  If position >= script.Length Then Return False
		  Var c As String = script.Middle(position, 1)
		  
		  If c = "/" Then
		    position = position + 1
		    While position < script.Length
		      c = script.Middle(position, 1)
		      If c = "\" Then
		        position = position + 2
		        Continue
		      End If
		      position = position + 1
		      If c = "/" Then
		        isPattern = True
		        Return True
		      End If
		    Wend
		    Return False
		  End If
		  
		  Var start As Integer = position
		  While position < script.Length
		    c = script.Middle(position, 1)
		    If Not ((c >= "0" And c <= "9") Or c = "$" Or c = "~") Then Exit
		    position = position + 1
		  Wend
		  isPattern = False
		  Return position > start
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SedPattern(arguments() As String) As Patterns
		  // The sed script is the value of -e, or else the first word that isn't an option. -n prints
		  // only what the script asks for, and -i changes the file in place.
		  Var script As String
		  Var quiet, inPlace As Boolean
		  Var i As Integer
		  While i <= arguments.LastIndex
		    Var word As String = arguments(i)
		    If word = "-e" Or word = "--expression" Then
		      If script = "" And i < arguments.LastIndex Then script = arguments(i + 1)
		      i = i + 2
		      Continue
		    End If
		    If word = "--quiet" Or word = "--silent" Then
		      quiet = True
		    ElseIf word.BeginsWith("--in-place") Then
		      inPlace = True
		    ElseIf word.BeginsWith("-") And Not word.BeginsWith("--") Then
		      If word.IndexOf("n") > 0 Then quiet = True
		      If word.IndexOf("i") > 0 Then inPlace = True
		    ElseIf script = "" And Not word.BeginsWith("-") Then
		      script = word
		    End If
		    i = i + 1
		  Wend
		  
		  If inPlace Then Return Patterns.Edit
		  Return AddressPattern(script.Trim, quiet)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ShellPattern(words() As String) As Patterns
		  // words is the program followed by its arguments.
		  If words.Count = 0 Then Return Patterns.Run
		  Var program As String = words(0).NthField("/", words(0).CountFields("/")).Lowercase
		  Var arguments() As String
		  For i As Integer = 1 To words.LastIndex
		    arguments.Add(words(i))
		  Next
		  
		  Select Case program
		  Case "sed", "gsed"
		    Return SedPattern(arguments)
		  Case "awk", "gawk", "mawk", "nawk"
		    Return AwkPattern(arguments)
		  Case "head", "tail"
		    Return Patterns.LineRange
		  Case "cat", "less", "more", "bat"
		    // `cat > file` writes a file, and `cat << END` reads only its own text.
		    Var hasFile As Boolean
		    For Each word As String In arguments
		      If word.BeginsWith(">") Then Return Patterns.Edit
		      If word.BeginsWith("<<") Then Return Patterns.Run
		      If Not word.BeginsWith("-") And word.IndexOf(">") < 0 Then hasFile = True
		    Next
		    If hasFile Then Return Patterns.WholeFile
		    Return Patterns.Run
		  Case "grep", "egrep", "fgrep", "rg", "ag", "ack", "ugrep"
		    Return Patterns.Search
		  Case "ls", "find", "tree", "fd"
		    Return Patterns.Listing
		  Case "git"
		    For Each word As String In arguments
		      If word.BeginsWith("-") Then Continue
		      If word = "grep" Then Return Patterns.Search
		      If word = "ls-files" Or word = "ls-tree" Then Return Patterns.Listing
		      Exit
		    Next
		  End Select
		  
		  Return Patterns.Run
		End Function
	#tag EndMethod


	#tag Constant, Name = kKeyEdit, Type = String, Dynamic = False, Default = \"edit", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyLineRange, Type = String, Dynamic = False, Default = \"line-range", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyListing, Type = String, Dynamic = False, Default = \"listing", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyOther, Type = String, Dynamic = False, Default = \"other", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyReread, Type = String, Dynamic = False, Default = \"re-read", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyRun, Type = String, Dynamic = False, Default = \"run", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeySearch, Type = String, Dynamic = False, Default = \"search", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeySection, Type = String, Dynamic = False, Default = \"section", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyWeb, Type = String, Dynamic = False, Default = \"web", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kKeyWholeFile, Type = String, Dynamic = False, Default = \"whole-file", Scope = Public
	#tag EndConstant


	#tag Enum, Name = Patterns, Type = Integer, Flags = &h0
		Other
		  LineRange
		  Section
		  WholeFile
		  Search
		  Listing
		  Edit
		  Web
		Run
	#tag EndEnum


End Module
#tag EndModule
