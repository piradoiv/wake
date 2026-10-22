#tag Class
Protected Class WakeChangedFile
	#tag Method, Flags = &h0
		Function ExistsOnDisk() As Boolean
		  // Whether the file is still there. Nothing is read from it.
		  Try
		    Var f As New FolderItem(TargetPath, FolderItem.PathModes.Native)
		    Return f.Exists
		  Catch err As RuntimeException
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  // The file's name, without its folders.
		  Var separator As String = If(Path.IndexOf("/") < 0 And Path.IndexOf("\") >= 0, "\", "/")
		  Return Path.NthField(separator, Path.CountFields(separator))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SessionCount() As Integer
		  Return SessionIDs.Count
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Edits As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		IsOutside As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		LastChanged As DateTime
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
		ProjectID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Reads As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		SessionIDs() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		TargetPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Tokens As Int64
	#tag EndProperty


End Class
#tag EndClass
