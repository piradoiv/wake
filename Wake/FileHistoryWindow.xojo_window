#tag DesktopWindow
Begin DesktopWindow FileHistoryWindow
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   0
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   True
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   HasTitleBar     =   True
   Height          =   760
   ImplicitInstance=   False
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   478898175
   MenuBarVisible  =   False
   MinimumHeight   =   400
   MinimumWidth    =   480
   Resizeable      =   True
   Title           =   "File History"
   Type            =   0
   Visible         =   True
   Width           =   960
   Begin DesktopCheckBox ShowReadsCheckBox
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Show reads"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   2
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Also list the reads of this file, in the sessions that changed it"
      Top             =   12
      Transparent     =   False
      Underline       =   False
      Value           =   False
      Visible         =   True
      VisualState     =   0
      Width           =   200
   End
   Begin DesktopHTMLViewer HistoryViewer
      AutoDeactivate  =   True
      Enabled         =   True
      Height          =   718
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Renderer        =   0
      Scope           =   2
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Visible         =   True
      Width           =   960
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag MenuHandler
		Function FileCloseWindow() As Boolean Handles FileCloseWindow.Action
		  Self.Close
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileExportMarkdown() As Boolean Handles FileExportMarkdown.Action
		  App.ExportFileHistory(mHistory)
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ViewWatchForChanges() As Boolean Handles ViewWatchForChanges.Action
		  App.ToggleWatching
		  Return True
		End Function
	#tag EndMenuHandler

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


	#tag Method, Flags = &h21
		Private Sub OpenPendingLink()
		  // Opens the timeline a header asked for, after the page's call has returned.
		  Var link As WakeFileChangeInfo = mPendingLink
		  mPendingLink = Nil
		  If link <> Nil Then App.OpenTimeline(link.Session, link.EventSessionUID, link.Sequence)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PricesChanged()
		  // The page's costs are filled in by script, so it keeps its scroll position and open blocks.
		  If Not mLoadingPage Then ShowCosts
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowCosts()
		  // The JSON holds only generated ids and formatted amounts, never transcript text.
		  If mHistory Is Nil Then Return
		  HistoryViewer.ExecuteJavaScript("wakeSetCosts(" + mHistory.CostsJSON(App.Prices) + ");")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowHistory(history As WakeFileHistory)
		  // The history re-parsed only the sessions that changed the file, read-only.
		  mHistory = history
		  Title = "History of " + history.FileName
		  mLoadingPage = True
		  HistoryViewer.LoadPage(history.HTML, Nil)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowReads()
		  If mLoadingPage Then Return
		  HistoryViewer.ExecuteJavaScript("wakeShowReads(" + If(ShowReadsCheckBox.Value, "true", "false") + ");")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TargetPath() As String
		  // The file shown, as the index resolves it, so a file opens in one window.
		  If mHistory Is Nil Then Return ""
		  Return mHistory.TargetPath
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mHistory As WakeFileHistory
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLoadingPage As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingLink As WakeFileChangeInfo
	#tag EndProperty


#tag EndWindowCode

#tag Events ShowReadsCheckBox
	#tag Event
		Sub ValueChanged()
		  ShowReads
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events HistoryViewer
	#tag Event
		Function CancelLoad(URL as String) As Boolean
		  // Only the generated page may load, so the viewer never leaves it or reaches the network.
		  #Pragma Unused URL
		  Return Not mLoadingPage
		End Function
	#tag EndEvent
	#tag Event
		Sub DocumentComplete(url as String)
		  #Pragma Unused URL
		  mLoadingPage = False
		  ShowCosts
		  ShowReads
		End Sub
	#tag EndEvent
	#tag Event
		Function JavaScriptRequest(method As String, parameters() as Variant) As String
		  // The page calls executeInXojoSync to expand a long block, and to open a session's timeline
		  // from a header. The window opens once the call has returned.
		  If mHistory Is Nil Or parameters.Count = 0 Then Return ""
		  If method = "open" Then
		    mPendingLink = mHistory.ChangeFor(parameters(0).StringValue)
		    Timer.CallLater(0, AddressOf OpenPendingLink)
		    Return ""
		  End If
		  Return mHistory.Request(method, parameters(0).StringValue)
		End Function
	#tag EndEvent
#tag EndEvents
