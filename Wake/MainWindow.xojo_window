#tag DesktopWindow
Begin DesktopWindow MainWindow
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   True
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   HasTitleBar     =   True
   Height          =   720
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   478898175
   MenuBarVisible  =   False
   MinimumHeight   =   420
   MinimumWidth    =   900
   Resizeable      =   True
   Title           =   "Wake"
   Type            =   0
   Visible         =   True
   Width           =   1240
   Begin DesktopListBox SourceList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   True
      AllowFocusRing  =   False
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   2
      ColumnWidths    =   "*,44"
      DefaultRowHeight=   22
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   True
      HasHeader       =   False
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   689
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   -1
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   2
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   -1
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   221
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopListBox SessionsList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   6
      ColumnWidths    =   "124,60,*,90,60,64"
      DefaultRowHeight=   22
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   True
      HasHeader       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   689
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   219
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   2
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   -1
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   662
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopListBox DetailList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   2
      ColumnWidths    =   "120,*"
      DefaultRowHeight=   22
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   True
      HasHeader       =   False
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   689
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   879
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   2
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   -1
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   362
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopCheckBox ShowCommandsCheckBox
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Show command-only sessions"
      Enabled         =   True
      FontName        =   "SmallSystem"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   12
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      Scope           =   2
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Sessions with only slash commands such as /clear, or nothing at all"
      Top             =   694
      Transparent     =   False
      Underline       =   False
      Value           =   False
      Visible         =   True
      VisualState     =   0
      Width           =   210
   End
   Begin DesktopProgressWheel IndexWheel
      Active          =   True
      AllowAutoDeactivate=   True
      AllowTabStop    =   True
      Enabled         =   True
      Height          =   16
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   230
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      PanelIndex      =   0
      Scope           =   2
      TabIndex        =   4
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   696
      Transparent     =   False
      Visible         =   False
      Width           =   16
      _mIndex         =   0
      _mInitialParent =   ""
      _mName          =   ""
      _mPanelIndex    =   0
   End
   Begin DesktopLabel StatusLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "SmallSystem"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   254
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   False
      Scope           =   2
      Selectable      =   False
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   694
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   974
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Closing()
		  CloseCatalog
		End Sub
	#tag EndEvent

	#tag Event
		Sub Opening()
		  SetUpLists

		  // The window opens its own connection only once an indexing run has finished, so it never
		  // races the indexer thread while that creates or rebuilds the schema.
		  If App.IndexThread Is Nil Then
		    StatusLabel.Text = "Not indexed yet"
		  ElseIf App.IndexThread.ThreadState = Thread.ThreadStates.NotRunning Then
		    Reload
		  Else
		    ShowIndexing("Indexing" + WakeFormat.kEllipsis)
		  End If
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FileRefresh() As Boolean Handles FileRefresh.Action
		  ShowIndexing("Indexing" + WakeFormat.kEllipsis)
		  App.StartIndexing
		  Return True
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h21
		Private Sub AddDetail(label As String, value As String)
		  DetailList.AddRow(label, value)
		  DetailList.CellTooltipAt(DetailList.LastAddedRowIndex, 1) = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddDetailHeading(text As String)
		  If DetailList.RowCount > 0 Then DetailList.AddRow("", "")
		  DetailList.AddRow(text, "")
		  DetailList.CellBoldAt(DetailList.LastAddedRowIndex, 0) = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function AgentName(agentID As String) As String
		  Var parser As IAgentParser = AgentRegistry.ParserFor(agentID)
		  If parser Is Nil Then Return agentID
		  Return parser.DisplayName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CloseCatalog()
		  mCatalog = Nil
		  If mIndex <> Nil Then mIndex.Close
		  mIndex = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatTime(d As DateTime) As String
		  If d Is Nil Then Return WakeFormat.kUnknown
		  Return d.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IndexingFailed(message As String)
		  mIndexNote = message
		  Reload
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IndexingFinished(result As WakeIndexRunResult)
		  mIndexNote = ""
		  If result.FilesFailed = 1 Then
		    mIndexNote = "1 file could not be read"
		  ElseIf result.FilesFailed > 1 Then
		    mIndexNote = result.FilesFailed.ToString + " files could not be read"
		  End If
		  Reload
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IndexingProgress(done As Integer, total As Integer)
		  ShowIndexing("Indexing " + done.ToString + " of " + total.ToString + WakeFormat.kEllipsis)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadSessions()
		  // Fills the sessions list for the selected agent or project, keeping the selected session.
		  Var previousID As Integer = SelectedSessionID

		  mLoading = True
		  SessionsList.RemoveAllRows
		  DetailList.RemoveAllRows

		  Var source As WakeProjectInfo = SelectedSource
		  Var sessions() As WakeSessionInfo
		  If source <> Nil And mCatalog <> Nil Then
		    Try
		      sessions = mCatalog.Sessions(source.AgentID, source.ID, ShowCommandsCheckBox.Value)
		    Catch err As DatabaseException
		      mIndexNote = "Could not read the index: " + err.Message
		    End Try
		  End If

		  For Each s As WakeSessionInfo In sessions
		    SessionsList.AddRow(FormatTime(s.StartTime), WakeFormat.Duration(s.DurationSeconds), s.DisplayTitle, _
		    AgentName(s.AgentID), WakeFormat.Tokens(s.TotalUsage.Total), "")

		    Var row As Integer = SessionsList.LastAddedRowIndex
		    SessionsList.RowTagAt(row) = s
		    SessionsList.CellTagAt(row, kColumnStarted) = If(s.StartTime Is Nil, 0.0, s.StartTime.SecondsFrom1970)
		    SessionsList.CellTagAt(row, kColumnDuration) = s.DurationSeconds
		    SessionsList.CellTagAt(row, kColumnTokens) = s.TotalUsage.Total
		    SessionsList.CellTooltipAt(row, kColumnTitle) = WakeFormat.OneLine(If(s.FirstPrompt <> "", s.FirstPrompt, s.DisplayTitle), 500)
		    If s.IsPartial Then SessionsList.CellTooltipAt(row, kColumnStatus) = s.ParseNote
		  Next

		  If SessionsList.SortingColumn >= 0 Then SessionsList.Sort

		  For row As Integer = 0 To SessionsList.LastRowIndex
		    If WakeSessionInfo(SessionsList.RowTagAt(row).ObjectValue).ID = previousID Then
		      SessionsList.SelectedRowIndex = row
		      Exit
		    End If
		  Next
		  mLoading = False

		  ShowDetail(SelectedSession)
		  UpdateStatus
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OpenCatalog() As Boolean
		  If mCatalog <> Nil Then Return True

		  Var index As New WakeIndex(WakeFolders.DefaultIndexFile)
		  Try
		    index.Open
		  Catch err As DatabaseException
		    mIndexNote = "Could not open the index: " + err.Message
		    Return False
		  Catch err As IOException
		    mIndexNote = "Could not open the index: " + err.Message
		    Return False
		  End Try

		  mIndex = index
		  mCatalog = New WakeCatalog(index)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProjectLabel(p As WakeProjectInfo) As String
		  // The folder name, plus its parent folder when another project of the same agent has
		  // the same name: "Snake/src" and "Sample Project/src".
		  For Each other As WakeProjectInfo In mProjects
		    If other.ID <> p.ID And other.AgentID = p.AgentID And other.Name = p.Name Then
		      Var parts() As String = p.Path.ReplaceAll("\", "/").Split("/")
		      Var kept() As String
		      For i As Integer = parts.LastIndex DownTo 0
		        If parts(i) <> "" Then kept.AddAt(0, parts(i))
		        If kept.Count = 2 Then Exit
		      Next
		      Return String.FromArray(kept, "/")
		    End If
		  Next
		  Return p.Name
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Reload()
		  // Rebuilds the source list from the index and keeps the current selection when it still exists.
		  IndexWheel.Visible = False

		  If Not OpenCatalog Then
		    UpdateStatus
		    Return
		  End If

		  Var previous As WakeProjectInfo = SelectedSource
		  Var previousKey As String = If(previous Is Nil, "", previous.AgentID + "/" + previous.ID.ToString)

		  Try
		    mProjects = mCatalog.Projects(ShowCommandsCheckBox.Value)
		  Catch err As DatabaseException
		    mIndexNote = "Could not read the index: " + err.Message
		    mProjects.RemoveAll
		  End Try

		  mLoading = True
		  SourceList.RemoveAllRows

		  // One expandable row per agent, most recently active first. Its tag is a project with ID 0,
		  // which the catalog reads as every project of that agent.
		  Var agents() As String
		  For Each p As WakeProjectInfo In mProjects
		    If agents.IndexOf(p.AgentID) < 0 Then agents.Add(p.AgentID)
		  Next

		  For Each agentID As String In agents
		    Var all As New WakeProjectInfo
		    all.AgentID = agentID
		    For Each p As WakeProjectInfo In mProjects
		      If p.AgentID = agentID Then all.SessionCount = all.SessionCount + p.SessionCount
		    Next

		    SourceList.AddExpandableRow(AgentName(agentID))
		    Var row As Integer = SourceList.LastAddedRowIndex
		    SourceList.CellTextAt(row, 1) = all.SessionCount.ToString
		    SourceList.CellBoldAt(row, 0) = True
		    SourceList.RowTagAt(row) = all
		    SourceList.RowExpandedAt(row) = True
		  Next

		  Var selectRow As Integer = If(SourceList.RowCount > 0, 0, -1)
		  For row As Integer = 0 To SourceList.LastRowIndex
		    Var p As WakeProjectInfo = WakeProjectInfo(SourceList.RowTagAt(row).ObjectValue)
		    If p.AgentID + "/" + p.ID.ToString = previousKey Then
		      selectRow = row
		      Exit
		    End If
		  Next
		  SourceList.SelectedRowIndex = selectRow
		  mLoading = False

		  LoadSessions
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedSession() As WakeSessionInfo
		  If SessionsList.SelectedRowIndex < 0 Then Return Nil
		  Return WakeSessionInfo(SessionsList.RowTagAt(SessionsList.SelectedRowIndex).ObjectValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedSessionID() As Integer
		  Var s As WakeSessionInfo = SelectedSession
		  If s Is Nil Then Return 0
		  Return s.ID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedSource() As WakeProjectInfo
		  If SourceList.SelectedRowIndex < 0 Then Return Nil
		  Return WakeProjectInfo(SourceList.RowTagAt(SourceList.SelectedRowIndex).ObjectValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetUpLists()
		  SourceList.ColumnAlignmentAt(1) = DesktopListBox.Alignments.Right

		  SessionsList.HeaderAt(kColumnStarted) = "Started"
		  SessionsList.HeaderAt(kColumnDuration) = "Duration"
		  SessionsList.HeaderAt(kColumnTitle) = "Title"
		  SessionsList.HeaderAt(kColumnAgent) = "Agent"
		  SessionsList.HeaderAt(kColumnTokens) = "Tokens"
		  SessionsList.HeaderAt(kColumnStatus) = " " // An empty heading shows the column number.
		  SessionsList.ColumnAlignmentAt(kColumnDuration) = DesktopListBox.Alignments.Right
		  SessionsList.ColumnAlignmentAt(kColumnTokens) = DesktopListBox.Alignments.Right

		  DetailList.ColumnAlignmentAt(0) = DesktopListBox.Alignments.Left
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowDetail(info As WakeSessionInfo)
		  // A summary of one session. The full timeline comes in the next milestone.
		  DetailList.RemoveAllRows
		  If mCatalog Is Nil Then Return
		  If info Is Nil Then
		    If SessionsList.RowCount > 0 Then AddDetail("", "Select a session to see its details.")
		    Return
		  End If

		  Var s As WakeSessionInfo
		  Var subagents() As WakeSessionInfo
		  Try
		    s = mCatalog.Session(info.ID)
		    If s <> Nil Then subagents = mCatalog.Subagents(s.ID)
		  Catch err As DatabaseException
		    AddDetail("Error", "Could not read the index: " + err.Message)
		    Return
		  End Try

		  If s Is Nil Then
		    AddDetail("", "This session is no longer in the index.")
		    Return
		  End If

		  AddDetailHeading("Session")
		  AddDetail("Title", s.DisplayTitle)
		  If s.FirstPrompt <> "" And s.Title <> "" Then AddDetail("First prompt", WakeFormat.OneLine(s.FirstPrompt, 500))
		  AddDetail("Project", s.ProjectPath)
		  AddDetail("Agent", AgentName(s.AgentID) + If(s.AgentVersion <> "", " " + s.AgentVersion, ""))
		  If s.GitBranch <> "" Then AddDetail("Branch", s.GitBranch)
		  AddDetail("Started", FormatTime(s.StartTime))
		  AddDetail("Ended", FormatTime(s.EndTime))
		  AddDetail("Duration", WakeFormat.Duration(s.DurationSeconds))
		  If s.ActiveMs > 0 Then AddDetail("Active time", WakeFormat.Duration(s.ActiveMs / 1000))
		  AddDetail("Prompts", WakeFormat.Count(s.PromptCount))
		  AddDetail("Events", WakeFormat.Count(s.EventCount))

		  AddDetailHeading("Tokens")
		  AddDetail("Total", WakeFormat.Count(s.TotalUsage.Total))
		  AddDetail("Input", WakeFormat.Count(s.TotalUsage.InputTokens))
		  AddDetail("Output", WakeFormat.Count(s.TotalUsage.OutputTokens))
		  AddDetail("Cache write", WakeFormat.Count(s.TotalUsage.CacheWriteTokens))
		  AddDetail("Cache read", WakeFormat.Count(s.TotalUsage.CacheReadTokens))
		  If s.SubagentCount > 0 Then AddDetail("Without subagents", WakeFormat.Count(s.OwnUsage.Total))
		  If s.HasAgentCost Then AddDetail("Cost", "$" + s.AgentCostUSD.ToString(Locale.Raw, "0.00") + " (reported by agent)")

		  If s.Models.Count > 0 Then
		    AddDetailHeading("Models")
		    For Each model As Pair In s.Models
		      AddDetail(model.Left.StringValue, WakeFormat.Count(WakeTokenUsage(model.Right.ObjectValue).Total) + " tokens")
		    Next
		  End If

		  If subagents.Count > 0 Then
		    AddDetailHeading("Subagents")
		    For Each child As WakeSessionInfo In subagents
		      AddDetail(If(child.SubagentType <> "", child.SubagentType, "Subagent"), _
		      child.DisplayTitle + " (" + WakeFormat.Tokens(child.TotalUsage.Total) + " tokens)")
		    Next
		  End If

		  AddDetailHeading("Source")
		  If s.IsPartial Then AddDetail("Partially parsed", s.ParseNote)
		  AddDetail("File", s.FilePath)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowIndexing(message As String)
		  IndexWheel.Visible = True
		  StatusLabel.Text = message
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateStatus()
		  Var parts() As String
		  If mCatalog <> Nil Then
		    parts.Add(If(SessionsList.RowCount = 1, "1 session", SessionsList.RowCount.ToString + " sessions"))
		  End If
		  If mIndexNote <> "" Then parts.Add(mIndexNote)
		  StatusLabel.Text = String.FromArray(parts, " · ")
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCatalog As WakeCatalog
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndexNote As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLoading As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mProjects() As WakeProjectInfo
	#tag EndProperty


	#tag Constant, Name = kColumnAgent, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnDuration, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnStarted, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnStatus, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnTitle, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnTokens, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant


#tag EndWindowCode

#tag Events SourceList
	#tag Event
		Sub RowExpanded(row As Integer)
		  // Children of an agent row: its projects, most recently active first.
		  Var agent As WakeProjectInfo = WakeProjectInfo(Me.RowTagAt(row).ObjectValue)

		  For Each p As WakeProjectInfo In mProjects
		    If p.AgentID <> agent.AgentID Then Continue
		    Me.AddRow(ProjectLabel(p), p.SessionCount.ToString)
		    Var child As Integer = Me.LastAddedRowIndex
		    Me.RowTagAt(child) = p
		    Me.CellTooltipAt(child, 0) = p.Path
		  Next
		End Sub
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  If Not mLoading Then LoadSessions
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SessionsList
	#tag Event
		Function PaintCellText(g as Graphics, row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  // Draws a "Partial" badge for sessions the parser could not read completely.
		  #Pragma Unused y
		  If column <> kColumnStatus Or row > Me.LastRowIndex Then Return False

		  Var s As WakeSessionInfo = WakeSessionInfo(Me.RowTagAt(row).ObjectValue)
		  If s Is Nil Or Not s.IsPartial Then Return True

		  Var label As String = "Partial"
		  g.FontSize = 10
		  g.Bold = True
		  Var badgeWidth As Double = g.TextWidth(label) + 10
		  Var badgeHeight As Double = 16
		  Var top As Double = (g.Height - badgeHeight) / 2

		  g.DrawingColor = Color.RGB(201, 120, 0)
		  g.FillRoundRectangle(x, top, badgeWidth, badgeHeight, 8, 8)
		  g.DrawingColor = Color.White
		  g.DrawText(label, x + 5, top + (badgeHeight - g.TextHeight) / 2 + g.FontAscent)
		  Return True
		End Function
	#tag EndEvent
	#tag Event
		Function RowComparison(row1 As Integer, row2 As Integer, column As Integer, ByRef result As Integer) As Boolean
		  // Dates, durations and token counts sort by value, not by their text.
		  Select Case column
		  Case kColumnStarted, kColumnDuration, kColumnTokens
		    Var a As Double = Me.CellTagAt(row1, column).DoubleValue
		    Var b As Double = Me.CellTagAt(row2, column).DoubleValue
		    If a < b Then
		      result = -1
		    ElseIf a > b Then
		      result = 1
		    Else
		      result = 0
		    End If
		    Return True
		  End Select

		  Return False
		End Function
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  If Not mLoading Then ShowDetail(SelectedSession)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ShowCommandsCheckBox
	#tag Event
		Sub ValueChanged()
		  Reload
		End Sub
	#tag EndEvent
#tag EndEvents
