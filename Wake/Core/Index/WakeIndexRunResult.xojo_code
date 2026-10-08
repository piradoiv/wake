#tag Class
Protected Class WakeIndexRunResult
	#tag Method, Flags = &h0
		Function Summary() As String
		  Var line As String = FilesFound.ToString + " files: " + FilesIndexed.ToString + " indexed, " + _
		  FilesSkipped.ToString + " unchanged, " + FilesRemoved.ToString + " removed, " + FilesFailed.ToString + " failed"
		  If Cancelled Then line = line + " (cancelled)"
		  Return line
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Cancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Errors() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FilesFailed As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FilesFound As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FilesIndexed As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FilesRemoved As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FilesSkipped As Integer
	#tag EndProperty


End Class
#tag EndClass
