#tag Class
Protected Class WakeSearchHit
	#tag Method, Flags = &h0
		Shared Function MatchEnd() As String
		  Return &u03
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MatchStart() As String
		  // Snippet marks each matched term with MatchStart and MatchEnd. The index replaces these
		  // control characters in the text it stores, so they only ever mark matches.
		  Return &u02
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PlainSnippet() As String
		  // The snippet without its match markers.
		  Return Snippet.ReplaceAll(MatchStart, "").ReplaceAll(MatchEnd, "")
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		EventID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		EventSessionUID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FilePath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InSubagent As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Kind As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Sequence As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Session As WakeSessionInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		Snippet As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Timestamp As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		ToolName As String
	#tag EndProperty


End Class
#tag EndClass
