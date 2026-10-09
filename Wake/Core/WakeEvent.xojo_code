#tag Class
Protected Class WakeEvent
	#tag Method, Flags = &h0
		Function IsToolCall() As Boolean
		  Return Kind = Kinds.ToolCall Or Kind = Kinds.ShellCommand Or Kind = Kinds.FileEdit
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

	#tag Method, Flags = &h0
		Function ResultSeconds() As Double
		  // How long a tool call took, from the call to its result, or -1 when unknown.
		  If Timestamp Is Nil Or ResultTimestamp Is Nil Then Return -1
		  Var span As Double = ResultTimestamp.SecondsFrom1970 - Timestamp.SecondsFrom1970
		  Return If(span < 0, -1, span)
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
		Kind As Kinds
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
		TurnResponses As Integer
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
