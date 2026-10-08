#tag DesktopWindow
Begin DesktopWindow PricesWindow
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
   Height          =   420
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   478898175
   MenuBarVisible  =   False
   MinimumHeight   =   240
   MinimumWidth    =   600
   Resizeable      =   True
   Title           =   "Prices"
   Type            =   0
   Visible         =   True
   Width           =   760
   Begin DesktopLabel NoteLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "SmallSystem"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   54
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   12
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   2
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "Prices in US dollars per million tokens. Wake has no built-in prices: copy them from your provider's price list. Click a cell to edit it. An empty “Cache write 1h” uses the “Cache write” price, and a dated model such as claude-haiku-4-5-20251001 also uses the price of claude-haiku-4-5."
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   10
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   736
   End
   Begin DesktopListBox PricesList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   6
      ColumnWidths    =   "*,90,90,100,110,100"
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
      Height          =   347
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
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   74
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   762
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  PricesList.HeaderAt(kColumnModel) = "Model"
		  PricesList.HeaderAt(kColumnInput) = "Input"
		  PricesList.HeaderAt(kColumnOutput) = "Output"
		  PricesList.HeaderAt(kColumnCacheWrite) = "Cache write"
		  PricesList.HeaderAt(kColumnCacheWrite1h) = "Cache write 1h"
		  PricesList.HeaderAt(kColumnCacheRead) = "Cache read"
		  For column As Integer = kColumnInput To kColumnCacheRead
		    PricesList.ColumnTypeAt(column) = DesktopListBox.CellTypes.TextField
		    PricesList.ColumnAlignmentAt(column) = DesktopListBox.Alignments.Right
		  Next
		  
		  If App.Prices.LoadError <> "" Then
		    NoteLabel.Text = App.Prices.LoadError + " Saving a price here replaces the file."
		  End If
		  
		  LoadRows
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FileCloseWindow() As Boolean Handles FileCloseWindow.Action
		  Self.Close
		  Return True
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h21
		Private Sub CommitRow(row As Integer)
		  // Stores the prices typed in a row. Clearing every cell removes the model's price.
		  If row < 0 Or row > PricesList.LastRowIndex Then Return
		  Var model As String = PricesList.CellTextAt(row, kColumnModel)
		  
		  Var values() As Double
		  Var anySet As Boolean
		  For column As Integer = kColumnInput To kColumnCacheRead
		    Var entry As String = PricesList.CellTextAt(row, column).Trim
		    Var value As Double
		    If entry = "" Then
		      values.Add(0)
		    ElseIf WakePriceTable.ParsePrice(entry, value) Then
		      values.Add(value)
		      anySet = True
		    Else
		      System.Beep
		      ShowRow(row, App.Prices.PriceFor(model))
		      Return
		    End If
		  Next
		  
		  Var price As WakeModelPrice
		  If anySet Then
		    price = New WakeModelPrice(model)
		    price.InputPerMillion = values(0)
		    price.OutputPerMillion = values(1)
		    price.CacheWritePerMillion = values(2)
		    price.CacheWrite1hPerMillion = values(3)
		    price.CacheReadPerMillion = values(4)
		  End If
		  
		  // Only save when something changed, since leaving a cell also commits it.
		  Var old As WakeModelPrice = App.Prices.PriceFor(model)
		  If old <> Nil And old.Model <> model Then old = Nil
		  If SamePrice(old, price) Then
		    ShowRow(row, price)
		    Return
		  End If
		  
		  If price Is Nil Then
		    App.Prices.RemovePrice(model)
		  Else
		    App.Prices.SetPrice(price)
		  End If
		  ShowRow(row, price)
		  App.PricesChanged
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EditNextCell()
		  // Runs just after a Tab press, so the cell being left has already been committed.
		  If mNextRow < 0 Or mNextRow > PricesList.LastRowIndex Then Return
		  PricesList.SelectedRowIndex = mNextRow
		  PricesList.EditCellAt(mNextRow, mNextColumn)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatPrice(value As Double) As String
		  If value <= 0 Then Return ""
		  Return value.ToString(Locale.Raw, "0.00####")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadRows()
		  // One row per model that has a price or has used tokens.
		  Var models() As String = App.Prices.Models
		  
		  // The index is only opened once an indexing run has finished, like in the main window.
		  If Not App.IsIndexing Then
		    Var index As New WakeIndex(WakeFolders.DefaultIndexFile)
		    Try
		      index.Open
		      Var catalog As New WakeCatalog(index)
		      For Each model As String In catalog.Models
		        If models.IndexOf(model) < 0 Then models.Add(model)
		      Next
		    Catch err As DatabaseException
		      System.DebugLog("Wake: could not read models from the index: " + err.Message)
		    Catch err As IOException
		      System.DebugLog("Wake: could not open the index: " + err.Message)
		    End Try
		    index.Close
		  End If
		  models.Sort
		  
		  PricesList.RemoveAllRows
		  For Each model As String In models
		    PricesList.AddRow(model)
		    Var price As WakeModelPrice = App.Prices.PriceFor(model)
		    If price <> Nil And price.Model <> model Then
		      // Priced through its undated name, which has a row of its own.
		      PricesList.CellTooltipAt(PricesList.LastAddedRowIndex, kColumnModel) = "Uses the price of " + price.Model + " unless set here"
		      price = Nil
		    End If
		    ShowRow(PricesList.LastAddedRowIndex, price)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SamePrice(a As WakeModelPrice, b As WakeModelPrice) As Boolean
		  If a Is Nil Or b Is Nil Then Return a Is b
		  Return a.InputPerMillion = b.InputPerMillion And a.OutputPerMillion = b.OutputPerMillion And _
		  a.CacheWritePerMillion = b.CacheWritePerMillion And a.CacheWrite1hPerMillion = b.CacheWrite1hPerMillion And _
		  a.CacheReadPerMillion = b.CacheReadPerMillion
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowRow(row As Integer, price As WakeModelPrice)
		  If price Is Nil Then
		    For column As Integer = kColumnInput To kColumnCacheRead
		      PricesList.CellTextAt(row, column) = ""
		    Next
		    Return
		  End If
		  
		  PricesList.CellTextAt(row, kColumnInput) = FormatPrice(price.InputPerMillion)
		  PricesList.CellTextAt(row, kColumnOutput) = FormatPrice(price.OutputPerMillion)
		  PricesList.CellTextAt(row, kColumnCacheWrite) = FormatPrice(price.CacheWritePerMillion)
		  PricesList.CellTextAt(row, kColumnCacheWrite1h) = FormatPrice(price.CacheWrite1hPerMillion)
		  PricesList.CellTextAt(row, kColumnCacheRead) = FormatPrice(price.CacheReadPerMillion)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mNextColumn As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNextRow As Integer = -1
	#tag EndProperty


	#tag Constant, Name = kColumnCacheRead, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCacheWrite, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCacheWrite1h, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnInput, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnModel, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnOutput, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant


#tag EndWindowCode

#tag Events PricesList
	#tag Event
		Sub CellAction(row As Integer, column As Integer)
		  #Pragma Unused column
		  CommitRow(row)
		End Sub
	#tag EndEvent
	#tag Event
		Sub CellFocusLost(row as Integer, column as Integer)
		  #Pragma Unused column
		  CommitRow(row)
		End Sub
	#tag EndEvent
	#tag Event
		Function CellKeyDown(row as Integer, column as Integer, key as String) As Boolean
		  // Tab edits the next price, going on to the next model's Input after Cache read.
		  // Shift+Tab goes back. Some systems send Shift+Tab as &u19.
		  If key <> &u09 And key <> &u19 Then Return False
		  
		  Var nextRow As Integer = row
		  Var nextColumn As Integer = column
		  If key = &u19 Or Keyboard.AsyncShiftKey Then
		    nextColumn = nextColumn - 1
		    If nextColumn < kColumnInput Then
		      nextColumn = kColumnCacheRead
		      nextRow = nextRow - 1
		    End If
		  Else
		    nextColumn = nextColumn + 1
		    If nextColumn > kColumnCacheRead Then
		      nextColumn = kColumnInput
		      nextRow = nextRow + 1
		    End If
		  End If
		  
		  // Past the first or last price, Tab just ends editing as usual.
		  If nextRow < 0 Or nextRow > Me.LastRowIndex Then Return False
		  
		  // Start the next edit once this key press is done, so the current cell is committed
		  // through CellAction first.
		  mNextRow = nextRow
		  mNextColumn = nextColumn
		  Timer.CallLater(0, AddressOf EditNextCell)
		  Return True
		End Function
	#tag EndEvent
#tag EndEvents
