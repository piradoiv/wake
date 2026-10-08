#tag Class
Protected Class WakeModelPrice
	#tag Method, Flags = &h0
		Sub Constructor(model As String)
		  Self.Model = model
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Cost(amount As WakeTokenUsage) As Double
		  // The price of amount in US dollars. One-hour cache writes use the five-minute price
		  // when no one-hour price is set.
		  If amount Is Nil Then Return 0
		  
		  Var longRate As Double = If(CacheWrite1hPerMillion > 0, CacheWrite1hPerMillion, CacheWritePerMillion)
		  Var shortWrites As Int64 = amount.CacheWriteTokens - amount.CacheWrite1hTokens
		  
		  Var perMillion As Double = amount.InputTokens * InputPerMillion + amount.OutputTokens * OutputPerMillion + _
		  shortWrites * CacheWritePerMillion + amount.CacheWrite1hTokens * longRate + _
		  amount.CacheReadTokens * CacheReadPerMillion
		  Return perMillion / 1000000
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		CacheReadPerMillion As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		CacheWrite1hPerMillion As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		CacheWritePerMillion As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		InputPerMillion As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		Model As String
	#tag EndProperty

	#tag Property, Flags = &h0
		OutputPerMillion As Double
	#tag EndProperty


End Class
#tag EndClass
