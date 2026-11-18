#tag Class
Protected Class WakeCLIArgs
	#tag Method, Flags = &h0
		Sub Constructor(args() As String, flags() As String, valueOptions() As String)
		  // Splits a command line (without the program's name) into words and options: the names in
		  // flags take no value, and those in valueOptions take one, as --name value or --name=value.
		  // -h is --help, and a lone -- ends the options. Error is set at the first problem.
		  Options = WakeCore.NewCaseSensitiveDictionary
		  
		  Var endOfOptions As Boolean
		  Var i As Integer
		  While i <= args.LastIndex
		    Var word As String = args(i)
		    i = i + 1
		    
		    If endOfOptions Or Not word.BeginsWith("-") Or word = "-" Then
		      Words.Add(word)
		      Continue
		    End If
		    
		    If word = "--" Then
		      endOfOptions = True
		      Continue
		    End If
		    
		    If word = "-h" Then word = "--help"
		    If Not word.BeginsWith("--") Or word.Length < 3 Then
		      If Error = "" Then Error = "Unknown option " + word + "."
		      Continue
		    End If
		    
		    Var name As String = word.Middle(2)
		    Var value As String
		    Var hasValue As Boolean
		    Var equals As Integer = name.IndexOf("=")
		    If equals >= 0 Then
		      value = name.Middle(equals + 1)
		      name = name.Left(equals)
		      hasValue = True
		    End If
		    
		    If flags.IndexOf(name) >= 0 Then
		      If hasValue And Error = "" Then Error = "--" + name + " takes no value."
		      Options.Value(name) = "true"
		      Continue
		    End If
		    
		    If valueOptions.IndexOf(name) < 0 Then
		      If Error = "" Then Error = "Unknown option --" + name + "."
		      Continue
		    End If
		    
		    If Not hasValue Then
		      If i > args.LastIndex Then
		        If Error = "" Then Error = "--" + name + " needs a value."
		        Continue
		      End If
		      value = args(i)
		      i = i + 1
		    End If
		    Options.Value(name) = value
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(name As String) As Boolean
		  Return Options.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function IsNumber(text As String) As Boolean
		  // True when text is one or more ASCII digits.
		  If text = "" Then Return False
		  For Each character As String In text.Characters
		    If character < "0" Or character > "9" Then Return False
		  Next
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function Midnight(now As DateTime) As DateTime
		  Return New DateTime(now.Year, now.Month, now.Day, 0, 0, 0, 0, now.Timezone)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ParseAmount(text As String, ByRef amount As Integer, ByRef unit As String) As Boolean
		  // "7d", "4w", "3m" or "1y": a whole number from 1 to 9999 and a unit.
		  If text.Length < 2 Or text.Length > 5 Then Return False
		  unit = text.Right(1)
		  Var units As String = "dwmy"
		  If units.IndexOf(unit) < 0 Then Return False
		  
		  Var digits As String = text.Left(text.Length - 1)
		  If Not IsNumber(digits) Then Return False
		  amount = digits.ToInteger
		  Return amount >= 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ParseDate(text As String, zone As TimeZone, ByRef result As DateTime) As Boolean
		  // A calendar day as YYYY-MM-DD, at midnight in zone.
		  If text.Length <> 10 Or text.Middle(4, 1) <> "-" Or text.Middle(7, 1) <> "-" Then Return False
		  Var yearText As String = text.Left(4)
		  Var monthText As String = text.Middle(5, 2)
		  Var dayText As String = text.Middle(8, 2)
		  If Not IsNumber(yearText) Or Not IsNumber(monthText) Or Not IsNumber(dayText) Then Return False
		  
		  Var y As Integer = yearText.ToInteger
		  Var m As Integer = monthText.ToInteger
		  Var d As Integer = dayText.ToInteger
		  If y < 1970 Or m < 1 Or m > 12 Or d < 1 Or d > 31 Then Return False
		  
		  Try
		    Var day As New DateTime(y, m, d, 0, 0, 0, 0, zone)
		    // A day past the end of the month rolls over into the next one.
		    If day.Year <> y Or day.Month <> m Or day.Day <> d Then Return False
		    result = day
		    Return True
		  Catch err As InvalidArgumentException
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ParseEnd(text As String, now As DateTime, ByRef result As DateTime) As Boolean
		  // The end of a period, as the moment just after it: a date or "today" or "yesterday"
		  // includes that whole day, and "7d" ends where the last 7 days start.
		  Var t As String = text.Trim.Lowercase
		  Var today As DateTime = Midnight(now)
		  
		  Select Case t
		  Case "today"
		    result = today.AddInterval(0, 0, 1)
		    Return True
		  Case "yesterday"
		    result = today
		    Return True
		  End Select
		  
		  Var amount As Integer
		  Var unit As String
		  If ParseAmount(t, amount, unit) Then Return ParseStart(t, now, result)
		  
		  Var day As DateTime
		  If Not ParseDate(t, now.Timezone, day) Then Return False
		  result = day.AddInterval(0, 0, 1)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ParseStart(text As String, now As DateTime, ByRef result As DateTime) As Boolean
		  // The start of a period, at midnight in now's time zone: "today", "yesterday", "7d", "4w",
		  // "3m" or "1y" (each counting today as its last day), a date as YYYY-MM-DD, or "all", which
		  // sets result to Nil. False when text is none of those.
		  Var t As String = text.Trim.Lowercase
		  Var today As DateTime = Midnight(now)
		  
		  Select Case t
		  Case "all"
		    result = Nil
		    Return True
		  Case "today"
		    result = today
		    Return True
		  Case "yesterday"
		    result = today.SubtractInterval(0, 0, 1)
		    Return True
		  End Select
		  
		  Var amount As Integer
		  Var unit As String
		  If ParseAmount(t, amount, unit) Then
		    Select Case unit
		    Case "d"
		      result = today.SubtractInterval(0, 0, amount - 1)
		    Case "w"
		      result = today.SubtractInterval(0, 0, amount * 7 - 1)
		    Case "m"
		      result = today.SubtractInterval(0, amount, 0).AddInterval(0, 0, 1)
		    Case "y"
		      result = today.SubtractInterval(amount, 0, 0).AddInterval(0, 0, 1)
		    End Select
		    Return True
		  End If
		  
		  Return ParseDate(t, now.Timezone, result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(name As String, defaultValue As String = "") As String
		  Return Options.Lookup(name, defaultValue).StringValue
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Error As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Options As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Words() As String
	#tag EndProperty


End Class
#tag EndClass
