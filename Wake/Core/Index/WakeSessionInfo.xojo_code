#tag Class
Protected Class WakeSessionInfo
	#tag Method, Flags = &h0
		Function DisplayTitle() As String
		  // The agent's title, else the first prompt, else what the session was for.
		  If Title <> "" Then Return WakeFormat.OneLine(Title, kMaxTitleLength)
		  If FirstPrompt <> "" Then Return WakeFormat.OneLine(FirstPrompt, kMaxTitleLength)
		  If SubagentDescription <> "" Then Return WakeFormat.OneLine(SubagentDescription, kMaxTitleLength)
		  If IsCommandOnly Then Return "(commands only)"
		  Return "(untitled)"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DurationSeconds() As Double
		  // Wall-clock time from the first to the last record, idle time included. -1 when unknown.
		  If StartTime Is Nil Or EndTime Is Nil Then Return -1
		  Return Max(0.0, EndTime.SecondsFrom1970 - StartTime.SecondsFrom1970)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsLive(now As DateTime) As Boolean
		  // True while the agent is probably still writing the session: its transcript changed in the
		  // last kLiveSeconds. A clock a little ahead of the file's still counts.
		  If FileModified Is Nil Or now Is Nil Then Return False
		  Var age As Double = now.SecondsFrom1970 - FileModified.SecondsFrom1970
		  Return age > -kLiveSeconds And age < kLiveSeconds
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		ActiveMs As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		AgentCostUSD As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AgentVersion As String
	#tag EndProperty

	#tag Property, Flags = &h0
		EndTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		EventCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FileModified As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		FilePath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstPrompt As String
	#tag EndProperty

	#tag Property, Flags = &h0
		GitBranch As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HasAgentCost As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		IsCommandOnly As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsPartial As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Models() As Pair
	#tag EndProperty

	#tag Property, Flags = &h0
		OwnUsage As WakeTokenUsage
	#tag EndProperty

	#tag Property, Flags = &h0
		ParentID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ParseNote As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PromptCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		StartTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentDescription As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TotalUsage As WakeTokenUsage
	#tag EndProperty

	#tag Property, Flags = &h0
		UID As String
	#tag EndProperty


	#tag Constant, Name = kLiveSeconds, Type = Double, Dynamic = False, Default = \"120", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMaxTitleLength, Type = Double, Dynamic = False, Default = \"200", Scope = Public
	#tag EndConstant


End Class
#tag EndClass
