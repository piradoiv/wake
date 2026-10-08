#tag Class
Protected Class WakeSearchQuery
	#tag Method, Flags = &h0
		Sub Constructor(text As String = "")
		  // What to search for and where. Empty AgentID and Kinds, ProjectID 0 and Nil times mean no
		  // filter. Kinds are WakeEvent.KindName values. Times compare against the event, or against
		  // the start of its session when the event has no timestamp. ToTime is exclusive.
		  Self.Text = text
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MatchExpression() As String
		  // Text as an FTS5 query that every input can be given safely. Words match as prefixes, so
		  // "pars" finds "parse", and "double-quoted text" matches as an exact phrase. Every term is
		  // quoted, so operators such as OR, NOT and * are searched as words. All terms must match.
		  Var terms() As String
		  Var current As String
		  Var inPhrase As Boolean

		  For i As Integer = 0 To Text.Length - 1
		    Var c As String = Text.Middle(i, 1)

		    If c = """" Then
		      If inPhrase Then
		        If current.Trim <> "" Then terms.Add(Quoted(current))
		      Else
		        If current <> "" Then terms.Add(Quoted(current) + "*")
		      End If
		      current = ""
		      inPhrase = Not inPhrase
		    ElseIf Not inPhrase And (c = " " Or c = &u09 Or c = &u0A Or c = &u0D) Then
		      If current <> "" Then terms.Add(Quoted(current) + "*")
		      current = ""
		    Else
		      current = current + c
		    End If
		  Next

		  // An unclosed quote runs to the end of the text.
		  If inPhrase Then
		    If current.Trim <> "" Then terms.Add(Quoted(current))
		  ElseIf current <> "" Then
		    terms.Add(Quoted(current) + "*")
		  End If

		  Return String.FromArray(terms, " ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Quoted(term As String) As String
		  // Terms never contain a double quote, because MatchExpression splits on them.
		  Return """" + term + """"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FromTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		IncludeCommandOnly As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Kinds() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Limit As Integer = 500
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Text As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ToTime As DateTime
	#tag EndProperty


End Class
#tag EndClass
