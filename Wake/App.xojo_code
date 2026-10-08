#tag Class
Protected Class App
Inherits DesktopApplication
	#tag Event
		Sub MenuBarSelected()
		  // Auto-enable leaves this item greyed out, so it's enabled here.
		  FileCloseWindow.Enabled = WindowCount > 0
		End Sub
	#tag EndEvent

	#tag Event
		Sub Opening()
		  #If DebugBuild Then
		    If RunTestsIfRequested Then Return
		  #EndIf
		  
		  StartIndexing
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function WindowPrices() As Boolean Handles WindowPrices.Action
		  PricesWindow.Show
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function WindowUsage() As Boolean Handles WindowUsage.Action
		  UsageWindow.Show
		  Return True
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h0
		Sub ExportMarkdown(info As WakeSessionInfo)
		  // Asks where to save a Markdown report of a session and writes it there. The transcript is
		  // only read, and the report can never be saved over it.
		  If info Is Nil Then Return
		  
		  Var report As New WakeMarkdown(WakeCore.LoadSession(info.AgentID, info.FilePath), Prices)
		  
		  // A file name from the title, without characters that some systems don't allow.
		  Var name As String = report.Title
		  For Each character As String In Array("/", "\", ":", "*", "?", """", "<", ">", "|")
		    name = name.ReplaceAll(character, " ")
		  Next
		  name = WakeFormat.OneLine(name, 80).Replace(WakeFormat.kEllipsis, "").Trim
		  If name = "" Then name = "Session"
		  
		  Var f As FolderItem = FolderItem.ShowSaveFileDialog("", name + ".md")
		  If f Is Nil Then Return
		  
		  If f.NativePath = info.FilePath Or f.Name.EndsWith(".jsonl") Then
		    MessageBox("Wake doesn't write over transcripts. Choose another name.")
		    Return
		  End If
		  
		  Try
		    Var output As TextOutputStream = TextOutputStream.Create(f)
		    output.Encoding = Encodings.UTF8
		    output.Write(report.Markdown)
		    output.Close
		  Catch err As IOException
		    MessageBox("Could not save the report: " + err.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndexThread_Failed(sender As WakeIndexThread, message As String)
		  #Pragma Unused sender
		  System.DebugLog("Wake: " + message)
		  
		  For Each w As MainWindow In MainWindows
		    w.IndexingFailed(message)
		  Next
		  
		  Var usage As UsageWindow = OpenUsageWindow
		  If usage <> Nil Then usage.IndexingFinished
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndexThread_Finished(sender As WakeIndexThread, result As WakeIndexRunResult)
		  #Pragma Unused sender
		  System.DebugLog("Wake: indexed " + result.Summary)
		  For Each message As String In result.Errors
		    System.DebugLog("Wake: " + message)
		  Next
		  
		  For Each w As MainWindow In MainWindows
		    w.IndexingFinished(result)
		  Next
		  
		  Var usage As UsageWindow = OpenUsageWindow
		  If usage <> Nil Then usage.IndexingFinished
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndexThread_Progress(sender As WakeIndexThread, done As Integer, total As Integer, currentPath As String)
		  #Pragma Unused sender
		  #Pragma Unused currentPath
		  
		  For Each w As MainWindow In MainWindows
		    w.IndexingProgress(done, total)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsIndexing() As Boolean
		  Return IndexThread <> Nil And IndexThread.ThreadState <> Thread.ThreadStates.NotRunning
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MainWindows() As MainWindow()
		  // The browse windows that are open. Going through the implicit MainWindow instance
		  // would reopen a window the user closed.
		  Var result() As MainWindow
		  For i As Integer = 0 To WindowCount - 1
		    If WindowAt(i) IsA MainWindow Then result.Add(MainWindow(WindowAt(i)))
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OpenUsageWindow() As UsageWindow
		  // The usage window if it is open. Going through its implicit instance would open it.
		  For i As Integer = 0 To WindowCount - 1
		    If WindowAt(i) IsA UsageWindow Then Return UsageWindow(WindowAt(i))
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Prices() As WakePriceTable
		  // The user's price table, read from the app data folder the first time it is needed.
		  If mPrices Is Nil Then
		    mPrices = WakePriceTable.Load(WakeFolders.PricesFile)
		    If mPrices.LoadError <> "" Then System.DebugLog("Wake: " + mPrices.LoadError)
		  End If
		  Return mPrices
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PricesChanged()
		  // Saves the price table and updates every cost on screen.
		  Try
		    Prices.Save(WakeFolders.PricesFile)
		    mPrices.LoadError = ""
		  Catch err As IOException
		    MessageBox("Could not save the prices: " + err.Message)
		  End Try
		  
		  For Each w As MainWindow In MainWindows
		    w.PricesChanged
		  Next
		  
		  Var usage As UsageWindow = OpenUsageWindow
		  If usage <> Nil Then usage.PricesChanged
		  
		  For i As Integer = 0 To WindowCount - 1
		    If WindowAt(i) IsA SessionWindow Then SessionWindow(WindowAt(i)).PricesChanged
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunTestsIfRequested() As Boolean
		  // Debug-only test mode: when a WakeRunTests marker file sits next to the project file,
		  // run every XojoUnit group, export JUnit XML to tests/results.xml and quit.
		  Var project As FolderItem = TestSupport.ProjectFolder
		  If project Is Nil Then Return False
		  
		  Var marker As FolderItem = project.Child(kTestMarkerName)
		  If marker Is Nil Or Not marker.Exists Then Return False
		  
		  Try
		    marker.Remove
		  Catch err As IOException
		    System.DebugLog("Wake: could not remove test marker: " + err.Message)
		  End Try
		  
		  mTestController = New WakeTestController
		  AddHandler mTestController.AllTestsFinished, AddressOf TestController_AllTestsFinished
		  mTestController.LoadTestGroups
		  mTestController.Start
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartIndexing()
		  // Brings the index up to date in the background. Does nothing if a run is in progress.
		  If IsIndexing Then Return
		  
		  IndexThread = New WakeIndexThread(WakeFolders.DefaultIndexFile, WakeFolders.AllRoots)
		  AddHandler IndexThread.Progress, AddressOf IndexThread_Progress
		  AddHandler IndexThread.Finished, AddressOf IndexThread_Finished
		  AddHandler IndexThread.Failed, AddressOf IndexThread_Failed
		  IndexThread.Start
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


	#tag Property, Flags = &h0
		IndexThread As WakeIndexThread
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrices As WakePriceTable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTestController As WakeTestController
	#tag EndProperty


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

	#tag Constant, Name = kTestMarkerName, Type = String, Dynamic = False, Default = \"WakeRunTests", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
