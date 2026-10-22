#tag Class
Protected Class WakeHistoryTurn
	#tag Method, Flags = &h0
		Function ChangeCount() As Integer
		  Var total As Integer
		  For Each entry As WakeHistoryEntry In Entries
		    If Not entry.IsRead Then total = total + 1
		  Next
		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FirstChange() As WakeHistoryEntry
		  // The turn's first change, or its first read when it changed nothing, or Nil.
		  For Each entry As WakeHistoryEntry In Entries
		    If Not entry.IsRead Then Return entry
		  Next
		  If Entries.Count > 0 Then Return Entries(0)
		  Return Nil
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Entries() As WakeHistoryEntry
	#tag EndProperty

	#tag Property, Flags = &h0
		Info As WakeSessionInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		Note As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Prompt As WakeEvent
	#tag EndProperty

	#tag Property, Flags = &h0
		Why As String
	#tag EndProperty


End Class
#tag EndClass
