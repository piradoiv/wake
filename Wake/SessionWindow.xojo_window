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
   MinimumHeight   =   300
   MinimumWidth    =   480
   Resizeable      =   True
   Title           =   "Session"
   Type            =   0
   Visible         =   True
   Width           =   960
   Begin DesktopHTMLViewer TimelineViewer
      AutoDeactivate  =   True
      Enabled         =   True
      Height          =   760
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
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   0
      Visible         =   True
      Width           =   960
   End
End
#tag EndDesktopWindow

#tag WindowCode
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
		  Title = info.DisplayTitle
		  mTimeline = WakeTimeline.Load(info.AgentID, info.FilePath)
		  
		  mLoadingPage = True
		  mPendingAnchor = ""
		  TimelineViewer.LoadPage(mTimeline.HTML, Nil)
		End Sub
	#tag EndMethod


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
