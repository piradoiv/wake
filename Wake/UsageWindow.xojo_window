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
   Height          =   560
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   478898175
   MenuBarVisible  =   False
   MinimumHeight   =   300
   MinimumWidth    =   640
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
      Height          =   481
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
      Top             =   44
      Transparent     =   False
      Underline       =   False
      Visible         =   True
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
      Top             =   532
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
		  
		  // Like the main window, open the index only once an indexing run has finished.
		  If App.IsIndexing Then
		    StatusLabel.Text = "Indexing" + WakeFormat.kEllipsis
		  Else
		    Reload
		  End If
		End Sub
	#tag EndEvent


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

	#tag Method, Flags = &h0
		Sub PricesChanged()
		  If mCatalog <> Nil Then Reload
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Reload()
		  // Fills the list with usage per day, project or model in the chosen period, and sums it
		  // up below the list.
		  UsageList.RemoveAllRows
		  
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
		  
		  Var grouping As WakeCatalog.UsageGroupings = WakeCatalog.UsageGroupings(GroupPopup.RowTagAt(GroupPopup.SelectedRowIndex).IntegerValue)
		  Select Case grouping
		  Case WakeCatalog.UsageGroupings.Day
		    UsageList.HeaderAt(kColumnLabel) = "Day"
		  Case WakeCatalog.UsageGroupings.Project
		    UsageList.HeaderAt(kColumnLabel) = "Project"
		  Else
		    UsageList.HeaderAt(kColumnLabel) = "Model"
		  End Select
		  
		  Var periodStart As DateTime
		  Var days As Integer = PeriodPopup.RowTagAt(PeriodPopup.SelectedRowIndex).IntegerValue
		  If days > 0 Then
		    Var now As DateTime = DateTime.Now
		    Var midnight As New DateTime(now.Year, now.Month, now.Day)
		    periodStart = midnight.SubtractInterval(0, 0, days - 1)
		  End If
		  
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
		  
		  UsageList.HeaderAt(kColumnSessions) = "Sessions"
		  UsageList.HeaderAt(kColumnInput) = "Input"
		  UsageList.HeaderAt(kColumnOutput) = "Output"
		  UsageList.HeaderAt(kColumnCacheWrite) = "Cache write"
		  UsageList.HeaderAt(kColumnCacheRead) = "Cache read"
		  UsageList.HeaderAt(kColumnTotal) = "Total"
		  UsageList.HeaderAt(kColumnCost) = "Est. cost"
		  For column As Integer = kColumnSessions To kColumnCost
		    UsageList.ColumnAlignmentAt(column) = DesktopListBox.Alignments.Right
		  Next
		  
		  mLoading = False
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
		  If column = kColumnLabel Then
		    result = Me.CellTagAt(row1, column).StringValue.Compare(Me.CellTagAt(row2, column).StringValue)
		    Return True
		  End If
		  
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
#tag EndEvents
