#tag Module
Protected Module AgentRegistry
	#tag Method, Flags = &h0
		Function ParserFor(agentID As String) As IAgentParser
		  For Each parser As IAgentParser In Parsers
		    If parser.AgentID = agentID Then Return parser
		  Next

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parsers() As IAgentParser()
		  // Every supported agent. Adding an agent means adding its parser here.
		  If mParsers.Count = 0 Then
		    mParsers.Add(New ClaudeCodeParser)
		  End If

		  Return mParsers
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mParsers() As IAgentParser
	#tag EndProperty


End Module
#tag EndModule
