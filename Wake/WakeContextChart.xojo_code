#tag Class
Protected Class WakeContextChart
Inherits DesktopCanvas
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  // Pressing a point asks to show the turn it belongs to.
		  #Pragma Unused y
		  Var index As Integer = PointAt(x)
		  If index < 0 Or mTurnSequences(index) < 0 Then Return False
		  RaiseEvent TurnPressed(mTurnSequences(index))
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  If mHover < 0 Then Return
		  mHover = -1
		  Me.Tooltip = ""
		  Me.MouseCursor = Nil
		  Me.Refresh(False)
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(x As Integer, y As Integer)
		  // The response under the pointer is marked, its turn is shaded, and the tooltip says what
		  // the context held then.
		  #Pragma Unused y
		  Var index As Integer = PointAt(x)
		  If index = mHover Then Return
		  mHover = index
		  Me.Tooltip = If(index >= 0, mTips(index), "")
		  Me.MouseCursor = If(index >= 0 And mTurnSequences(index) >= 0, System.Cursors.FingerPointer, Nil)
		  Me.Refresh(False)
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  // The title and a summary on top, the context of each response as a filled curve, the
		  // starting context as a faint line, and a mark where the context was compacted.
		  #Pragma Unused areas
		  
		  Var dark As Boolean = Color.IsDarkMode
		  Var tint As Color = WakeGlanceTiles.kPurple
		  
		  g.FontSize = 11
		  g.Bold = True
		  g.DrawingColor = Color.TextColor
		  g.DrawText("Context", kPadding, kPadding + g.FontAscent)
		  If mSummary <> "" Then
		    g.Bold = False
		    g.DrawingColor = WakeGlanceTiles.SecondaryTextColor
		    g.DrawText(mSummary, g.Width - kPadding - g.TextWidth(mSummary), kPadding + g.FontAscent)
		  End If
		  
		  Var plotTop As Double = kPadding + 24
		  Var plotBottom As Double = g.Height - kPadding - 14
		  Var plotHeight As Double = plotBottom - plotTop
		  
		  g.DrawingColor = Color.RGB(128, 128, 128, 170)
		  g.DrawLine(kPadding, plotBottom + 0.5, g.Width - kPadding, plotBottom + 0.5)
		  If mValues.Count < 2 Or mMax <= 0 Then Return
		  
		  // The turn under the pointer is shaded behind the curve.
		  If mHover >= 0 Then
		    Var first As Integer = mHover
		    Var last As Integer = mHover
		    While first > 0 And mTurnNumbers(first - 1) = mTurnNumbers(mHover)
		      first = first - 1
		    Wend
		    While last < mValues.LastIndex And mTurnNumbers(last + 1) = mTurnNumbers(mHover)
		      last = last + 1
		    Wend
		    Var halfStep As Double = PointX(1) - PointX(0)
		    halfStep = halfStep / 2
		    Var bandLeft As Double = Max(kPadding, PointX(first) - halfStep)
		    Var bandRight As Double = Min(g.Width - kPadding, PointX(last) + halfStep)
		    g.DrawingColor = Color.RGB(128, 128, 128, If(dark, 200, 225))
		    g.FillRectangle(bandLeft, plotTop, bandRight - bandLeft, plotHeight)
		  End If
		  
		  Var area As New GraphicsPath
		  area.MoveToPoint(PointX(0), plotBottom)
		  For i As Integer = 0 To mValues.LastIndex
		    area.AddLineToPoint(PointX(i), PointY(i, plotTop, plotHeight))
		  Next
		  area.AddLineToPoint(PointX(mValues.LastIndex), plotBottom)
		  g.DrawingColor = Color.RGB(tint.Red, tint.Green, tint.Blue, If(dark, 150, 170))
		  g.FillPath(area)
		  
		  g.PenSize = 1.5
		  g.DrawingColor = tint
		  For i As Integer = 1 To mValues.LastIndex
		    g.DrawLine(PointX(i - 1), PointY(i - 1, plotTop, plotHeight), PointX(i), PointY(i, plotTop, plotHeight))
		  Next
		  g.PenSize = 1
		  
		  // What every response sends anyway: the system prompt and tools.
		  If mStarting > 0 Then
		    Var startY As Double = plotBottom - mStarting / mMax * plotHeight
		    g.DrawingColor = Color.RGB(128, 128, 128, 120)
		    g.DrawLine(kPadding, startY, g.Width - kPadding, startY)
		  End If
		  
		  For i As Integer = 0 To mValues.LastIndex
		    If Not mCompactions(i) Then Continue
		    g.DrawingColor = WakeGlanceTiles.kOrange
		    g.PenSize = 2
		    g.DrawLine(PointX(i), plotTop, PointX(i), plotBottom)
		    g.PenSize = 1
		  Next
		  
		  If mHover >= 0 Then
		    g.DrawingColor = If(dark, Color.White, WakeGlanceTiles.Shade(tint))
		    g.FillOval(PointX(mHover) - 3.5, PointY(mHover, plotTop, plotHeight) - 3.5, 7, 7)
		  End If
		  
		  g.FontSize = 10
		  g.DrawingColor = WakeGlanceTiles.SecondaryTextColor
		  Var labelBaseline As Double = g.Height - kPadding
		  Var firstLabel As String = "Turn 1"
		  Var lastLabel As String = "Turn " + mTurnNumbers(mValues.LastIndex).ToString
		  g.DrawText(firstLabel, kPadding, labelBaseline)
		  If mTurnNumbers(mValues.LastIndex) > 1 Then g.DrawText(lastLabel, g.Width - kPadding - g.TextWidth(lastLabel), labelBaseline)
		  Var peak As String = WakeFormat.Tokens(mMax)
		  g.DrawText(peak, kPadding + 2, plotTop + g.FontAscent)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function PointAt(x As Integer) As Integer
		  // The response nearest to x, or -1 off the curve.
		  If mValues.Count < 2 Then Return -1
		  Var stepWidth As Double = (Me.Width - kPadding * 2) / mValues.LastIndex
		  Var index As Integer = Round((x - kPadding) / stepWidth)
		  If index < 0 Or index > mValues.LastIndex Then Return -1
		  Return index
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PointX(index As Integer) As Double
		  Return kPadding + index * (Me.Width - kPadding * 2) / Max(1, mValues.LastIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PointY(index As Integer, plotTop As Double, plotHeight As Double) As Double
		  Return plotTop + plotHeight - mValues(index) / mMax * plotHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowSession(session As WakeSession)
		  // One point per response of the session itself, in order. Subagents have contexts of their
		  // own, so they aren't drawn. Call Refresh afterwards.
		  mValues.RemoveAll
		  mTurnSequences.RemoveAll
		  mTurnNumbers.RemoveAll
		  mCompactions.RemoveAll
		  mTips.RemoveAll
		  mMax = 0
		  mHover = -1
		  mSummary = ""
		  mStarting = 0
		  Me.Tooltip = ""
		  If session Is Nil Then Return
		  
		  mStarting = session.StartingContextTokens
		  Var turn, compactions, responseInTurn As Integer
		  Var lastSequence As Integer = -1
		  Var peak As Int64
		  
		  For Each response As WakeResponse In session.Responses
		    If response.TurnSequence <> lastSequence Then
		      lastSequence = response.TurnSequence
		      turn = turn + 1
		      responseInTurn = 0
		    End If
		    responseInTurn = responseInTurn + 1
		    
		    Var context As Int64 = response.ContextTokens
		    mValues.Add(context)
		    mTurnSequences.Add(response.TurnSequence)
		    mTurnNumbers.Add(turn)
		    mCompactions.Add(response.StartsNewContext)
		    If context > peak Then peak = context
		    If response.StartsNewContext Then compactions = compactions + 1
		    
		    Var tip As String = "Turn " + turn.ToString + ", response " + responseInTurn.ToString + ": " + _
		    WakeFormat.Count(context) + " tokens of context"
		    If response.StartsNewContext Then tip = tip + ". The context shrank here, so it was probably compacted"
		    If response.TurnSequence >= 0 Then
		      Var prompt As WakeEvent = session.Events(response.TurnSequence)
		      If prompt.TurnCarriedTokens > 0 Then
		        tip = tip + ". The turn paid about " + WakeFormat.Count(prompt.TurnCarriedTokens) + " tokens to re-send earlier turns"
		      End If
		      tip = tip + ". Click to show the turn."
		    End If
		    mTips.Add(tip)
		  Next
		  mMax = peak
		  
		  Var facts() As String
		  facts.Add("started at " + WakeFormat.Tokens(session.StartingContextTokens))
		  facts.Add("peak " + WakeFormat.Tokens(peak))
		  If session.CarriedTokens > 0 Then facts.Add("≈" + WakeFormat.Tokens(session.CarriedTokens) + " carried")
		  If compactions > 0 Then facts.Add(If(compactions = 1, "1 compaction", compactions.ToString + " compactions"))
		  mSummary = String.FromArray(facts, " · ")
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event TurnPressed(sequence As Integer)
	#tag EndHook


	#tag Property, Flags = &h21
		Private mCompactions() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHover As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMax As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStarting As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSummary As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTips() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTurnNumbers() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTurnSequences() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValues() As Double
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
	#tag EndViewBehavior
End Class
#tag EndClass
