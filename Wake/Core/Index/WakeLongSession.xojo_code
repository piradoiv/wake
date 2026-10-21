#tag Class
Protected Class WakeLongSession
Inherits WakeUsageGroup
	#tag Property, Flags = &h0
		PeakContextTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		Session As WakeSessionInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		TippingPrompt As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TippingTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		TippingTurn As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnCount As Integer
	#tag EndProperty


End Class
#tag EndClass
