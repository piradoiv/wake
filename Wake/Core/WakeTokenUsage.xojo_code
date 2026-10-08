#tag Class
Protected Class WakeTokenUsage
	#tag Method, Flags = &h0
		Sub Add(other As WakeTokenUsage)
		  If other Is Nil Then Return

		  InputTokens = InputTokens + other.InputTokens
		  OutputTokens = OutputTokens + other.OutputTokens
		  CacheWriteTokens = CacheWriteTokens + other.CacheWriteTokens
		  CacheReadTokens = CacheReadTokens + other.CacheReadTokens
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone() As WakeTokenUsage
		  Var copy As New WakeTokenUsage
		  copy.Add(Self)
		  Return copy
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsEmpty() As Boolean
		  Return Total = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total() As Int64
		  Return InputTokens + OutputTokens + CacheWriteTokens + CacheReadTokens
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		CacheReadTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		CacheWriteTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		InputTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		OutputTokens As Int64
	#tag EndProperty


End Class
#tag EndClass
