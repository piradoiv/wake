#tag DesktopWindow
Begin DesktopWindow SessionWindow
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
   Title           =   "Session"
   Type            =   0
   Visible         =   True
   Width           =   960
   Begin WakeGlanceTiles GlanceTiles
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Heading         =   ""
      Height          =   138
      Index           =   -2147483648
      Left            =   12
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   2
      Subheading      =   ""
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   0
      Transparent     =   True
      Visible         =   True
      Width           =   936
   End
   Begin DesktopButton ExpandButton
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Expand all"
      Default         =   False
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
      MacButtonStyle  =   0
      Scope           =   2
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   138
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   96
   End
   Begin DesktopButton CollapseButton
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Collapse all"
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   128
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   2
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   138
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   96
   End
   Begin DesktopHTMLViewer TimelineViewer
      AutoDeactivate  =   True
      Enabled         =   True
      Height          =   592
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
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   168
      Visible         =   True
      Width           =   960
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Resized()
		  LayOutHeader
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resizing()
		  LayOutHeader
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FileCloseWindow() As Boolean Handles FileCloseWindow.Action
		  Self.Close
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileExportMarkdown() As Boolean Handles FileExportMarkdown.Action
		  App.ExportMarkdown(mInfo)
		  Return True
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h21
		Private Sub LayOutHeader()
		  // The tiles take the height their rows need at this width, then the buttons, then the page.
		  // The canvas pads its tiles by 12, so they line up with the page's 24-point margin.
		  GlanceTiles.Left = 12
		  GlanceTiles.Width = Width - 24
		  GlanceTiles.Height = GlanceTiles.HeightFor(GlanceTiles.Width)
		  
		  ExpandButton.Top = GlanceTiles.Top + GlanceTiles.Height
		  CollapseButton.Top = ExpandButton.Top
		  
		  TimelineViewer.Top = ExpandButton.Top + ExpandButton.Height + 10
		  TimelineViewer.Height = Height - TimelineViewer.Top
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PricesChanged()
		  // Only the cost tile depends on the prices, and it is native, so the page stays as it is.
		  ShowTiles
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SessionID() As Integer
		  Return mSessionID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowEvent(sessionUID As String, sequence As Integer)
		  // Scrolls to an event and highlights it, opening the blocks around it. sessionUID is the uid
		  // of the session or subagent the event belongs to.
		  If mTimeline Is Nil Then Return
		  Var anchor As String = mTimeline.Anchor(sessionUID, sequence)
		  If anchor = "" Then Return
		  
		  If mLoadingPage Then
		    mPendingAnchor = anchor
		  Else
		    TimelineViewer.ExecuteJavaScript("wakeGoTo('" + anchor + "');")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowSession(info As WakeSessionInfo)
		  // The timeline re-parses the transcript, read-only. The index holds only summaries.
		  mSessionID = info.ID
		  mInfo = info
		  Title = info.DisplayTitle
		  mTimeline = WakeTimeline.Load(info.AgentID, info.FilePath)
		  ShowTiles
		  
		  mLoadingPage = True
		  mPendingAnchor = ""
		  TimelineViewer.LoadPage(mTimeline.HTML, Nil)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowTiles()
		  // The same tiles as the main window, with the cost from the parsed transcript, and the full
		  // path and branch under the title.
		  If mInfo Is Nil Or mTimeline Is Nil Then Return
		  GlanceTiles.ShowSession(mInfo, mTimeline.Session.TotalUsageByModel, App.Prices)
		  
		  Var facts() As String
		  If mInfo.ProjectPath <> "" Then facts.Add(mInfo.ProjectPath)
		  If mInfo.GitBranch <> "" Then facts.Add(mInfo.GitBranch)
		  If mInfo.StartTime <> Nil Then facts.Add(mInfo.StartTime.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short))
		  GlanceTiles.Subheading = String.FromArray(facts, " · ")
		  
		  LayOutHeader
		  GlanceTiles.Refresh(False)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mInfo As WakeSessionInfo
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLoadingPage As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingAnchor As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSessionID As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTimeline As WakeTimeline
	#tag EndProperty


#tag EndWindowCode

#tag Events ExpandButton
	#tag Event
		Sub Pressed()
		  If Not mLoadingPage Then TimelineViewer.ExecuteJavaScript("wakeAll(true);")
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events CollapseButton
	#tag Event
		Sub Pressed()
		  If Not mLoadingPage Then TimelineViewer.ExecuteJavaScript("wakeAll(false);")
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events TimelineViewer
	#tag Event
		Function CancelLoad(URL as String) As Boolean
		  // Only the generated page may load. Anything after it, such as a dropped file, is blocked,
		  // so the viewer never leaves the timeline or reaches the network.
		  #Pragma Unused URL
		  Return Not mLoadingPage
		End Function
	#tag EndEvent
	#tag Event
		Sub DocumentComplete(url as String)
		  #Pragma Unused URL
		  mLoadingPage = False
		  
		  // A search hit asked for an event before the page was ready. Anchors are generated ids,
		  // never transcript text.
		  If mPendingAnchor <> "" Then
		    TimelineViewer.ExecuteJavaScript("wakeGoTo('" + mPendingAnchor + "');")
		    mPendingAnchor = ""
		  End If
		End Sub
	#tag EndEvent
	#tag Event
		Function JavaScriptRequest(method As String, parameters() as Variant) As String
		  // The page calls executeInXojoSync to expand a long block or load persisted tool output.
		  If mTimeline Is Nil Or parameters.Count = 0 Then Return ""
		  Return mTimeline.Request(method, parameters(0).StringValue)
		End Function
	#tag EndEvent
#tag EndEvents
