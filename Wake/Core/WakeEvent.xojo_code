#tag Class
Protected Class WakeEvent
	#tag Method, Flags = &h21
		Private Shared Function ExtensionOf(path As String) As String
		  // The lowercased extension of a file name, such as ".xojo_code", or "" when it has none.
		  // Version numbers and decimals such as "1.5" have no letter, so they don't count.
		  path = path.ReplaceAll("\", "/")
		  Var name As String = path.NthField("/", path.CountFields("/"))
		  Var count As Integer = name.CountFields(".")
		  If count < 2 Then Return ""
		  
		  Var extension As String = name.NthField(".", count)
		  If extension = "" Or extension.Length > 15 Or name.Length = extension.Length + 1 Then Return ""
		  
		  Var hasLetter As Boolean
		  For i As Integer = 0 To extension.Length - 1
		    Var c As String = extension.Middle(i, 1)
		    If (c >= "a" And c <= "z") Or (c >= "A" And c <= "Z") Then
		      hasLetter = True
		    ElseIf Not ((c >= "0" And c <= "9") Or c = "_" Or c = "-") Then
		      Return ""
		    End If
		  Next
		  If Not hasLetter Then Return ""
		  
		  Return "." + extension.Lowercase
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileType() As String
		  // The extension of the file a tool call worked on, such as ".xojo_code", or "".
		  Return ExtensionOf(TargetPath)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function IsAbsolutePath(path As String) As Boolean
		  // A Unix path, a home-relative path, a drive letter or a network share.
		  If path.BeginsWith("/") Or path.BeginsWith("~") Or path.BeginsWith("\\") Then Return True
		  Return path.Length > 2 And path.Middle(1, 1) = ":" And (path.Middle(2, 1) = "\" Or path.Middle(2, 1) = "/")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsToolCall() As Boolean
		  Return Kind = Kinds.ToolCall Or Kind = Kinds.ShellCommand Or Kind = Kinds.FileEdit
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function JoinPath(folder As String, relative As String) As String
		  // folder and relative joined with the folder's own separator. A leading ./ is dropped.
		  Var separator As String = If(folder.IndexOf("/") < 0 And folder.IndexOf("\") >= 0, "\", "/")
		  While relative.BeginsWith("./") Or relative.BeginsWith(".\")
		    relative = relative.Middle(2)
		  Wend
		  If relative = "." Or relative = "" Then Return folder
		  If folder.EndsWith(separator) Then Return folder + relative
		  Return folder + separator + relative
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function KindName(value As Kinds) As String
		  Select Case value
		  Case Kinds.UserPrompt
		    Return "user"
		  Case Kinds.AssistantText
		    Return "assistant"
		  Case Kinds.Thinking
		    Return "thinking"
		  Case Kinds.ToolCall
		    Return "tool"
		  Case Kinds.ShellCommand
		    Return "shell"
		  Case Kinds.FileEdit
		    Return "edit"
		  Case Kinds.ToolResult
		    Return "result"
		  Case Kinds.Error
		    Return "error"
		  Case Kinds.System
		    Return "system"
		  End Select
		  
		  Return "unknown"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ProgramIndex(words() As String) As Integer
		  // The index of the word that names the program, skipping leading cd, export, source and
		  // VAR=value parts, or -1.
		  Var atStart As Boolean = True
		  For i As Integer = 0 To words.LastIndex
		    Var word As String = words(i)
		    If word = &u01 Then
		      atStart = True
		      Continue
		    End If
		    If Not atStart Or word.IndexOf("=") > 0 Or word.BeginsWith("-") Then Continue
		    
		    If word = "cd" Or word = "export" Or word = "pushd" Or word = "source" Or word = "." Then
		      atStart = False
		      Continue
		    End If
		    Return i
		  Next
		  
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ResolvedTargetPath(folder As String) As String
		  // TargetPath, with a relative path joined to the folder the command ran in: folder, or the
		  // folder of a leading `cd`. So `src/a.c` and `/work/src/a.c` name the same file.
		  Var target As String = TargetPath
		  If target = "" Or folder = "" Or IsAbsolutePath(target) Then Return target
		  
		  Var base As String = folder
		  If Kind = Kinds.ShellCommand Then
		    Var words() As String = ShellWords
		    If words.Count > 1 And (words(0) = "cd" Or words(0) = "pushd") And words(1) <> &u01 Then
		      If IsAbsolutePath(words(1)) Then
		        base = words(1)
		      Else
		        base = JoinPath(folder, words(1))
		      End If
		    End If
		  End If
		  
		  Return JoinPath(base, target)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ResultSeconds() As Double
		  // How long a tool call took, from the call to its result, or -1 when unknown.
		  If Timestamp Is Nil Or ResultTimestamp Is Nil Then Return -1
		  Var span As Double = ResultTimestamp.SecondsFrom1970 - Timestamp.SecondsFrom1970
		  Return If(span < 0, -1, span)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellArguments() As String()
		  // The program a shell command runs, followed by its arguments up to the next &&, ||, |, &
		  // or ;. Quotes are removed, so a quoted path with spaces is one word.
		  Var result() As String
		  If Kind <> Kinds.ShellCommand Then Return result
		  
		  Var words() As String = ShellWords
		  Var first As Integer = ProgramIndex(words)
		  If first < 0 Then Return result
		  For i As Integer = first To words.LastIndex
		    If words(i) = &u01 Then Exit
		    result.Add(words(i))
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellProgram() As String
		  // The program a shell command runs, such as "sed" or "git". Leading cd, export, source and
		  // VAR=value parts are skipped, so `cd x && sed -n 1p f` gives "sed".
		  If Kind <> Kinds.ShellCommand Then Return ""
		  
		  Var words() As String = ShellWords
		  Var first As Integer = ProgramIndex(words)
		  If first < 0 Then Return ""
		  Var word As String = words(first)
		  Return word.NthField("/", word.CountFields("/"))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ShellWords() As String()
		  // The words of the command's first line, with quotes removed, so a quoted path with spaces
		  // stays one word. Each unquoted &&, ||, |, &, ;, $(, (, ) or backtick becomes &u01, where a
		  // new command starts, so the program of `f=$(grep x a.c)` is grep.
		  // Only the first 2,000 characters are read: that's where the program and its files are.
		  Var line As String = Command.ReplaceLineEndings(&u0A).NthField(&u0A, 1).Left(2000)
		  Var words() As String
		  Var current As String
		  Var inWord As Boolean
		  Var quote As String
		  Var i As Integer
		  
		  While i < line.Length
		    Var c As String = line.Middle(i, 1)
		    
		    If quote <> "" Then
		      If c = quote Then
		        quote = ""
		      ElseIf c = "\" And quote = """" And i + 1 < line.Length Then
		        i = i + 1
		        current = current + line.Middle(i, 1)
		      Else
		        current = current + c
		      End If
		    ElseIf c = """" Or c = "'" Then
		      quote = c
		      inWord = True
		    ElseIf c = "\" And i + 1 < line.Length Then
		      i = i + 1
		      current = current + line.Middle(i, 1)
		      inWord = True
		    ElseIf c = " " Or c = &u09 Or c = "&" Or c = "|" Or c = ";" Or c = "(" Or c = ")" Or c = "`" Or _
		      (c = "$" And line.Middle(i + 1, 1) = "(") Then
		      If inWord Then words.Add(current)
		      current = ""
		      inWord = False
		      If c = "$" Then i = i + 1
		      If c <> " " And c <> &u09 Then
		        If (c = "&" Or c = "|") And line.Middle(i + 1, 1) = c Then i = i + 1
		        words.Add(&u01)
		      End If
		    Else
		      current = current + c
		      inWord = True
		    End If
		    
		    i = i + 1
		  Wend
		  
		  If inWord Then words.Add(current)
		  Return words
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Summary() As String
		  // One line describing the event, for lists and search results.
		  Var line As String
		  
		  Select Case Kind
		  Case Kinds.ShellCommand
		    line = "$ " + Command
		  Case Kinds.FileEdit
		    line = ToolName + " " + FilePath
		  Case Kinds.ToolCall
		    line = ToolName
		  Case Kinds.ToolResult
		    line = ResultText
		  Case Kinds.Thinking
		    line = If(Text.Trim = "", "(thinking)", Text)
		  Else
		    line = Text
		  End Select
		  
		  line = line.ReplaceLineEndings(" ").Trim
		  If line.Length > 200 Then line = line.Left(199) + "…"
		  Return line
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TargetPath() As String
		  // The file or folder a tool call worked on: its file_path, notebook_path or path input. For a
		  // shell command, the last word on its first line that looks like a file name.
		  If FilePath <> "" Then Return FilePath
		  
		  If Kind = Kinds.ShellCommand Then
		    Var words() As String = ShellWords
		    For i As Integer = words.LastIndex DownTo 1
		      Var word As String = words(i)
		      If word = &u01 Or word.BeginsWith("-") Or word.IndexOf(".") < 0 Then Continue
		      If ExtensionOf(word) <> "" Then Return word
		    Next
		    Return ""
		  End If
		  
		  If ToolInputJSON = "" Then Return ""
		  Try
		    Var toolInput As Dictionary = WakeCore.AsDictionary(ParseJSON(ToolInputJSON))
		    For Each key As String In Array("file_path", "notebook_path", "path")
		      Var value As String = WakeCore.JSONString(toolInput, key)
		      If value <> "" Then Return value
		    Next
		  Catch err As JSONException
		    Return ""
		  End Try
		  
		  Return ""
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AddedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		AddedUsage As WakeUsageGroup
	#tag EndProperty

	#tag Property, Flags = &h0
		CarriedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		CarriedUsage As WakeUsageGroup
	#tag EndProperty

	#tag Property, Flags = &h0
		Command As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FilePath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HasResult As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Interrupted As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsReread As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Kind As Kinds
	#tag EndProperty

	#tag Property, Flags = &h0
		LedNowhere As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		MessageID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Model As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Patch As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Pattern As WakeCallPattern.Patterns
	#tag EndProperty

	#tag Property, Flags = &h0
		PersistedOutputPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PersistedOutputSize As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		Response As WakeResponse
	#tag EndProperty

	#tag Property, Flags = &h0
		ResultIsError As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ResultText As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ResultTimestamp As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		Sequence As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Stderr As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Stdout As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Subagent As WakeSession
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SystemSubtype As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Text As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Timestamp As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		ToolInputJSON As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ToolName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ToolUseID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnActiveMs As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnCarriedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnCarriedUsage As WakeUsageGroup
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnContextTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnResponses As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnStartsNewContext As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnUsage As WakeUsageGroup
	#tag EndProperty


	#tag Enum, Name = Kinds, Type = Integer, Flags = &h0
		UserPrompt
		  AssistantText
		  Thinking
		  ToolCall
		  ShellCommand
		  FileEdit
		  ToolResult
		  Error
		System
	#tag EndEnum


End Class
#tag EndClass
