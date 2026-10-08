#tag Class
Protected Class WakeCostEstimate
	#tag Method, Flags = &h0
		Function HasTokens() As Boolean
		  Return PricedTokens + UnpricedTokens > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsComplete() As Boolean
		  // True when every model that used tokens has a price, so AmountUSD covers all of them.
		  Return UnpricedTokens = 0
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AmountUSD As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		PricedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		UnpricedModels() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UnpricedTokens As Int64
	#tag EndProperty


End Class
#tag EndClass
