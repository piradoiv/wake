#tag Class
Protected Class WakeDayChart
Inherits DesktopCanvas
	#tag Event
		Sub MouseExit()
		  If mHover < 0 Then Return
		  mHover = -1
		  Me.Tooltip = ""
		  Me.Refresh(False)
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(x As Integer, y As Integer)
		  // The bar under the pointer is highlighted, and its tooltip names the day and its value.
		  #Pragma Unused y
		  Var index As Integer = BarAt(x)
		  If index = mHover Then Return
		  mHover = index
		  Me.Tooltip = If(index >= 0, mTips(index), "")
		  Me.Refresh(False)
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  // The title and a summary on top, one bar per day, and the first and last day below.
		  #Pragma Unused areas
		  
		  Var dark As Boolean = Color.IsDarkMode
		  
		  g.FontSize = 11
		  g.Bold = True
		  g.DrawingColor = Color.TextColor
		  g.DrawText(Title, kPadding, kPadding + g.FontAscent)
		  If Summary <> "" Then
		    g.Bold = False
		    g.DrawingColor = WakeGlanceTiles.SecondaryTextColor
		    g.DrawText(Summary, g.Width - kPadding - g.TextWidth(Summary), kPadding + g.FontAscent)
		  End If
		  
		  Var plotTop As Double = kPadding + 26
		  Var plotBottom As Double = g.Height - kPadding - 16
		  Var plotHeight As Double = plotBottom - plotTop
		  Var slot As Double = (g.Width - kPadding * 2) / Max(1, mValues.Count)
		  
		  g.DrawingColor = Color.RGB(128, 128, 128, 170)
		  g.DrawLine(kPadding, plotBottom + 0.5, g.Width - kPadding, plotBottom + 0.5)
		  
		  If mMax <= 0 Then
		    g.FontSize = 12
		    g.DrawingColor = WakeGlanceTiles.SecondaryTextColor
		    Var message As String = "No usage in this period"
		    g.DrawText(message, (g.Width - g.TextWidth(message)) / 2, plotTop + plotHeight / 2)
		  Else
		    // Bars leave a gap between them while there is room for one.
		    Var barWidth As Double = If(slot >= 4, slot * 0.7, slot)
		    For i As Integer = 0 To mValues.LastIndex
		      If mValues(i) <= 0 Then Continue
		      Var barHeight As Double = Max(2, mValues(i) / mMax * plotHeight)
		      Var barLeft As Double = kPadding + i * slot + (slot - barWidth) / 2
		      
		      If i = mHover Then
		        g.DrawingColor = If(dark, Tint, WakeGlanceTiles.Shade(Tint))
		      ElseIf mEmphasized(i) Then
		        g.DrawingColor = Tint
		      Else
		        g.DrawingColor = Color.RGB(Tint.Red, Tint.Green, Tint.Blue, 170)
		      End If
		      
		      // Rounded on top only: the lower half is filled square.
		      If barWidth >= 6 And barHeight >= 6 Then
		        g.FillRoundRectangle(barLeft, plotBottom - barHeight, barWidth, barHeight, 6, 6)
		        g.FillRectangle(barLeft, plotBottom - barHeight / 2, barWidth, barHeight / 2)
		      Else
		        g.FillRectangle(barLeft, plotBottom - barHeight, barWidth, barHeight)
		      End If
		    Next
		  End If
		  
		  g.Bold = False
		  g.FontSize = 10
		  g.DrawingColor = WakeGlanceTiles.SecondaryTextColor
		  Var labelBaseline As Double = g.Height - kPadding
		  g.DrawText(StartLabel, kPadding, labelBaseline)
		  g.DrawText(EndLabel, g.Width - kPadding - g.TextWidth(EndLabel), labelBaseline)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddBar(value As Double, tip As String, emphasized As Boolean)
		  // One bar per day, oldest first. Bars that are not emphasized are drawn lighter. Call
		  // Refresh after adding the bars.
		  mValues.Add(value)
		  mTips.Add(tip)
		  mEmphasized.Add(emphasized)
		  If value > mMax Then mMax = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BarAt(x As Integer) As Integer
		  If mValues.Count = 0 Then Return -1
		  Var slot As Double = (Me.Width - kPadding * 2) / mValues.Count
		  Var index As Integer = Floor((x - kPadding) / slot)
		  If index < 0 Or index > mValues.LastIndex Then Return -1
		  Return index
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveAllBars()
		  mValues.RemoveAll
		  mTips.RemoveAll
		  mEmphasized.RemoveAll
		  mMax = 0
		  mHover = -1
		  Me.Tooltip = ""
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		EndLabel As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEmphasized() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHover As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMax As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTips() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValues() As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		StartLabel As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Summary As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Tint As Color = &c0A84FF
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty


	#tag Constant, Name = kPadding, Type = Double, Dynamic = False, Default = \"12", Scope = Private
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
			Name="EndLabel"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StartLabel"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Summary"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Tint"
			Visible=false
			Group="Behavior"
			InitialValue="&c0A84FF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Title"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
