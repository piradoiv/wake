#tag Class
Protected Class WakeGlanceTiles
Inherits DesktopCanvas
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  // An optional heading, then the tiles in rows of equal width.
		  #Pragma Unused areas
		  
		  Var dark As Boolean = Color.IsDarkMode
		  Var y As Double = kPadding
		  
		  If Heading <> "" Then
		    g.Bold = True
		    g.FontSize = 15
		    g.DrawingColor = Color.TextColor
		    g.DrawText(FitText(g, Heading, g.Width - kPadding * 2), kPadding, y + g.FontAscent)
		    y = y + g.TextHeight + 2
		    
		    If Subheading <> "" Then
		      g.Bold = False
		      g.FontSize = 11
		      g.DrawingColor = SecondaryTextColor
		      g.DrawText(FitText(g, Subheading, g.Width - kPadding * 2), kPadding, y + g.FontAscent)
		      y = y + g.TextHeight
		    End If
		    y = y + 10
		  End If
		  
		  If mCaptions.Count = 0 Then Return
		  
		  Var columns As Integer = ColumnCount(g.Width)
		  Var tileWidth As Double = (g.Width - kPadding * 2 - kGap * (columns - 1)) / columns
		  For i As Integer = 0 To mCaptions.LastIndex
		    Var tileLeft As Double = kPadding + (i Mod columns) * (tileWidth + kGap)
		    Var tileTop As Double = y + (i \ columns) * (kTileHeight + kGap)
		    DrawTile(g, tileLeft, tileTop, tileWidth, i, dark)
		  Next
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddTile(caption As String, value As String, detail As String, tint As Color)
		  // Call Refresh after adding the tiles.
		  mCaptions.Add(caption)
		  mValues.Add(value)
		  mDetails.Add(detail)
		  mTints.Add(tint)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ColumnCount(availableWidth As Double) As Integer
		  // As many tiles per row as fit at their minimum width, and no more than there are tiles.
		  Var fits As Integer = Floor((availableWidth - kPadding * 2 + kGap) / (kMinTileWidth + kGap))
		  Return Max(1, Min(fits, mCaptions.Count))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawTile(g As Graphics, x As Double, y As Double, tileWidth As Double, index As Integer, dark As Boolean)
		  // A tinted card: the caption in the tint, the value large, and a detail line below.
		  Var tint As Color = mTints(index)
		  Var inner As Double = tileWidth - 20
		  
		  g.DrawingColor = Color.RGB(tint.Red, tint.Green, tint.Blue, If(dark, 196, 220))
		  g.FillRoundRectangle(x, y, tileWidth, kTileHeight, 14, 14)
		  
		  g.Bold = True
		  g.FontSize = 10
		  g.DrawingColor = If(dark, tint, Shade(tint))
		  g.DrawText(FitText(g, mCaptions(index).Uppercase, inner), x + 10, y + 18)
		  
		  // The value in the largest size that fits the tile.
		  g.FontSize = 22
		  While g.FontSize > 12 And g.TextWidth(mValues(index)) > inner
		    g.FontSize = g.FontSize - 1
		  Wend
		  g.DrawingColor = Color.TextColor
		  g.DrawText(FitText(g, mValues(index), inner), x + 10, y + 44)
		  
		  If mDetails(index) <> "" Then
		    g.Bold = False
		    g.FontSize = 11
		    g.DrawingColor = SecondaryTextColor
		    g.DrawText(FitText(g, mDetails(index), inner), x + 10, y + 61)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FitText(g As Graphics, text As String, maxWidth As Double) As String
		  // The text, cut with an ellipsis when it is wider than maxWidth in the current font.
		  If g.TextWidth(text) <= maxWidth Then Return text
		  
		  Var kept As String = text
		  While kept.Length > 1 And g.TextWidth(kept + WakeFormat.kEllipsis) > maxWidth
		    kept = kept.Left(kept.Length - 1)
		  Wend
		  Return kept.TrimRight + WakeFormat.kEllipsis
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HeightFor(availableWidth As Double) As Integer
		  // The height the heading and every row of tiles need at this width.
		  Var result As Double = kPadding * 2
		  If Heading <> "" Then result = result + If(Subheading <> "", 44, 30)
		  If mCaptions.Count > 0 Then
		    Var columns As Integer = ColumnCount(availableWidth)
		    Var rows As Integer = (mCaptions.Count + columns - 1) \ columns
		    result = result + rows * kTileHeight + (rows - 1) * kGap
		  End If
		  Return Ceiling(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveAllTiles()
		  mCaptions.RemoveAll
		  mValues.RemoveAll
		  mDetails.RemoveAll
		  mTints.RemoveAll
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function SecondaryTextColor() As Color
		  // The text colour at about 65% opacity: quieter than the text, but readable on a tint,
		  // which the system's disabled-text grey is not.
		  Var text As Color = Color.TextColor
		  Return Color.RGB(text.Red, text.Green, text.Blue, 90)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Shade(tint As Color) As Color
		  // A darker tint, readable as text on a light background.
		  Return Color.RGB(tint.Red * 7 \ 10, tint.Green * 7 \ 10, tint.Blue * 7 \ 10)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowSession(s As WakeSessionInfo, usage As WakeUsageGroup, prices As WakePriceTable)
		  // The session's title, and tiles with its cost, tokens, time and prompts. usage is per model,
		  // subagents included. Set Subheading afterwards to show other facts.
		  RemoveAllTiles
		  Heading = s.DisplayTitle
		  Subheading = WakeFormat.ProjectName(s.ProjectPath) + " · " + _
		  If(s.StartTime Is Nil, WakeFormat.kUnknown, s.StartTime.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short))
		  
		  AddTile("Estimated cost", WakeFormat.Cost(prices.Estimate(usage.ByModel)), _
		  If(s.HasAgentCost, WakeFormat.USD(s.AgentCostUSD) + " reported", ""), kGreen)
		  
		  Var total As WakeTokenUsage = s.TotalUsage
		  Var inputSide As Int64 = total.InputTokens + total.CacheWriteTokens + total.CacheReadTokens
		  AddTile("Tokens", WakeFormat.Tokens(total.Total), _
		  If(inputSide > 0, WakeFormat.Percent(total.CacheReadTokens, inputSide) + " from cache", ""), kBlue)
		  
		  AddTile("Duration", WakeFormat.Duration(s.DurationSeconds), _
		  If(s.ActiveMs > 0, WakeFormat.Duration(s.ActiveMs / 1000) + " active", ""), kOrange)
		  
		  Var activity As String = WakeFormat.Count(s.EventCount) + " events"
		  If s.SubagentCount = 1 Then activity = activity + " · 1 subagent"
		  If s.SubagentCount > 1 Then activity = activity + " · " + s.SubagentCount.ToString + " subagents"
		  AddTile("Prompts", WakeFormat.Count(s.PromptCount), activity, kPurple)
		  
		  Refresh(False)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Heading As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaptions() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDetails() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTints() As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValues() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Subheading As String
	#tag EndProperty


	#tag Constant, Name = kBlue, Type = Color, Dynamic = False, Default = \"&c0A84FF", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kGap, Type = Double, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGreen, Type = Color, Dynamic = False, Default = \"&c30B856", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMinTileWidth, Type = Double, Dynamic = False, Default = \"140", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOrange, Type = Color, Dynamic = False, Default = \"&cFF9500", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPadding, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPink, Type = Color, Dynamic = False, Default = \"&cFF2D55", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPurple, Type = Color, Dynamic = False, Default = \"&cAF52DE", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kRed, Type = Color, Dynamic = False, Default = \"&cFF3B30", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTeal,Type = Color, Dynamic = False, Default = \"&c30B0C7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTileHeight, Type = Double, Dynamic = False, Default = \"70", Scope = Private
	#tag EndConstant


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
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Visible=false
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Tooltip"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocus"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowTabs"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Transparent"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Heading"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Subheading"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
