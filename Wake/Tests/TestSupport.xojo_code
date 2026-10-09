#tag Module
Protected Module TestSupport
	#tag Method, Flags = &h0
		Function ClaudeFixture(sessionNumber As Integer, projectFolder As String = "-Users-dev-demo", rootName As String = "projects") As FolderItem
		  // The fixture file for session N, e.g. 00000000-0000-4000-8000-000000000002.jsonl. Session 7
		  // is in the "patterns" root.
		  Var root As FolderItem = FixturesFolder("claude-code")
		  If root Is Nil Then Return Nil
		  
		  Return root.Child(rootName).Child(projectFolder).Child(ClaudeFixtureID(sessionNumber) + ".jsonl")
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
		Sub AppendLine(f As FolderItem, line As String)
		  // Only for scratch copies of fixtures. Never use this on a real transcript.
		  Var output As TextOutputStream
		  If f.Exists Then
		    output = TextOutputStream.Open(f)
		  Else
		    output = TextOutputStream.Create(f)
		  End If
		  output.Encoding = Encodings.UTF8
		  output.WriteLine(line)
		  output.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CopyFolder(source As FolderItem, destination As FolderItem)
		  // Recursive copy, used to give tests a scratch copy of the fixtures.
		  If Not destination.Exists Then destination.CreateFolder

		  For Each child As FolderItem In source.Children
		    If child.IsFolder Then
		      CopyFolder(child, destination.Child(child.Name))
		    Else
		      child.CopyTo(destination.Child(child.Name))
		    End If
		  Next
		End Sub
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
		Function NewScratchFolder() As FolderItem
		  // An empty folder in the system temporary folder. Remove it with RemoveScratchFolder.
		  Var f As FolderItem = SpecialFolder.Temporary.Child(kScratchPrefix + System.Random.InRange(100000, 999999).ToString)
		  f.CreateFolder
		  Return f
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParseClaudeFixture(sessionNumber As Integer, projectFolder As String = "-Users-dev-demo", rootName As String = "projects") As WakeSession
		  Var parser As New ClaudeCodeParser
		  Return parser.ParseSession(ClaudeFixture(sessionNumber, projectFolder, rootName))
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
		Sub RemoveScratchFolder(f As FolderItem)
		  // Refuses anything that isn't a scratch folder made by NewScratchFolder.
		  If f Is Nil Or Not f.Exists Or Not f.Name.BeginsWith(kScratchPrefix) Then Return

		  Try
		    f.RemoveFolderAndContents
		  Catch err As IOException
		    System.DebugLog("Wake tests: could not remove " + f.NativePath + ": " + err.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RepositoryFolder() As FolderItem
		  Var project As FolderItem = ProjectFolder
		  If project Is Nil Then Return Nil
		  Return project.Parent
		End Function
	#tag EndMethod


	#tag Constant, Name = kScratchPrefix, Type = String, Dynamic = False, Default = \"wake-test-", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kProjectFileName, Type = String, Dynamic = False, Default = \"Wake.xojo_project", Scope = Public
	#tag EndConstant


End Module
#tag EndModule
