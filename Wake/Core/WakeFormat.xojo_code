#tag Module
Protected Module WakeFormat
	#tag Method, Flags = &h0
		Function Duration(seconds As Double) As String
		  // "45s", "12m", "3h 05m" or "2d 4h". Negative means unknown and gives an em dash.
		  If seconds < 0 Then Return kUnknown

		  Var total As Integer = Round(seconds)
		  If total < 60 Then Return total.ToString + "s"

		  Var minutes As Integer = total \ 60
		  If minutes < 60 Then Return minutes.ToString + "m"

		  Var hours As Integer = minutes \ 60
		  If hours < 24 Then
		    Var restMinutes As Integer = minutes Mod 60
		    Return hours.ToString + "h " + restMinutes.ToString(Locale.Raw, "00") + "m"
		  End If

		  Var days As Integer = hours \ 24
		  Var restHours As Integer = hours Mod 24
		  Return days.ToString + "d " + restHours.ToString + "h"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(value As Int64) As String
		  // Whole number with thousands separators from the user's locale.
		  Return value.ToString(Locale.Current, "#,##0")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OneLine(text As String, maxLength As Integer) As String
		  // Collapses whitespace runs, line breaks included, and cuts to maxLength with an ellipsis.
		  Var words() As String = text.ReplaceAll(&u0D, " ").ReplaceAll(&u0A, " ").ReplaceAll(&u09, " ").Split(" ")
		  Var kept() As String
		  For Each word As String In words
		    If word <> "" Then kept.Add(word)
		  Next

		  Var result As String = String.FromArray(kept, " ")
		  If maxLength > 1 And result.Length > maxLength Then result = result.Left(maxLength - 1) + kEllipsis
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ProjectName(path As String) As String
		  // The last component of a project path: "/Users/dev/demo" gives "demo".
		  Var parts() As String = path.ReplaceAll("\", "/").Split("/")
		  For i As Integer = parts.LastIndex DownTo 0
		    If parts(i) <> "" Then Return parts(i)
		  Next
		  Return path
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Tokens(amount As Int64) As String
		  // Compact token count: "950", "12.3K", "4.5M", "1.2B".
		  If amount < 1000 Then Return amount.ToString

		  Var value As Double = amount
		  Var suffix As String = "K"
		  value = value / 1000
		  If value >= 999.95 Then
		    value = value / 1000
		    suffix = "M"
		  End If
		  If value >= 999.95 Then
		    value = value / 1000
		    suffix = "B"
		  End If

		  If value >= 100 Then Return value.ToString(Locale.Raw, "0") + suffix
		  Return value.ToString(Locale.Raw, "0.0") + suffix
		End Function
	#tag EndMethod


	#tag Constant, Name = kEllipsis, Type = String, Dynamic = False, Default = \"…", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kUnknown, Type = String, Dynamic = False, Default = \"—", Scope = Public
	#tag EndConstant


End Module
#tag EndModule
