#tag Class
Protected Class WakeToolCallInfo
	#tag Method, Flags = &h0
		Sub Constructor()
		  Usage = New WakeUsageGroup
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Description() As String
		  // The event's summary, with the target added when the summary is only the tool's name.
		  If Summary = "" Or Summary = ToolName Then
		    If TargetPath = "" Then Return If(Summary = "", ToolName, Summary)
		    Return ToolName + " " + TargetPath
		  End If
		  Return Summary
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AddedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		CarriedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		EventSessionUID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Sequence As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Session As WakeSessionInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		Summary As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TargetPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Timestamp As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		ToolName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Usage As WakeUsageGroup
	#tag EndProperty


End Class
#tag EndClass
