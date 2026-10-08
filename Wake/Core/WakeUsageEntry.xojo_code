#tag Class
Protected Class WakeUsageEntry
	#tag Method, Flags = &h0
		Sub Constructor(timestamp As DateTime, model As String, usage As WakeTokenUsage)
		  Self.Timestamp = timestamp
		  Self.Model = model
		  Self.Usage = usage
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Model As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Timestamp As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		Usage As WakeTokenUsage
	#tag EndProperty


End Class
#tag EndClass
