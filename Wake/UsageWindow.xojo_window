#tag DesktopWindow
Begin DesktopWindow UsageWindow
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
   Height          =   700
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   478898175
   MenuBarVisible  =   False
   MinimumHeight   =   500
   MinimumWidth    =   800
   Resizeable      =   True
   Title           =   "Usage"
   Type            =   0
   Visible         =   True
   Width           =   960
   Begin DesktopPopupMenu GroupPopup
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
      Left            =   12
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   2
      SelectedRowIndex=   -1
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Add up usage per day, project or model"
      Top             =   8
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   170
   End
   Begin DesktopPopupMenu PeriodPopup
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
      Left            =   192
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   2
      SelectedRowIndex=   -1
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Count only model responses from this period"
      Top             =   8
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   170
   End
   Begin WakeGlanceTiles GlanceTiles
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Heading         =   ""
      Height          =   94
      Index           =   -2147483648
      Left            =   0
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   2
      Subheading      =   ""
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   36
      Transparent     =   True
      Visible         =   True
      Width           =   960
   End
   Begin WakeDayChart DayChart
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      EndLabel        =   ""
      Height          =   150
      Index           =   -2147483648
      Left            =   0
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   2
      StartLabel      =   ""
      Summary         =   ""
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Tint            =   &c0A84FF00
      Title           =   ""
      Tooltip         =   ""
      Top             =   130
      Transparent     =   True
      Visible         =   True
      Width           =   960
   End
   Begin DesktopListBox UsageList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   8
      ColumnWidths    =   "*,70,90,90,100,100,90,110"
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
      Height          =   381
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   -1
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   2
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   284
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   962
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopListBox CallsList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   6
      ColumnWidths    =   "140,220,*,90,90,110"
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
      Height          =   201
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   -1
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   2
      TabIndex        =   6
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "The calls in the selected group, most tokens first. Double-click one to open it in its timeline."
      Top             =   464
      Transparent     =   False
      Underline       =   False
      Visible         =   False
      Width           =   962
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
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
      Left            =   12
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   False
      Scope           =   2
      Selectable      =   False
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   672
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   936
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
		  SetUp
		  LayOutLists
		  
		  // Like the main window, open the index only once an indexing run has finished.
		  If App.IsIndexing Then
		    StatusLabel.Text = "Indexing" + WakeFormat.kEllipsis
		  Else
		    Reload
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resized()
		  LayOutLists
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resizing()
		  LayOutLists
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FileCloseWindow() As Boolean Handles FileCloseWindow.Action
		  Self.Close
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
		Private Sub AddUsageRow(label As String, sortKey As String, usage As WakeUsageGroup)
		  Var total As WakeTokenUsage = usage.Total
		  Var estimate As WakeCostEstimate = App.Prices.Estimate(usage.ByModel)
		  
		  UsageList.AddRow(label, WakeFormat.Count(usage.SessionCount), WakeFormat.Tokens(total.InputTokens), _
		  WakeFormat.Tokens(total.OutputTokens), WakeFormat.Tokens(total.CacheWriteTokens), _
		  WakeFormat.Tokens(total.CacheReadTokens), WakeFormat.Tokens(total.Total), WakeFormat.Cost(estimate))
		  
		  Var row As Integer = UsageList.LastAddedRowIndex
		  UsageList.CellTagAt(row, kColumnLabel) = sortKey
		  UsageList.CellTagAt(row, kColumnSessions) = usage.SessionCount
		  UsageList.CellTagAt(row, kColumnInput) = total.InputTokens
		  UsageList.CellTagAt(row, kColumnOutput) = total.OutputTokens
		  UsageList.CellTagAt(row, kColumnCacheWrite) = total.CacheWriteTokens
		  UsageList.CellTagAt(row, kColumnCacheRead) = total.CacheReadTokens
		  UsageList.CellTagAt(row, kColumnTotal) = total.Total
		  UsageList.CellTagAt(row, kColumnCost) = If(estimate.PricedTokens > 0, estimate.AmountUSD, -1.0)
		  If estimate.UnpricedModels.Count > 0 Then
		    UsageList.CellTooltipAt(row, kColumnCost) = "No price set for " + String.FromArray(estimate.UnpricedModels, ", ")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CloseCatalog()
		  mCatalog = Nil
		  If mIndex <> Nil Then mIndex.Close
		  mIndex = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CompareCells(list As DesktopListBox, row1 As Integer, row2 As Integer, column As Integer, asText As Boolean) As Integer
		  // Compares two rows by the cell tags of a column: as text, or by value.
		  If asText Then Return list.CellTagAt(row1, column).StringValue.Compare(list.CellTagAt(row2, column).StringValue)
		  
		  Var a As Double = list.CellTagAt(row1, column).DoubleValue
		  Var b As Double = list.CellTagAt(row2, column).DoubleValue
		  If a < b Then Return -1
		  If a > b Then Return 1
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DayLabel(key As String) As String
		  // "Thursday, 8 October 2026" in the user's format, from the index's "2026-10-08".
		  If key = "" Then Return "Unknown date"
		  
		  Try
		    Var day As DateTime = DateTime.FromString(key)
		    Return day.ToString(DateTime.FormatStyles.Full, DateTime.FormatStyles.None)
		  Catch err As RuntimeException
		    Return key
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IndexingFinished()
		  // The index changed or was rebuilt, so read it again on a fresh connection.
		  CloseCatalog
		  Reload
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LayOutLists()
		  // The groups fill the space below the chart. For a tool grouping, the calls of the selected
		  // group share it, and the two lists overlap by a pixel so their borders draw as one line.
		  Var bottom As Integer = StatusLabel.Top - 7
		  Var available As Integer = Max(bottom - UsageList.Top, 80)
		  
		  If CallsList.Visible Then
		    UsageList.Height = available * 45 \ 100
		    CallsList.Top = UsageList.Top + UsageList.Height - 1
		    CallsList.Height = Max(bottom - CallsList.Top, 40)
		  Else
		    UsageList.Height = available
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenSelectedCall()
		  // Opens the selected call's timeline at its event, or brings its window to the front if it
		  // is open, the way search hits do.
		  If CallsList.SelectedRowIndex < 0 Then Return
		  Var c As WakeToolCallInfo = WakeToolCallInfo(CallsList.RowTagAt(CallsList.SelectedRowIndex).ObjectValue)
		  If c Is Nil Or c.Session Is Nil Or c.Session.FilePath = "" Then Return
		  
		  For i As Integer = 0 To App.WindowCount - 1
		    Var existing As DesktopWindow = App.WindowAt(i)
		    If existing IsA SessionWindow And SessionWindow(existing).SessionID = c.Session.ID Then
		      existing.Show
		      SessionWindow(existing).ShowEvent(c.EventSessionUID, c.Sequence)
		      Return
		    End If
		  Next
		  
		  Var timelineWindow As New SessionWindow
		  timelineWindow.ShowSession(c.Session)
		  timelineWindow.ShowEvent(c.EventSessionUID, c.Sequence)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PricesChanged()
		  If mCatalog <> Nil Then Reload
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Reload()
		  // Fills the list with usage per day, project or model in the chosen period, and sums it
		  // up in the tiles above the list and below it.
		  UsageList.RemoveAllRows
		  CallsList.RemoveAllRows
		  GlanceTiles.RemoveAllTiles
		  GlanceTiles.Refresh(False)
		  DayChart.RemoveAllBars
		  DayChart.Refresh(False)
		  
		  If mCatalog Is Nil Then
		    Var index As New WakeIndex(WakeFolders.DefaultIndexFile)
		    Try
		      index.Open
		    Catch err As DatabaseException
		      StatusLabel.Text = "Could not open the index: " + err.Message
		      Return
		    Catch err As IOException
		      StatusLabel.Text = "Could not open the index: " + err.Message
		      Return
		    End Try
		    mIndex = index
		    mCatalog = New WakeCatalog(index)
		  End If
		  
		  Var periodStart As DateTime
		  Var days As Integer = PeriodPopup.RowTagAt(PeriodPopup.SelectedRowIndex).IntegerValue
		  If days > 0 Then
		    Var now As DateTime = DateTime.Now
		    Var midnight As New DateTime(now.Year, now.Month, now.Day)
		    periodStart = midnight.SubtractInterval(0, 0, days - 1)
		  End If
		  
		  Var tag As Integer = GroupPopup.RowTagAt(GroupPopup.SelectedRowIndex).IntegerValue
		  mPeriodStart = periodStart
		  mToolGrouping = If(tag >= kToolGroupingBase, tag - kToolGroupingBase, -1)
		  CallsList.Visible = mToolGrouping >= 0
		  LayOutLists
		  
		  If mToolGrouping >= 0 Then
		    ShowToolUsage(WakeCatalog.ToolGroupings(mToolGrouping), periodStart)
		    ShowGlance(periodStart)
		    Return
		  End If
		  
		  Var grouping As WakeCatalog.UsageGroupings = WakeCatalog.UsageGroupings(tag)
		  Var label As String = "Model"
		  Select Case grouping
		  Case WakeCatalog.UsageGroupings.Day
		    label = "Day"
		  Case WakeCatalog.UsageGroupings.Project
		    label = "Project"
		  End Select
		  SetHeaders(Array(label, "Sessions", "Input", "Output", "Cache write", "Cache read", "Total", "Est. cost"))
		  
		  Var groups() As WakeUsageGroup
		  Try
		    groups = mCatalog.Usage(grouping, periodStart)
		  Catch err As DatabaseException
		    StatusLabel.Text = "Could not read the index: " + err.Message
		    Return
		  End Try
		  
		  Var all As New WakeUsageGroup
		  For Each g As WakeUsageGroup In groups
		    Select Case grouping
		    Case WakeCatalog.UsageGroupings.Day
		      AddUsageRow(DayLabel(g.Key), g.Key, g)
		    Case WakeCatalog.UsageGroupings.Project
		      Var name As String = WakeFormat.ProjectName(g.Label)
		      AddUsageRow(name, name, g)
		      UsageList.CellTooltipAt(UsageList.LastAddedRowIndex, kColumnLabel) = g.Label
		    Else
		      AddUsageRow(g.Label, g.Label, g)
		    End Select
		    
		    For Each model As Variant In g.ByModel.Keys
		      all.Add(model.StringValue, WakeTokenUsage(g.ByModel.Value(model).ObjectValue))
		    Next
		  Next
		  
		  If UsageList.SortingColumn >= 0 Then UsageList.Sort
		  
		  Var estimate As WakeCostEstimate = App.Prices.Estimate(all.ByModel)
		  Var parts() As String
		  parts.Add(WakeFormat.Count(all.Total.Total) + " tokens")
		  If estimate.HasTokens Then parts.Add("estimated cost " + WakeFormat.Cost(estimate))
		  If estimate.UnpricedModels.Count > 0 Then
		    parts.Add("no price set for " + String.FromArray(estimate.UnpricedModels, ", ") + " (Window → Prices)")
		  End If
		  StatusLabel.Text = String.FromArray(parts, " · ")
		  
		  ShowGlance(periodStart)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetHeaders(labels() As String)
		  For column As Integer = 0 To labels.LastIndex
		    UsageList.HeaderAt(column) = labels(column)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetUp()
		  mLoading = True
		  
		  // Each grouping row's tag is its WakeCatalog.UsageGroupings value.
		  GroupPopup.AddRow("By day")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = Integer(WakeCatalog.UsageGroupings.Day)
		  GroupPopup.AddRow("By project")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = Integer(WakeCatalog.UsageGroupings.Project)
		  GroupPopup.AddRow("By model")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = Integer(WakeCatalog.UsageGroupings.Model)
		  
		  // Tool groupings show where the tokens went. Their tags are kToolGroupingBase plus their
		  // WakeCatalog.ToolGroupings value.
		  GroupPopup.AddSeparator
		  GroupPopup.AddRow("By tool")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = kToolGroupingBase + Integer(WakeCatalog.ToolGroupings.Tool)
		  GroupPopup.AddRow("By tool and file type")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = kToolGroupingBase + Integer(WakeCatalog.ToolGroupings.ToolAndFileType)
		  GroupPopup.AddRow("By shell command")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = kToolGroupingBase + Integer(WakeCatalog.ToolGroupings.Command)
		  GroupPopup.AddRow("By file")
		  GroupPopup.RowTagAt(GroupPopup.LastAddedRowIndex) = kToolGroupingBase + Integer(WakeCatalog.ToolGroupings.File)
		  GroupPopup.SelectedRowIndex = 0
		  
		  // Each period row's tag is its length in days, counted back from the end of today.
		  // 0 means all time.
		  PeriodPopup.AddRow("Today")
		  PeriodPopup.RowTagAt(PeriodPopup.LastAddedRowIndex) = 1
		  PeriodPopup.AddRow("Last 7 days")
		  PeriodPopup.RowTagAt(PeriodPopup.LastAddedRowIndex) = 7
		  PeriodPopup.AddRow("Last 30 days")
		  PeriodPopup.RowTagAt(PeriodPopup.LastAddedRowIndex) = 30
		  PeriodPopup.AddRow("Last 12 months")
		  PeriodPopup.RowTagAt(PeriodPopup.LastAddedRowIndex) = 365
		  PeriodPopup.AddRow("All time")
		  PeriodPopup.RowTagAt(PeriodPopup.LastAddedRowIndex) = 0
		  PeriodPopup.SelectedRowIndex = 2
		  
		  For column As Integer = kColumnSessions To kColumnCost
		    UsageList.ColumnAlignmentAt(column) = DesktopListBox.Alignments.Right
		  Next
		  For column As Integer = kCallColumnAdded To kCallColumnCost
		    CallsList.ColumnAlignmentAt(column) = DesktopListBox.Alignments.Right
		  Next
		  CallsList.HeaderAt(kCallColumnTime) = "Time"
		  CallsList.HeaderAt(kCallColumnSession) = "Session"
		  CallsList.HeaderAt(kCallColumnCall) = "Call"
		  CallsList.HeaderAt(kCallColumnAdded) = "≈ Added"
		  CallsList.HeaderAt(kCallColumnCarried) = "≈ Re-read"
		  CallsList.HeaderAt(kCallColumnCost) = "Est. cost"
		  mToolGrouping = -1
		  
		  mLoading = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowCalls()
		  // Lists the calls of the selected tool group, most tokens first.
		  CallsList.RemoveAllRows
		  If mToolGrouping < 0 Or mCatalog Is Nil Or UsageList.SelectedRowIndex < 0 Then Return
		  
		  Var key As String = UsageList.RowTagAt(UsageList.SelectedRowIndex).StringValue
		  Var calls() As WakeToolCallInfo
		  Try
		    calls = mCatalog.ToolCalls(WakeCatalog.ToolGroupings(mToolGrouping), key, mPeriodStart)
		  Catch err As DatabaseException
		    StatusLabel.Text = "Could not read the index: " + err.Message
		    Return
		  End Try
		  
		  For Each c As WakeToolCallInfo In calls
		    Var estimate As WakeCostEstimate = App.Prices.Estimate(c.Usage.ByModel)
		    Var title As String = If(c.Session Is Nil, WakeFormat.kUnknown, c.Session.DisplayTitle)
		    Var description As String = WakeFormat.OneLine(c.Description, 200)
		    Var shownTime As String = WakeFormat.kUnknown
		    If c.Timestamp <> Nil Then shownTime = c.Timestamp.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short)
		    
		    CallsList.AddRow(shownTime, title, description, WakeFormat.Tokens(c.AddedTokens), _
		    WakeFormat.Tokens(c.CarriedTokens), If(estimate.HasTokens, WakeFormat.Cost(estimate), WakeFormat.kUnknown))
		    
		    Var row As Integer = CallsList.LastAddedRowIndex
		    CallsList.RowTagAt(row) = c
		    CallsList.CellTagAt(row, kCallColumnTime) = If(c.Timestamp Is Nil, 0.0, c.Timestamp.SecondsFrom1970)
		    CallsList.CellTagAt(row, kCallColumnSession) = title
		    CallsList.CellTagAt(row, kCallColumnCall) = description
		    CallsList.CellTagAt(row, kCallColumnAdded) = c.AddedTokens
		    CallsList.CellTagAt(row, kCallColumnCarried) = c.CarriedTokens
		    CallsList.CellTagAt(row, kCallColumnCost) = If(estimate.PricedTokens > 0, estimate.AmountUSD, -1.0)
		    CallsList.CellTooltipAt(row, kCallColumnCall) = c.Description
		    If c.Session <> Nil Then CallsList.CellTooltipAt(row, kCallColumnSession) = c.Session.ProjectPath
		    If estimate.UnpricedModels.Count > 0 Then
		      CallsList.CellTooltipAt(row, kCallColumnCost) = "No price set for " + String.FromArray(estimate.UnpricedModels, ", ")
		    End If
		  Next
		  
		  If CallsList.SortingColumn >= 0 Then CallsList.Sort
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowGlance(periodStart As DateTime)
		  // Tiles with the period's totals, and a bar per day. A period shorter than kMinChartDays
		  // is shown within that many days, with its own days in full colour.
		  Var now As DateTime = DateTime.Now
		  Var today As New DateTime(now.Year, now.Month, now.Day)
		  Var chartStart As DateTime
		  If periodStart <> Nil Then
		    chartStart = today.SubtractInterval(0, 0, kMinChartDays - 1)
		    If periodStart < chartStart Then chartStart = periodStart
		  End If
		  
		  Var dayGroups() As WakeUsageGroup
		  Var projectGroups() As WakeUsageGroup
		  Try
		    dayGroups = mCatalog.Usage(WakeCatalog.UsageGroupings.Day, chartStart)
		    projectGroups = mCatalog.Usage(WakeCatalog.UsageGroupings.Project, periodStart)
		  Catch err As DatabaseException
		    Return
		  End Try
		  
		  // Every session belongs to one project, so the project groups count each session once.
		  Var all As New WakeUsageGroup
		  Var sessions As Integer
		  For Each g As WakeUsageGroup In projectGroups
		    sessions = sessions + g.SessionCount
		    For Each model As Variant In g.ByModel.Keys
		      all.Add(model.StringValue, WakeTokenUsage(g.ByModel.Value(model).ObjectValue))
		    Next
		  Next
		  Var total As WakeTokenUsage = all.Total
		  Var estimate As WakeCostEstimate = App.Prices.Estimate(all.ByModel)
		  Var useCost As Boolean = estimate.PricedTokens > 0
		  
		  // All time starts at the first day with usage.
		  Var byDay As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  Var earliest As String
		  For Each g As WakeUsageGroup In dayGroups
		    If g.Key = "" Then Continue
		    byDay.Value(g.Key) = g
		    If earliest = "" Or g.Key.Compare(earliest) < 0 Then earliest = g.Key
		  Next
		  If chartStart Is Nil Then
		    chartStart = today
		    If earliest <> "" Then
		      Try
		        chartStart = DateTime.FromString(earliest)
		      Catch err As RuntimeException
		        chartStart = today
		      End Try
		    End If
		  End If
		  Var oldest As DateTime = today.SubtractInterval(0, 0, kMaxChartDays - 1)
		  If chartStart < oldest Then chartStart = oldest
		  
		  DayChart.Title = If(useCost, "Estimated cost per day", "Tokens per day")
		  DayChart.Tint = If(useCost, WakeGlanceTiles.kGreen, WakeGlanceTiles.kBlue)
		  DayChart.StartLabel = chartStart.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.None)
		  DayChart.EndLabel = "Today"
		  
		  Var activeDays As Integer
		  Var busiestValue As Double
		  Var busiestDay As DateTime
		  Var day As DateTime = chartStart
		  While day <= today
		    Var tip As String = day.ToString(DateTime.FormatStyles.Full, DateTime.FormatStyles.None)
		    Var value As Double = 0
		    Var inPeriod As Boolean = periodStart Is Nil Or day >= periodStart
		    
		    Var g As WakeUsageGroup = WakeUsageGroup(byDay.Lookup(day.SQLDate, Nil).ObjectValue)
		    If g Is Nil Then
		      tip = tip + ": no usage"
		    Else
		      Var dayEstimate As WakeCostEstimate = App.Prices.Estimate(g.ByModel)
		      Var dayTokens As Int64 = g.Total.Total
		      If useCost Then
		        value = dayEstimate.AmountUSD
		      Else
		        value = dayTokens
		      End If
		      tip = tip + ": " + If(useCost, WakeFormat.Cost(dayEstimate) + " · ", "") + WakeFormat.Tokens(dayTokens) + _
		      " tokens · " + If(g.SessionCount = 1, "1 session", g.SessionCount.ToString + " sessions")
		      
		      If inPeriod And dayTokens > 0 Then
		        activeDays = activeDays + 1
		        If value > busiestValue Then
		          busiestValue = value
		          busiestDay = day
		        End If
		      End If
		    End If
		    
		    DayChart.AddBar(value, tip, inPeriod)
		    day = day.AddInterval(0, 0, 1)
		  Wend
		  DayChart.Summary = If(activeDays = 1, "1 active day", activeDays.ToString + " active days")
		  DayChart.Refresh(False)
		  
		  Var perDay As String = "Set prices in Window → Prices"
		  If useCost And activeDays > 0 Then perDay = WakeFormat.USD(estimate.AmountUSD / activeDays) + " per active day"
		  GlanceTiles.AddTile("Estimated cost", WakeFormat.Cost(estimate), perDay, WakeGlanceTiles.kGreen)
		  
		  GlanceTiles.AddTile("Tokens", WakeFormat.Tokens(total.Total), WakeFormat.Tokens(total.OutputTokens) + " output", WakeGlanceTiles.kBlue)
		  
		  GlanceTiles.AddTile("Sessions", WakeFormat.Count(sessions), _
		  "in " + If(projectGroups.Count = 1, "1 project", projectGroups.Count.ToString + " projects"), WakeGlanceTiles.kPurple)
		  
		  If busiestDay Is Nil Then
		    GlanceTiles.AddTile("Busiest day", WakeFormat.kUnknown, "", WakeGlanceTiles.kOrange)
		  Else
		    GlanceTiles.AddTile("Busiest day", If(useCost, WakeFormat.USD(busiestValue), WakeFormat.Tokens(busiestValue)), _
		    busiestDay.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.None), WakeGlanceTiles.kOrange)
		  End If
		  
		  // The share of input tokens read from the cache instead of sent again.
		  Var inputSide As Int64 = total.InputTokens + total.CacheWriteTokens + total.CacheReadTokens
		  GlanceTiles.AddTile("Cache hits", WakeFormat.Percent(total.CacheReadTokens, inputSide), _
		  If(inputSide > 0, WakeFormat.Tokens(total.CacheReadTokens) + " read from cache", ""), WakeGlanceTiles.kTeal)
		  GlanceTiles.Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowToolUsage(grouping As WakeCatalog.ToolGroupings, periodStart As DateTime)
		  // Where the tokens went: what each group's tool results added to the context, and how often
		  // later responses read them again. Both are estimates, so they're marked with ≈.
		  Var label As String
		  Select Case grouping
		  Case WakeCatalog.ToolGroupings.Tool
		    label = "Tool"
		  Case WakeCatalog.ToolGroupings.ToolAndFileType
		    label = "Tool and file type"
		  Case WakeCatalog.ToolGroupings.Command
		    label = "Shell command"
		  Else
		    label = "File"
		  End Select
		  SetHeaders(Array(label, "Calls", "Sessions", "≈ Added", "≈ Per call", "≈ Re-read", "≈ Total", "Est. cost"))
		  
		  Var groups() As WakeToolUsageGroup
		  Try
		    groups = mCatalog.ToolUsage(grouping, periodStart)
		  Catch err As DatabaseException
		    StatusLabel.Text = "Could not read the index: " + err.Message
		    Return
		  End Try
		  
		  Var all As New WakeUsageGroup
		  Var calls As Integer
		  Var added, carried As Int64
		  
		  For Each g As WakeToolUsageGroup In groups
		    Var perCall As Int64 = If(g.Calls > 0, g.AddedTokens \ g.Calls, 0)
		    Var estimate As WakeCostEstimate = App.Prices.Estimate(g.ByModel)
		    Var shown As String = If(g.Key = "", "(none)", g.Key)
		    If grouping = WakeCatalog.ToolGroupings.File Then shown = WakeFormat.ProjectName(g.Key)
		    
		    UsageList.AddRow(shown, WakeFormat.Count(g.Calls), WakeFormat.Count(g.SessionCount), WakeFormat.Tokens(g.AddedTokens), _
		    WakeFormat.Tokens(perCall), WakeFormat.Tokens(g.CarriedTokens), WakeFormat.Tokens(g.AddedTokens + g.CarriedTokens), _
		    If(estimate.HasTokens, WakeFormat.Cost(estimate), WakeFormat.kUnknown))
		    
		    Var row As Integer = UsageList.LastAddedRowIndex
		    UsageList.RowTagAt(row) = g.Key
		    UsageList.CellTagAt(row, kColumnLabel) = shown
		    UsageList.CellTagAt(row, kColumnSessions) = g.Calls
		    UsageList.CellTagAt(row, kColumnInput) = g.SessionCount
		    UsageList.CellTagAt(row, kColumnOutput) = g.AddedTokens
		    UsageList.CellTagAt(row, kColumnCacheWrite) = perCall
		    UsageList.CellTagAt(row, kColumnCacheRead) = g.CarriedTokens
		    UsageList.CellTagAt(row, kColumnTotal) = g.AddedTokens + g.CarriedTokens
		    UsageList.CellTagAt(row, kColumnCost) = If(estimate.PricedTokens > 0, estimate.AmountUSD, -1.0)
		    If grouping = WakeCatalog.ToolGroupings.File Then UsageList.CellTooltipAt(row, kColumnLabel) = g.Key
		    If estimate.UnpricedModels.Count > 0 Then
		      UsageList.CellTooltipAt(row, kColumnCost) = "No price set for " + String.FromArray(estimate.UnpricedModels, ", ")
		    End If
		    
		    calls = calls + g.Calls
		    added = added + g.AddedTokens
		    carried = carried + g.CarriedTokens
		    For Each model As Variant In g.ByModel.Keys
		      all.Add(model.StringValue, WakeTokenUsage(g.ByModel.Value(model).ObjectValue))
		    Next
		  Next
		  
		  If UsageList.SortingColumn >= 0 Then UsageList.Sort
		  
		  // Commands and files cover only some calls, so their totals aren't summed up here.
		  Var parts() As String
		  If grouping = WakeCatalog.ToolGroupings.Tool Or grouping = WakeCatalog.ToolGroupings.ToolAndFileType Then
		    parts.Add(WakeFormat.Count(calls) + " tool calls")
		    parts.Add("≈" + WakeFormat.Tokens(added) + " added")
		    parts.Add("≈" + WakeFormat.Tokens(carried) + " re-read")
		    Var estimate As WakeCostEstimate = App.Prices.Estimate(all.ByModel)
		    If estimate.PricedTokens > 0 Then parts.Add("estimated cost " + WakeFormat.Cost(estimate))
		  End If
		  parts.Add("estimated from how the context grows between responses")
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
		Private mLoading As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPeriodStart As DateTime
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolGrouping As Integer = -1
	#tag EndProperty


	#tag Constant, Name = kCallColumnAdded, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCallColumnCall, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCallColumnCarried, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCallColumnCost, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCallColumnSession, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCallColumnTime, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCacheRead, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCacheWrite, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCost, Type = Double, Dynamic = False, Default = \"7", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnInput, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnLabel, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnOutput, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnSessions, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnTotal, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaxChartDays, Type = Double, Dynamic = False, Default = \"1830", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinChartDays, Type = Double, Dynamic = False, Default = \"14", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolGroupingBase, Type = Double, Dynamic = False, Default = \"100", Scope = Private
	#tag EndConstant


#tag EndWindowCode

#tag Events GroupPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  If Not mLoading And mCatalog <> Nil Then Reload
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PeriodPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  If Not mLoading And mCatalog <> Nil Then Reload
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events UsageList
	#tag Event
		Function RowComparison(row1 as Integer, row2 as Integer, column as Integer, ByRef result as Integer) As Boolean
		  // Days sort by date and numbers by value, not by their text. A row with no price sorts
		  // below every priced one.
		  result = CompareCells(Me, row1, row2, column, column = kColumnLabel)
		  Return True
		End Function
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  ShowCalls
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events CallsList
	#tag Event
		Sub DoublePressed()
		  OpenSelectedCall
		End Sub
	#tag EndEvent
	#tag Event
		Function RowComparison(row1 as Integer, row2 as Integer, column as Integer, ByRef result as Integer) As Boolean
		  // Times and numbers sort by value. A call with no price sorts below every priced one.
		  result = CompareCells(Me, row1, row2, column, column = kCallColumnSession Or column = kCallColumnCall)
		  Return True
		End Function
	#tag EndEvent
#tag EndEvents
