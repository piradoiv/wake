#tag Module
Protected Module TestSupport
	#tag Method, Flags = &h0
		Function ClaudeFixture(sessionNumber As Integer, projectFolder As String = "-Users-dev-demo") As FolderItem
		  // The fixture file for session N, e.g. 00000000-0000-4000-8000-000000000002.jsonl.
		  Var root As FolderItem = FixturesFolder("claude-code")
		  If root Is Nil Then Return Nil
		  
		  Return root.Child("projects").Child(projectFolder).Child(ClaudeFixtureID(sessionNumber) + ".jsonl")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ClaudeFixtureID(sessionNumber As Integer) As String
		  Var digits As String = sessionNumber.ToString
		  While digits.Length < 12
		    digits = "0" + digits
		  Wend
		  Return "00000000-0000-4000-8000-" + digits
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountEvents(session As WakeSession, kind As WakeEvent.Kinds) As Integer
		  Var total As Integer
		  For Each e As WakeEvent In session.Events
		    If e.Kind = kind Then total = total + 1
		  Next
		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindTool(session As WakeSession, toolUseID As String) As WakeEvent
		  For Each e As WakeEvent In session.Events
		    If e.ToolUseID = toolUseID Then Return e
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParseClaudeFixture(sessionNumber As Integer, projectFolder As String = "-Users-dev-demo") As WakeSession
		  Var parser As New ClaudeCodeParser
		  Return parser.ParseSession(ClaudeFixture(sessionNumber, projectFolder))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FixturesFolder(agentID As String) As FolderItem
		  // Returns tests/fixtures/<agentID> in the repository, or Nil when it can't be found.
		  Var root As FolderItem = RepositoryFolder
		  If root Is Nil Then Return Nil
		  
		  Var f As FolderItem = root.Child("tests").Child("fixtures").Child(agentID)
		  If f Is Nil Or Not f.Exists Then Return Nil
		  Return f
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ProjectFolder() As FolderItem
		  // The folder that holds Wake.xojo_project. Debug builds run from inside it (or a
		  // subfolder of it), so walk up from the executable until the project file is found.
		  Var f As FolderItem = App.ExecutableFile
		  
		  For depth As Integer = 0 To 10
		    If f Is Nil Then Return Nil
		    f = f.Parent
		    If f Is Nil Then Return Nil
		    
		    Var candidate As FolderItem = f.Child(kProjectFileName)
		    If candidate <> Nil And candidate.Exists Then Return f
		  Next
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RepositoryFolder() As FolderItem
		  Var project As FolderItem = ProjectFolder
		  If project Is Nil Then Return Nil
		  Return project.Parent
		End Function
	#tag EndMethod


	#tag Constant, Name = kProjectFileName, Type = String, Dynamic = False, Default = \"Wake.xojo_project", Scope = Public
	#tag EndConstant


End Module
#tag EndModule
