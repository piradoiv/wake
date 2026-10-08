#tag Class
Protected Class WakeProjectInfo
	#tag Method, Flags = &h0
		Function Name() As String
		  Return WakeFormat.ProjectName(Path)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LastActivity As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SessionCount As Integer
	#tag EndProperty


End Class
#tag EndClass
