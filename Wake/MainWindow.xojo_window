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
      ColumnCount     =   7
      ColumnWidths    =   "124,60,*,90,60,70,64"
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
      Height          =   653
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
      Top             =   35
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   662
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin WakeGlanceTiles GlanceTiles
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Heading         =   ""
      Height          =   218
      Index           =   -2147483648
      Left            =   881
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   True
      Scope           =   2
      Subheading      =   ""
      TabIndex        =   10
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   35
      Transparent     =   True
      Visible         =   True
      Width           =   360
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
      Height          =   435
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   880
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
      Top             =   253
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   361
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
   Begin DesktopTextField SearchField
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   False
      AllowTabs       =   False
      BackgroundColor =   &cFFFFFF00
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Format          =   ""
      HasBorder       =   True
      Height          =   24
      Hint            =   "Search prompts, answers, commands and output"
      Index           =   -2147483648
      Italic          =   False
      Left            =   228
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      MaximumCharactersAllowed=   0
      Password        =   False
      ReadOnly        =   False
      Scope           =   2
      TabIndex        =   6
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c00000000
      Tooltip         =   "Words match as prefixes. Put a phrase in double quotes to match it exactly. Searches the agent or project selected on the left."
      Top             =   6
      Transparent     =   False
      Underline       =   False
      ValidationMask  =   ""
      Visible         =   True
      Width           =   640
   End
   Begin DesktopPopupMenu KindPopup
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   False
      Left            =   878
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   True
      Scope           =   2
      SelectedRowIndex=   -1
      TabIndex        =   8
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Search only events of this kind"
      Top             =   8
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   170
   End
   Begin DesktopPopupMenu DatePopup
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   False
      Left            =   1058
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   True
      Scope           =   2
      SelectedRowIndex=   -1
      TabIndex        =   9
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Search only events from this period"
      Top             =   8
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   170
   End
   Begin DesktopListBox HitsList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   4
      ColumnWidths    =   "124,100,*,200"
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
      Height          =   653
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
      TabIndex        =   7
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   35
      Transparent     =   False
      Underline       =   False
      Visible         =   False
      Width           =   662
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Closing()
		  CloseCatalog
		  
		  // Timelines and the other windows hang off the browser, so closing it quits Wake.
		  Quit
		End Sub
	#tag EndEvent

	#tag Event
		Sub MenuBarSelected()
		  FileOpenTimeline.Enabled = SelectedSession <> Nil
		  FileExportMarkdown.Enabled = SelectedSession <> Nil
		  
		  Var project As WakeProjectInfo = SelectedProject
		  ViewHideProject.Enabled = project <> Nil
		  ViewHideProject.Text = If(project <> Nil And project.IsHidden, "Un&hide Project", "&Hide Project")
		  ViewShowHiddenProjects.Enabled = mShowHidden Or App.HiddenProjects.Count > 0
		  ViewShowHiddenProjects.HasCheckMark = mShowHidden
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
		Function EditFind() As Boolean Handles EditFind.Action
		  SearchField.SetFocus
		  SearchField.SelectAll
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileCloseWindow() As Boolean Handles FileCloseWindow.Action
		  Self.Close
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileExportMarkdown() As Boolean Handles FileExportMarkdown.Action
		  App.ExportMarkdown(SelectedSession)
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileOpenTimeline() As Boolean Handles FileOpenTimeline.Action
		  OpenTimeline
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileRefresh() As Boolean Handles FileRefresh.Action
		  ShowIndexing("Indexing" + WakeFormat.kEllipsis)
		  App.StartIndexing
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ViewHideProject() As Boolean Handles ViewHideProject.Action
		  ToggleHidden(SelectedProject)
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ViewShowHiddenProjects() As Boolean Handles ViewShowHiddenProjects.Action
		  mShowHidden = Not mShowHidden
		  If mCatalog <> Nil Then mCatalog.IncludeHidden = mShowHidden
		  Reload
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
		Sub HiddenProjectsChanged()
		  Reload
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HitKindLabel(hit As WakeSearchHit) As String
		  Select Case hit.Kind
		  Case "user"
		    Return "Prompt"
		  Case "assistant"
		    Return "Answer"
		  Case "thinking"
		    Return "Thinking"
		  Case "tool", "shell", "edit"
		    If hit.ToolName <> "" Then Return hit.ToolName
		    Return "Tool call"
		  Case "result"
		    Return "Tool result"
		  Case "error"
		    Return "Error"
		  Case "system"
		    Return "System"
		  End Select
		  Return hit.Kind
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
		Private Function IsSearching() As Boolean
		  Return SearchField.Text.Trim <> ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadHits()
		  // Fills the hits list with the events that match the search, within the agent or project
		  // selected in the source list and the kind and period chosen above the list.
		  Var previous As WakeSearchHit = SelectedHit
		  Var previousEventID As Integer = If(previous Is Nil, 0, previous.EventID)
		  
		  mLoading = True
		  HitsList.RemoveAllRows
		  DetailList.RemoveAllRows
		  mHitSessionCount = 0
		  
		  Var hits() As WakeSearchHit
		  If mCatalog <> Nil Then
		    Var query As New WakeSearchQuery(SearchField.Text)
		    Var source As WakeProjectInfo = SelectedSource
		    If source <> Nil Then
		      query.AgentID = source.AgentID
		      query.ProjectID = source.ID
		    End If
		    query.IncludeCommandOnly = ShowCommandsCheckBox.Value
		    query.Limit = kMaxHits
		    
		    If KindPopup.SelectedRowIndex > 0 Then
		      query.Kinds = KindPopup.RowTagAt(KindPopup.SelectedRowIndex).StringValue.Split(",")
		    End If
		    
		    If DatePopup.SelectedRowIndex > 0 Then
		      Var days As Integer = DatePopup.RowTagAt(DatePopup.SelectedRowIndex).IntegerValue
		      Var now As DateTime = DateTime.Now
		      Var midnight As New DateTime(now.Year, now.Month, now.Day)
		      query.FromTime = midnight.SubtractInterval(0, 0, days - 1)
		    End If
		    
		    Try
		      hits = mCatalog.Search(query)
		    Catch err As DatabaseException
		      mIndexNote = "Could not search the index: " + err.Message
		    End Try
		  End If
		  
		  Var sessionIDs() As Integer
		  For Each hit As WakeSearchHit In hits
		    Var sessionTitle As String = hit.Session.DisplayTitle + If(hit.InSubagent, " (subagent)", "")
		    HitsList.AddRow(FormatTime(hit.Timestamp), HitKindLabel(hit), WakeFormat.OneLine(hit.PlainSnippet, 0), sessionTitle)
		    
		    Var row As Integer = HitsList.LastAddedRowIndex
		    HitsList.RowTagAt(row) = hit
		    HitsList.CellTagAt(row, kHitColumnTime) = If(hit.Timestamp Is Nil, 0.0, hit.Timestamp.SecondsFrom1970)
		    HitsList.CellTooltipAt(row, kHitColumnMatch) = WakeFormat.OneLine(hit.PlainSnippet, 500)
		    HitsList.CellTooltipAt(row, kHitColumnSession) = hit.Session.ProjectPath
		    
		    If sessionIDs.IndexOf(hit.Session.ID) < 0 Then sessionIDs.Add(hit.Session.ID)
		  Next
		  mHitSessionCount = sessionIDs.Count
		  
		  If HitsList.SortingColumn >= 0 Then HitsList.Sort
		  
		  For row As Integer = 0 To HitsList.LastRowIndex
		    If WakeSearchHit(HitsList.RowTagAt(row).ObjectValue).EventID = previousEventID Then
		      HitsList.SelectedRowIndex = row
		      Exit
		    End If
		  Next
		  mLoading = False
		  
		  ShowDetail(SelectedSession, SelectedHit)
		  UpdateStatus
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
		  Var usageBySession As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  If source <> Nil And mCatalog <> Nil Then
		    Try
		      sessions = mCatalog.Sessions(source.AgentID, source.ID, ShowCommandsCheckBox.Value)
		      For Each g As WakeUsageGroup In mCatalog.Usage(WakeCatalog.UsageGroupings.Session, Nil, source.AgentID, source.ID)
		        usageBySession.Value(g.Key) = g
		      Next
		    Catch err As DatabaseException
		      mIndexNote = "Could not read the index: " + err.Message
		    End Try
		  End If
		  
		  mMaxTokens = 0
		  mMaxCost = 0
		  For Each s As WakeSessionInfo In sessions
		    Var usage As WakeUsageGroup = WakeUsageGroup(usageBySession.Lookup(s.ID.ToString, Nil).ObjectValue)
		    Var estimate As WakeCostEstimate = App.Prices.Estimate(If(usage Is Nil, Nil, usage.ByModel))
		    mMaxTokens = Max(mMaxTokens, s.TotalUsage.Total)
		    If estimate.PricedTokens > 0 Then mMaxCost = Max(mMaxCost, estimate.AmountUSD)
		    
		    SessionsList.AddRow(FormatTime(s.StartTime), WakeFormat.Duration(s.DurationSeconds), s.DisplayTitle, _
		    AgentName(s.AgentID), WakeFormat.Tokens(s.TotalUsage.Total), WakeFormat.Cost(estimate), "")
		    
		    Var row As Integer = SessionsList.LastAddedRowIndex
		    SessionsList.RowTagAt(row) = s
		    SessionsList.CellTagAt(row, kColumnStarted) = If(s.StartTime Is Nil, 0.0, s.StartTime.SecondsFrom1970)
		    SessionsList.CellTagAt(row, kColumnDuration) = s.DurationSeconds
		    SessionsList.CellTagAt(row, kColumnTokens) = s.TotalUsage.Total
		    SessionsList.CellTagAt(row, kColumnCost) = If(estimate.PricedTokens > 0, estimate.AmountUSD, -1.0)
		    If estimate.UnpricedModels.Count > 0 Then
		      SessionsList.CellTooltipAt(row, kColumnCost) = "No price set for " + String.FromArray(estimate.UnpricedModels, ", ")
		    End If
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
		Private Sub LoadSourceTotals()
		  // Adds up the sessions of the selected agent or project for the glance tiles shown while
		  // no session is selected.
		  mSourceUsage = New WakeUsageGroup
		  mSourceSessions = 0
		  mSourceSeconds = 0
		  mSourcePrompts = 0
		  
		  Var source As WakeProjectInfo = SelectedSource
		  If source Is Nil Or mCatalog Is Nil Then Return
		  
		  Try
		    For Each s As WakeSessionInfo In mCatalog.Sessions(source.AgentID, source.ID, ShowCommandsCheckBox.Value)
		      mSourceSessions = mSourceSessions + 1
		      mSourceSeconds = mSourceSeconds + Max(0, s.DurationSeconds)
		      mSourcePrompts = mSourcePrompts + s.PromptCount
		    Next
		    For Each g As WakeUsageGroup In mCatalog.Usage(WakeCatalog.UsageGroupings.Project, Nil, source.AgentID, source.ID)
		      For Each model As Variant In g.ByModel.Keys
		        mSourceUsage.Add(model.StringValue, WakeTokenUsage(g.ByModel.Value(model).ObjectValue))
		      Next
		    Next
		  Catch err As DatabaseException
		    mIndexNote = "Could not read the index: " + err.Message
		  End Try
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
		  mCatalog.HiddenProjects = App.HiddenProjects
		  mCatalog.IncludeHidden = mShowHidden
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenTimeline()
		  // Opens the selected session's timeline, or brings its window to the front if it is open.
		  // For a search hit, the timeline scrolls to the matching event.
		  Var info As WakeSessionInfo = SelectedSession
		  If info Is Nil Then Return
		  Var hit As WakeSearchHit = SelectedHit
		  
		  For i As Integer = 0 To App.WindowCount - 1
		    Var existing As DesktopWindow = App.WindowAt(i)
		    If existing IsA SessionWindow And SessionWindow(existing).SessionID = info.ID Then
		      existing.Show
		      If hit <> Nil Then SessionWindow(existing).ShowEvent(hit.EventSessionUID, hit.Sequence)
		      Return
		    End If
		  Next
		  
		  Var timelineWindow As New SessionWindow
		  timelineWindow.ShowSession(info)
		  If hit <> Nil Then timelineWindow.ShowEvent(hit.EventSessionUID, hit.Sequence)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PricesChanged()
		  // Costs depend on the price table, so redraw the lists and the detail pane.
		  If mCatalog <> Nil Then ShowResults
		End Sub
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
		  
		  // A project that is gone, or was just hidden, leaves its agent selected.
		  Var selectRow As Integer = If(SourceList.RowCount > 0, 0, -1)
		  For row As Integer = 0 To SourceList.LastRowIndex
		    Var p As WakeProjectInfo = WakeProjectInfo(SourceList.RowTagAt(row).ObjectValue)
		    If p.AgentID + "/" + p.ID.ToString = previousKey Then
		      selectRow = row
		      Exit
		    ElseIf previous <> Nil And p.ID = 0 And p.AgentID = previous.AgentID Then
		      selectRow = row
		    End If
		  Next
		  SourceList.SelectedRowIndex = selectRow
		  mLoading = False
		  
		  ShowResults
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunSearch()
		  // Called a moment after the last keystroke, so typing doesn't query the index on every key.
		  ShowResults
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedHit() As WakeSearchHit
		  If Not HitsList.Visible Or HitsList.SelectedRowIndex < 0 Then Return Nil
		  Return WakeSearchHit(HitsList.RowTagAt(HitsList.SelectedRowIndex).ObjectValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedProject() As WakeProjectInfo
		  // The selected project, or Nil when an agent row or nothing is selected.
		  Var source As WakeProjectInfo = SelectedSource
		  If source Is Nil Or source.ID = 0 Then Return Nil
		  Return source
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedSession() As WakeSessionInfo
		  // The selected session, or the session of the selected search hit.
		  If HitsList.Visible Then
		    Var hit As WakeSearchHit = SelectedHit
		    If hit Is Nil Then Return Nil
		    Return hit.Session
		  End If
		  
		  If SessionsList.SelectedRowIndex < 0 Then Return Nil
		  Return WakeSessionInfo(SessionsList.RowTagAt(SessionsList.SelectedRowIndex).ObjectValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedSessionID() As Integer
		  If SessionsList.SelectedRowIndex < 0 Then Return 0
		  Return WakeSessionInfo(SessionsList.RowTagAt(SessionsList.SelectedRowIndex).ObjectValue).ID
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
		  SessionsList.HeaderAt(kColumnCost) = "Cost"
		  SessionsList.HeaderAt(kColumnStatus) = " " // An empty heading shows the column number.
		  SessionsList.ColumnAlignmentAt(kColumnDuration) = DesktopListBox.Alignments.Right
		  SessionsList.ColumnAlignmentAt(kColumnTokens) = DesktopListBox.Alignments.Right
		  SessionsList.ColumnAlignmentAt(kColumnCost) = DesktopListBox.Alignments.Right
		  
		  HitsList.HeaderAt(kHitColumnTime) = "Time"
		  HitsList.HeaderAt(kHitColumnKind) = "Kind"
		  HitsList.HeaderAt(kHitColumnMatch) = "Match"
		  HitsList.HeaderAt(kHitColumnSession) = "Session"
		  
		  // Each kind row's tag lists the event kinds it searches, as the index names them.
		  mLoading = True
		  KindPopup.AddRow("All events")
		  KindPopup.AddRow("Prompts")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "user"
		  KindPopup.AddRow("Answers")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "assistant"
		  KindPopup.AddRow("Thinking")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "thinking"
		  KindPopup.AddRow("Tool calls")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "tool,shell,edit,result"
		  KindPopup.AddRow("Shell commands")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "shell"
		  KindPopup.AddRow("File edits")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "edit"
		  KindPopup.AddRow("Errors")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "error"
		  KindPopup.AddRow("System messages")
		  KindPopup.RowTagAt(KindPopup.LastAddedRowIndex) = "system"
		  KindPopup.SelectedRowIndex = 0
		  
		  // Each period row's tag is its length in days, counted back from the end of today.
		  DatePopup.AddRow("Any time")
		  DatePopup.AddRow("Today")
		  DatePopup.RowTagAt(DatePopup.LastAddedRowIndex) = 1
		  DatePopup.AddRow("Last 7 days")
		  DatePopup.RowTagAt(DatePopup.LastAddedRowIndex) = 7
		  DatePopup.AddRow("Last 30 days")
		  DatePopup.RowTagAt(DatePopup.LastAddedRowIndex) = 30
		  DatePopup.AddRow("Last 12 months")
		  DatePopup.RowTagAt(DatePopup.LastAddedRowIndex) = 365
		  DatePopup.SelectedRowIndex = 0
		  mLoading = False
		  
		  DetailList.ColumnAlignmentAt(0) = DesktopListBox.Alignments.Left
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowDetail(info As WakeSessionInfo, hit As WakeSearchHit = Nil)
		  // A summary of one session, after the match when it comes from a search hit.
		  // Double-clicking the session or hit opens the full timeline.
		  DetailList.RemoveAllRows
		  If mCatalog Is Nil Or info Is Nil Then ShowSourceGlance
		  If mCatalog Is Nil Then Return
		  If info Is Nil Then
		    If HitsList.Visible And HitsList.RowCount > 0 Then
		      AddDetail("", "Select a match to see its session.")
		    ElseIf Not HitsList.Visible And SessionsList.RowCount > 0 Then
		      AddDetail("", "Select a session to see its details.")
		    End If
		    Return
		  End If
		  
		  If hit <> Nil Then
		    AddDetailHeading("Match")
		    AddDetail(HitKindLabel(hit), WakeFormat.OneLine(hit.PlainSnippet, 500))
		    AddDetail("Time", FormatTime(hit.Timestamp))
		    If hit.FilePath <> "" Then AddDetail("File", hit.FilePath)
		    If hit.InSubagent Then AddDetail("Where", "In a subagent of this session")
		  End If
		  
		  Var s As WakeSessionInfo
		  Var subagents() As WakeSessionInfo
		  Var usage As WakeUsageGroup
		  Try
		    s = mCatalog.Session(info.ID)
		    If s <> Nil Then
		      subagents = mCatalog.Subagents(s.ID)
		      usage = mCatalog.SessionUsage(s.ID)
		    End If
		  Catch err As DatabaseException
		    ShowSourceGlance
		    AddDetail("Error", "Could not read the index: " + err.Message)
		    Return
		  End Try
		  
		  If s Is Nil Then
		    ShowSourceGlance
		    AddDetail("", "This session is no longer in the index.")
		    Return
		  End If
		  
		  GlanceTiles.ShowSession(s, usage, App.Prices)
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
		  
		  // Wake's own estimate from the user's prices, and the agent's figure as a cross-check.
		  Var estimate As WakeCostEstimate = App.Prices.Estimate(usage.ByModel)
		  Var costText As String = WakeFormat.Cost(estimate)
		  If estimate.UnpricedModels.Count > 0 And estimate.PricedTokens > 0 Then
		    costText = costText + " (no price set for " + String.FromArray(estimate.UnpricedModels, ", ") + ")"
		  End If
		  If estimate.HasTokens Then AddDetail("Estimated cost", costText)
		  If s.HasAgentCost Then AddDetail("Reported cost", WakeFormat.USD(s.AgentCostUSD) + " (reported by agent)")
		  
		  If usage.ByModel.KeyCount > 0 Then
		    AddDetailHeading(If(s.SubagentCount > 0, "Models (with subagents)", "Models"))
		    For Each model As Pair In SortedModels(usage)
		      Var amount As WakeTokenUsage = WakeTokenUsage(model.Right.ObjectValue)
		      Var price As WakeModelPrice = App.Prices.PriceFor(model.Left.StringValue)
		      AddDetail(model.Left.StringValue, WakeFormat.Count(amount.Total) + " tokens · " + _
		      If(price Is Nil, WakeFormat.kNoPrice, WakeFormat.USD(price.Cost(amount))))
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
		  AddDetail("Timeline", If(hit <> Nil, "Double-click the match or press ⌘O", "Double-click the session or press ⌘O"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowIndexing(message As String)
		  IndexWheel.Visible = True
		  StatusLabel.Text = message
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowResults()
		  // Search hits while there is search text, otherwise the sessions of the selected source.
		  Timer.CancelCallLater(AddressOf RunSearch)
		  
		  Var searching As Boolean = IsSearching
		  HitsList.Visible = searching
		  SessionsList.Visible = Not searching
		  
		  LoadSourceTotals
		  If searching Then
		    LoadHits
		  Else
		    HitsList.RemoveAllRows
		    LoadSessions
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowSourceGlance()
		  // The selected agent or project, and tiles with the totals of its sessions.
		  GlanceTiles.RemoveAllTiles
		  GlanceTiles.Heading = ""
		  GlanceTiles.Subheading = ""
		  
		  Var source As WakeProjectInfo = SelectedSource
		  If source <> Nil And mCatalog <> Nil And mSourceUsage <> Nil Then
		    GlanceTiles.Heading = If(source.ID = 0, AgentName(source.AgentID), ProjectLabel(source))
		    GlanceTiles.Subheading = If(source.ID = 0, "All projects", source.Path)
		    
		    Var total As WakeTokenUsage = mSourceUsage.Total
		    GlanceTiles.AddTile("Estimated cost", WakeFormat.Cost(App.Prices.Estimate(mSourceUsage.ByModel)), _
		    If(mSourceSessions = 1, "1 session", WakeFormat.Count(mSourceSessions) + " sessions"), WakeGlanceTiles.kGreen)
		    
		    Var inputSide As Int64 = total.InputTokens + total.CacheWriteTokens + total.CacheReadTokens
		    GlanceTiles.AddTile("Tokens", WakeFormat.Tokens(total.Total), _
		    If(inputSide > 0, WakeFormat.Percent(total.CacheReadTokens, inputSide) + " from cache", ""), WakeGlanceTiles.kBlue)
		    
		    GlanceTiles.AddTile("Time", WakeFormat.Duration(mSourceSeconds), "across all sessions", WakeGlanceTiles.kOrange)
		    
		    Var perSession As String
		    If mSourceSessions > 0 Then
		      Var average As Double = mSourcePrompts / mSourceSessions
		      perSession = average.ToString(Locale.Current, "0.#") + " per session"
		    End If
		    GlanceTiles.AddTile("Prompts", WakeFormat.Count(mSourcePrompts), perSession, WakeGlanceTiles.kPurple)
		  End If
		  
		  GlanceTiles.Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SortedModels(usage As WakeUsageGroup) As Pair()
		  // model : WakeTokenUsage pairs, most tokens first.
		  Var result() As Pair
		  Var totals() As Int64
		  For Each key As Variant In usage.ByModel.Keys
		    Var amount As WakeTokenUsage = WakeTokenUsage(usage.ByModel.Value(key).ObjectValue)
		    result.Add(key.StringValue : amount)
		    totals.Add(-amount.Total)
		  Next
		  totals.SortWith(result)
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ToggleHidden(project As WakeProjectInfo)
		  If project Is Nil Then Return
		  If project.IsHidden Then
		    App.HiddenProjects.Unhide(project.AgentID, project.Path)
		  Else
		    App.HiddenProjects.Hide(project.AgentID, project.Path)
		  End If
		  App.HiddenProjectsChanged
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateStatus()
		  Var parts() As String
		  If mCatalog <> Nil And HitsList.Visible Then
		    Var matches As String = If(HitsList.RowCount = 1, "1 match", WakeFormat.Count(HitsList.RowCount) + " matches")
		    parts.Add(matches + " in " + If(mHitSessionCount = 1, "1 session", WakeFormat.Count(mHitSessionCount) + " sessions"))
		    If HitsList.RowCount >= kMaxHits Then parts.Add("showing the best " + WakeFormat.Count(kMaxHits))
		  ElseIf mCatalog <> Nil Then
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
		Private mHitSessionCount As Integer
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
		Private mMaxCost As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaxTokens As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mProjects() As WakeProjectInfo
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowHidden As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSourcePrompts As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSourceSeconds As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSourceSessions As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSourceUsage As WakeUsageGroup
	#tag EndProperty


	#tag Constant, Name = kColumnAgent, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCost, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnDuration, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnStarted, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnStatus, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnTitle, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnTokens, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitColumnKind, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitColumnMatch, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitColumnSession, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitColumnTime, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaxHits, Type = Double, Dynamic = False, Default = \"500", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSearchDelay, Type = Double, Dynamic = False, Default = \"250", Scope = Private
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
		    Me.CellTooltipAt(child, 0) = p.Path + If(p.IsHidden, " (hidden)", "")
		  Next
		End Sub
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  If Not mLoading Then ShowResults
		End Sub
	#tag EndEvent
	#tag Event
		Function PaintCellText(g as Graphics, row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  // Hidden projects, listed while View → Show Hidden Projects is on, are drawn dimmed.
		  #Pragma Unused column
		  #Pragma Unused x
		  #Pragma Unused y
		  If row > Me.LastRowIndex Or Me.RowSelectedAt(row) Then Return False
		  
		  Var p As WakeProjectInfo = WakeProjectInfo(Me.RowTagAt(row).ObjectValue)
		  If p <> Nil And p.IsHidden Then g.DrawingColor = WakeGlanceTiles.SecondaryTextColor
		  Return False
		End Function
	#tag EndEvent
	#tag Event
		Function ConstructContextualMenu(base As DesktopMenuItem, x As Integer, y As Integer) As Boolean
		  // Right-clicking a project offers to hide it, or to bring it back when it is hidden.
		  Var row As Integer = Me.RowFromXY(x, y)
		  If row < 0 Or row > Me.LastRowIndex Then Return False
		  
		  Var p As WakeProjectInfo = WakeProjectInfo(Me.RowTagAt(row).ObjectValue)
		  If p Is Nil Or p.ID = 0 Then Return False
		  
		  base.AddMenu(New DesktopMenuItem(If(p.IsHidden, "Unhide Project", "Hide Project"), p))
		  Return True
		End Function
	#tag EndEvent
	#tag Event
		Function ContextualMenuItemSelected(selectedItem As DesktopMenuItem) As Boolean
		  If selectedItem Is Nil Or Not (selectedItem.Tag.ObjectValue IsA WakeProjectInfo) Then Return False
		  ToggleHidden(WakeProjectInfo(selectedItem.Tag.ObjectValue))
		  Return True
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events SessionsList
	#tag Event
		Function PaintCellText(g as Graphics, row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  // Draws a strip under the token count and cost, as long as the largest in the list, and a
		  // "Partial" badge for sessions the parser could not read completely.
		  #Pragma Unused y
		  If row > Me.LastRowIndex Then Return False
		  
		  If column = kColumnTokens Or column = kColumnCost Then
		    Var largest As Double = If(column = kColumnTokens, mMaxTokens, mMaxCost)
		    Var value As Double = Me.CellTagAt(row, column).DoubleValue
		    If largest > 0 And value > 0 And Not Me.RowSelectedAt(row) Then
		      // The list draws the text in the current colour, so put it back after the strip.
		      Var textColor As Color = g.DrawingColor
		      Var tint As Color = If(column = kColumnTokens, WakeGlanceTiles.kBlue, WakeGlanceTiles.kGreen)
		      Var barWidth As Double = Max(3, (g.Width - 4) * value / largest)
		      g.DrawingColor = Color.RGB(tint.Red, tint.Green, tint.Blue, If(Color.IsDarkMode, 60, 90))
		      g.FillRoundRectangle(g.Width - 2 - barWidth, g.Height - 4, barWidth, 3, 3, 3)
		      g.DrawingColor = textColor
		    End If
		    Return False
		  End If
		  
		  If column <> kColumnStatus Then Return False
		  
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
		Function RowComparison(row1 as Integer, row2 as Integer, column as Integer, ByRef result as Integer) As Boolean
		  // Dates, durations, token counts and costs sort by value, not by their text. A session
		  // with no price sorts below every priced one.
		  Select Case column
		  Case kColumnStarted, kColumnDuration, kColumnTokens, kColumnCost
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
	#tag Event
		Sub DoublePressed()
		  OpenTimeline
		End Sub
	#tag EndEvent
	#tag Event
		Function KeyDown(key As String) As Boolean
		  // Return or Enter opens the timeline, like double-clicking the row.
		  If key = &u0D Or key = &u03 Then
		    OpenTimeline
		    Return True
		  End If
		  Return False
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events ShowCommandsCheckBox
	#tag Event
		Sub ValueChanged()
		  Reload
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SearchField
	#tag Event
		Sub TextChanged()
		  // Search shortly after typing stops. Clearing the field goes back to the sessions at once.
		  Timer.CancelCallLater(AddressOf RunSearch)
		  If IsSearching Then
		    Timer.CallLater(kSearchDelay, AddressOf RunSearch)
		  Else
		    ShowResults
		  End If
		End Sub
	#tag EndEvent
	#tag Event
		Function KeyDown(key As String) As Boolean
		  Select Case key
		  Case &u1B
		    // Escape clears the search.
		    Me.Text = ""
		    Return True
		  Case &u0D, &u03
		    ShowResults
		    Return True
		  Case &u1F
		    // Down arrow moves to the results.
		    If HitsList.Visible And HitsList.RowCount > 0 Then
		      HitsList.SetFocus
		      If HitsList.SelectedRowIndex < 0 Then HitsList.SelectedRowIndex = 0
		      Return True
		    End If
		  End Select
		  Return False
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events KindPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  If Not mLoading And IsSearching Then ShowResults
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events DatePopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  If Not mLoading And IsSearching Then ShowResults
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events HitsList
	#tag Event
		Function PaintCellText(g as Graphics, row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  // Draws the snippet with its matched terms in bold.
		  If column <> kHitColumnMatch Or row > Me.LastRowIndex Then Return False
		  
		  Var hit As WakeSearchHit = WakeSearchHit(Me.RowTagAt(row).ObjectValue)
		  If hit Is Nil Then Return False
		  
		  Var snippet As String = WakeFormat.OneLine(hit.Snippet, 0)
		  Var drawAt As Double = x
		  Var pieces() As String = snippet.Split(WakeSearchHit.MatchStart)
		  
		  For i As Integer = 0 To pieces.LastIndex
		    Var plain As String = pieces(i)
		    Var matched As String
		    If i > 0 Then
		      Var finish As Integer = plain.IndexOf(WakeSearchHit.MatchEnd)
		      If finish < 0 Then
		        matched = plain
		        plain = ""
		      Else
		        matched = plain.Left(finish)
		        plain = plain.Middle(finish + 1)
		      End If
		    End If
		    
		    If matched <> "" Then
		      g.Bold = True
		      g.DrawText(matched, drawAt, y)
		      drawAt = drawAt + g.TextWidth(matched)
		    End If
		    If plain <> "" Then
		      g.Bold = False
		      g.DrawText(plain, drawAt, y)
		      drawAt = drawAt + g.TextWidth(plain)
		    End If
		    If drawAt > g.Width Then Exit
		  Next
		  
		  g.Bold = False
		  Return True
		End Function
	#tag EndEvent
	#tag Event
		Function RowComparison(row1 as Integer, row2 as Integer, column as Integer, ByRef result as Integer) As Boolean
		  // Times sort by value, not by their text.
		  If column <> kHitColumnTime Then Return False
		  
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
		End Function
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  If Not mLoading Then ShowDetail(SelectedSession, SelectedHit)
		End Sub
	#tag EndEvent
	#tag Event
		Sub DoublePressed()
		  OpenTimeline
		End Sub
	#tag EndEvent
	#tag Event
		Function KeyDown(key As String) As Boolean
		  // Return or Enter opens the timeline at the match, like double-clicking the row.
		  If key = &u0D Or key = &u03 Then
		    OpenTimeline
		    Return True
		  End If
		  Return False
		End Function
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasTitleBar"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=true
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Window Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&cFFFFFF"
		Type="ColorGroup"
		EditorType="ColorGroup"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="DesktopMenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
