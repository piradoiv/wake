#tag Module
Protected Module WakeCore
	#tag Method, Flags = &h0
		Function AsDictionary(value As Variant) As Dictionary
		  // Returns value as a Dictionary, or Nil when it holds anything else.
		  If value.Type = Variant.TypeObject And value.ObjectValue IsA Dictionary Then
		    Return Dictionary(value.ObjectValue)
		  End If

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileSignature(agentID As String, filePath As String) As String
		  // The size and modification time of a transcript and of the side files parsed with it,
		  // such as subagent transcripts. It changes whenever the session does. Empty when the
		  // file is missing.
		  Var f As FolderItem
		  Try
		    f = New FolderItem(filePath, FolderItem.PathModes.Native)
		  Catch err As UnsupportedFormatException
		    Return ""
		  Catch err As IOException
		    Return ""
		  End Try
		  If f Is Nil Or Not f.Exists Then Return ""

		  Var entries() As String
		  Var parser As IAgentParser = AgentRegistry.ParserFor(agentID)
		  If parser <> Nil Then
		    For Each related As FolderItem In parser.RelatedFiles(f)
		      entries.Add(related.Name + ":" + related.Length.ToString + ":" + ModifiedTimeText(related))
		    Next
		  End If
		  entries.Sort
		  entries.AddAt(0, f.Length.ToString + ":" + ModifiedTimeText(f))

		  Return String.FromArray(entries, ";")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONArray(d As Dictionary, key As String) As Variant()
		  // The array stored under key, or an empty array when it is missing or not an array.
		  Var result() As Variant
		  If d Is Nil Then Return result

		  Var value As Variant = d.Lookup(key, Nil)
		  If value.IsArray Then
		    Try
		      result = value
		    Catch err As TypeMismatchException
		      // An array of a type other than Variant: treat it as missing.
		    End Try
		  End If

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONBoolean(d As Dictionary, key As String) As Boolean
		  If d Is Nil Then Return False

		  Var value As Variant = d.Lookup(key, Nil)
		  If value.Type = Variant.TypeBoolean Then Return value.BooleanValue

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONDictionary(d As Dictionary, key As String) As Dictionary
		  If d Is Nil Then Return Nil
		  Return AsDictionary(d.Lookup(key, Nil))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONDouble(d As Dictionary, key As String, defaultValue As Double = 0.0) As Double
		  If d Is Nil Then Return defaultValue

		  Var value As Variant = d.Lookup(key, Nil)
		  Select Case value.Type
		  Case Variant.TypeInt32, Variant.TypeInt64, Variant.TypeDouble, Variant.TypeSingle, Variant.TypeCurrency
		    Return value.DoubleValue
		  End Select

		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONInteger(d As Dictionary, key As String) As Int64
		  If d Is Nil Then Return 0

		  Var value As Variant = d.Lookup(key, Nil)
		  Select Case value.Type
		  Case Variant.TypeInt32, Variant.TypeInt64, Variant.TypeDouble, Variant.TypeSingle, Variant.TypeCurrency
		    Return value.Int64Value
		  End Select

		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONString(d As Dictionary, key As String, defaultValue As String = "") As String
		  If d Is Nil Then Return defaultValue

		  Var value As Variant = d.Lookup(key, Nil)
		  If value.Type = Variant.TypeString Then Return value.StringValue

		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadSession(agentID As String, filePath As String) As WakeSession
		  // Parses a transcript read-only, for the timeline or an export. Never raises: a missing
		  // file or an unknown agent gives an empty session whose report says why.
		  Var session As WakeSession
		  Var parser As IAgentParser = AgentRegistry.ParserFor(agentID)

		  If parser Is Nil Then
		    session = New WakeSession
		    session.AgentID = agentID
		    session.Report.FileError = "Wake can't read sessions of agent """ + agentID + """"
		    Return session
		  End If

		  Var f As FolderItem
		  Try
		    f = New FolderItem(filePath, FolderItem.PathModes.Native)
		  Catch err As UnsupportedFormatException
		    f = Nil
		  Catch err As IOException
		    f = Nil
		  End Try

		  If f Is Nil Or Not f.Exists Then
		    session = New WakeSession
		    session.AgentID = agentID
		    session.Report.FileError = "the transcript is no longer at " + filePath
		    Return session
		  End If

		  Return parser.ParseSession(f)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewCaseSensitiveDictionary() As Dictionary
		  // A plain Dictionary compares String keys case-insensitively. Dictionaries created by
		  // ParseJSON are case-sensitive, which ids such as "toolu_aB" and "toolu_Ab" need.
		  Return ParseJSON("{}")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParseISO8601(value As String) As DateTime
		  // Parses "2026-09-01T10:00:00.123Z" or "2026-09-01T10:00:00+02:00".
		  // Returns Nil for anything it does not understand.
		  If value.Length < 19 Then Return Nil
		  If value.Middle(4, 1) <> "-" Or value.Middle(7, 1) <> "-" Then Return Nil
		  If value.Middle(10, 1) <> "T" And value.Middle(10, 1) <> " " Then Return Nil
		  If value.Middle(13, 1) <> ":" Or value.Middle(16, 1) <> ":" Then Return Nil

		  Var year As Integer = value.Middle(0, 4).ToInteger
		  Var month As Integer = value.Middle(5, 2).ToInteger
		  Var day As Integer = value.Middle(8, 2).ToInteger
		  Var hour As Integer = value.Middle(11, 2).ToInteger
		  Var minute As Integer = value.Middle(14, 2).ToInteger
		  Var second As Integer = value.Middle(17, 2).ToInteger

		  If year < 1970 Or month < 1 Or month > 12 Or day < 1 Or day > 31 Then Return Nil
		  If hour > 23 Or minute > 59 Or second > 60 Then Return Nil

		  Var pos As Integer = 19
		  Var nanoseconds As Integer = 0

		  If value.Middle(pos, 1) = "." Then
		    pos = pos + 1
		    Var digits As String
		    While pos < value.Length And IsDigit(value.Middle(pos, 1))
		      digits = digits + value.Middle(pos, 1)
		      pos = pos + 1
		    Wend
		    If digits.Length > 9 Then digits = digits.Left(9)
		    While digits.Length < 9
		      digits = digits + "0"
		    Wend
		    nanoseconds = digits.ToInteger
		  End If

		  Var offsetSeconds As Integer = 0
		  Var zone As String = value.Middle(pos)

		  If zone = "Z" Or zone = "" Then
		    offsetSeconds = 0
		  ElseIf zone.Length = 6 And (zone.Left(1) = "+" Or zone.Left(1) = "-") And zone.Middle(3, 1) = ":" Then
		    offsetSeconds = zone.Middle(1, 2).ToInteger * 3600 + zone.Middle(4, 2).ToInteger * 60
		    If zone.Left(1) = "-" Then offsetSeconds = -offsetSeconds
		  Else
		    Return Nil
		  End If

		  Try
		    Return New DateTime(year, month, day, hour, minute, second, nanoseconds, New TimeZone(offsetSeconds))
		  Catch err As InvalidArgumentException
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RelativePath(path As String, folder As String) As String
		  // path relative to folder, or path unchanged when it isn't inside folder.
		  If folder = "" Then Return path
		  
		  For Each separator As String In Array("/", "\")
		    Var prefix As String = If(folder.EndsWith(separator), folder, folder + separator)
		    If path.Length > prefix.Length And path.BeginsWith(prefix, ComparisonOptions.CaseSensitive) Then
		      Return path.Middle(prefix.Length)
		    End If
		  Next
		  
		  Return path
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsDigit(character As String) As Boolean
		  Return character >= "0" And character <= "9" And character.Length = 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ModifiedTimeText(f As FolderItem) As String
		  // Whole milliseconds, like the index stores them.
		  Var modified As DateTime = f.ModificationDateTime
		  If modified Is Nil Then Return "0"
		  Var ms As Int64 = Round(modified.SecondsFrom1970 * 1000)
		  Return ms.ToString
		End Function
	#tag EndMethod


End Module
#tag EndModule
