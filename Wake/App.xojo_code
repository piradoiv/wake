#tag Class
Protected Class App
Inherits DesktopApplication
	#tag Event
		Sub Opening()
		  #If DebugBuild Then
		    RunTestsIfRequested
		  #EndIf
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub RunTestsIfRequested()
		  // Debug-only test mode: when a WakeRunTests marker file sits next to the project file,
		  // run every XojoUnit group, export JUnit XML to tests/results.xml and quit.
		  Var project As FolderItem = TestSupport.ProjectFolder
		  If project Is Nil Then Return

		  Var marker As FolderItem = project.Child(kTestMarkerName)
		  If marker Is Nil Or Not marker.Exists Then Return

		  Try
		    marker.Remove
		  Catch err As IOException
		    System.DebugLog("Wake: could not remove test marker: " + err.Message)
		  End Try

		  mTestController = New WakeTestController
		  AddHandler mTestController.AllTestsFinished, AddressOf TestController_AllTestsFinished
		  mTestController.LoadTestGroups
		  mTestController.Start
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TestController_AllTestsFinished(sender As TestController)
		  Var repo As FolderItem = TestSupport.RepositoryFolder

		  Try
		    Var results As FolderItem = repo.Child("tests").Child("results.xml")
		    sender.ExportTestResults(results.ShellPath)
		  Catch err As IOException
		    System.DebugLog("Wake: could not export test results: " + err.Message)
		  Catch err As NilObjectException
		    System.DebugLog("Wake: repository folder not found, test results not exported")
		  End Try

		  Quit
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mTestController As WakeTestController
	#tag EndProperty


	#tag Constant, Name = kTestMarkerName, Type = String, Dynamic = False, Default = \"WakeRunTests", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


End Class
#tag EndClass
