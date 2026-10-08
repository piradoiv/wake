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
		Function Bytes(amount As Int64) As String
		  // File size in decimal units: "512 bytes", "2.0 KB", "14 MB".
		  If amount < 1000 Then Return amount.ToString + If(amount = 1, " byte", " bytes")

		  Var value As Double = amount / 1000
		  Var suffix As String = " KB"
		  If value >= 999.95 Then
		    value = value / 1000
		    suffix = " MB"
		  End If
		  If value >= 999.95 Then
		    value = value / 1000
		    suffix = " GB"
		  End If

		  If value >= 100 Then Return value.ToString(Locale.Raw, "0") + suffix
		  Return value.ToString(Locale.Raw, "0.0") + suffix
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Cost(estimate As WakeCostEstimate) As String
		  // "$1.23"; "≥ $1.23" when some models have no price; "no price set" when none has one;
		  // an em dash when no tokens were used.
		  If estimate Is Nil Or Not estimate.HasTokens Then Return kUnknown
		  If estimate.PricedTokens = 0 Then Return kNoPrice
		  If Not estimate.IsComplete Then Return "≥ " + USD(estimate.AmountUSD)
		  Return USD(estimate.AmountUSD)
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
		Function Percent(part As Double, whole As Double) As String
		  // A whole percentage: "95%", "<1%" for a small share that isn't zero, and an em dash when
		  // there is nothing to take a share of.
		  If whole <= 0 Then Return kUnknown
		  Var share As Double = part / whole * 100
		  If share > 0 And share < 0.5 Then Return "<1%"
		  Return Round(share).ToString(Locale.Raw, "0") + "%"
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

	#tag Method, Flags = &h0
		Function USD(amount As Double) As String
		  // Dollars with cents and the user's separators: "$0.42", "$1,234.50". Amounts that
		  // round to zero but aren't zero show as "<$0.01".
		  If amount > 0 And amount < 0.005 Then Return "<$0.01"
		  Return "$" + amount.ToString(Locale.Current, "#,##0.00")
		End Function
	#tag EndMethod


	#tag Constant, Name = kEllipsis, Type = String, Dynamic = False, Default = \"…", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNoPrice, Type = String, Dynamic = False, Default = \"no price set", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kUnknown, Type = String, Dynamic = False, Default = \"—", Scope = Public
	#tag EndConstant


End Module
#tag EndModule
