#tag Class
Protected Class WakeUsageGroup
	#tag Method, Flags = &h0
		Sub Add(model As String, amount As WakeTokenUsage)
		  Var perModel As WakeTokenUsage = WakeTokenUsage(ByModel.Lookup(model, Nil).ObjectValue)
		  If perModel Is Nil Then
		    perModel = New WakeTokenUsage
		    ByModel.Value(model) = perModel
		  End If
		  perModel.Add(amount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  ByModel = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total() As WakeTokenUsage
		  Var result As New WakeTokenUsage
		  For Each model As Variant In ByModel.Keys
		    result.Add(WakeTokenUsage(ByModel.Value(model).ObjectValue))
		  Next
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ByModel As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Key As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Label As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SessionCount As Integer
	#tag EndProperty


End Class
#tag EndClass
