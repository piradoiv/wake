#tag Class
Protected Class WakeFileChangeInfo
	#tag Property, Flags = &h0
		Action As String
	#tag EndProperty

	#tag Property, Flags = &h0
		EventSessionUID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InSubagent As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		LinesAdded As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LinesRemoved As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Prompt As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PromptSequence As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		Sequence As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Session As WakeSessionInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		TargetPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Timestamp As DateTime
	#tag EndProperty


End Class
#tag EndClass
