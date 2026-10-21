#tag Class
Protected Class WakeResponse
	#tag Method, Flags = &h0
		Sub Constructor(model As String, usage As WakeTokenUsage, startTime As DateTime, endTime As DateTime)
		  // Events point to their response, and a response names its events by sequence, so the two
		  // never hold each other.
		  Self.Model = model
		  Self.Usage = usage
		  Self.StartTime = startTime
		  Self.EndTime = endTime
		  FirstSequence = -1
		  TurnSequence = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContextTokens() As Int64
		  // Everything the model read for this response: new input, cache writes and cache reads.
		  Return Usage.InputTokens + Usage.CacheWriteTokens + Usage.CacheReadTokens
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NoteRecord(timestamp As DateTime)
		  // A response is written as several records. It ends with the last of them.
		  If timestamp Is Nil Then Return
		  If EndTime Is Nil Or timestamp.SecondsFrom1970 > EndTime.SecondsFrom1970 Then EndTime = timestamp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Seconds() As Double
		  // From the input it answered to its last record, or -1 when unknown. Timestamps can go
		  // backwards, so a negative span is unknown too.
		  If StartTime Is Nil Or EndTime Is Nil Then Return -1
		  Var span As Double = EndTime.SecondsFrom1970 - StartTime.SecondsFrom1970
		  Return If(span < 0, -1, span)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		EndTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstSequence As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		InputSequences() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Model As String
	#tag EndProperty

	#tag Property, Flags = &h0
		StartsNewContext As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		StartTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		TurnSequence As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Usage As WakeTokenUsage
	#tag EndProperty


End Class
#tag EndClass
