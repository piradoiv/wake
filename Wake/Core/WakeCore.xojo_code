#tag Module
Protected Module WakeCore
	#tag Method, Flags = &h0
		Function AsDictionary(value As Variant) As Dictionary
		  // Returns value as a Dictionary, or Nil when it holds anything else.
		  If value.Type = Variant.TypeObject And value.ObjectValue IsA Dictionary Then
		    Return Dictionary(value.ObjectValue)
		  End If

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONArray(d As Dictionary, key As String) As Variant()
		  // The array stored under key, or an empty array when it is missing or not an array.
		  Var result() As Variant
		  If d Is Nil Then Return result

		  Var value As Variant = d.Lookup(key, Nil)
		  If value.IsArray Then
		    Try
		      result = value
		    Catch err As TypeMismatchException
		      // An array of a type other than Variant: treat it as missing.
		    End Try
		  End If

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONBoolean(d As Dictionary, key As String) As Boolean
		  If d Is Nil Then Return False

		  Var value As Variant = d.Lookup(key, Nil)
		  If value.Type = Variant.TypeBoolean Then Return value.BooleanValue

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONDictionary(d As Dictionary, key As String) As Dictionary
		  If d Is Nil Then Return Nil
		  Return AsDictionary(d.Lookup(key, Nil))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONDouble(d As Dictionary, key As String, defaultValue As Double = 0.0) As Double
		  If d Is Nil Then Return defaultValue

		  Var value As Variant = d.Lookup(key, Nil)
		  Select Case value.Type
		  Case Variant.TypeInt32, Variant.TypeInt64, Variant.TypeDouble, Variant.TypeSingle, Variant.TypeCurrency
		    Return value.DoubleValue
		  End Select

		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONInteger(d As Dictionary, key As String) As Int64
		  If d Is Nil Then Return 0

		  Var value As Variant = d.Lookup(key, Nil)
		  Select Case value.Type
		  Case Variant.TypeInt32, Variant.TypeInt64, Variant.TypeDouble, Variant.TypeSingle, Variant.TypeCurrency
		    Return value.Int64Value
		  End Select

		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONString(d As Dictionary, key As String, defaultValue As String = "") As String
		  If d Is Nil Then Return defaultValue

		  Var value As Variant = d.Lookup(key, Nil)
		  If value.Type = Variant.TypeString Then Return value.StringValue

		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewCaseSensitiveDictionary() As Dictionary
		  // A plain Dictionary compares String keys case-insensitively. Dictionaries created by
		  // ParseJSON are case-sensitive, which ids such as "toolu_aB" and "toolu_Ab" need.
		  Return ParseJSON("{}")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParseISO8601(value As String) As DateTime
		  // Parses "2026-09-01T10:00:00.123Z" or "2026-09-01T10:00:00+02:00".
		  // Returns Nil for anything it does not understand.
		  If value.Length < 19 Then Return Nil
		  If value.Middle(4, 1) <> "-" Or value.Middle(7, 1) <> "-" Then Return Nil
		  If value.Middle(10, 1) <> "T" And value.Middle(10, 1) <> " " Then Return Nil
		  If value.Middle(13, 1) <> ":" Or value.Middle(16, 1) <> ":" Then Return Nil

		  Var year As Integer = value.Middle(0, 4).ToInteger
		  Var month As Integer = value.Middle(5, 2).ToInteger
		  Var day As Integer = value.Middle(8, 2).ToInteger
		  Var hour As Integer = value.Middle(11, 2).ToInteger
		  Var minute As Integer = value.Middle(14, 2).ToInteger
		  Var second As Integer = value.Middle(17, 2).ToInteger

		  If year < 1970 Or month < 1 Or month > 12 Or day < 1 Or day > 31 Then Return Nil
		  If hour > 23 Or minute > 59 Or second > 60 Then Return Nil

		  Var pos As Integer = 19
		  Var nanoseconds As Integer = 0

		  If value.Middle(pos, 1) = "." Then
		    pos = pos + 1
		    Var digits As String
		    While pos < value.Length And IsDigit(value.Middle(pos, 1))
		      digits = digits + value.Middle(pos, 1)
		      pos = pos + 1
		    Wend
		    If digits.Length > 9 Then digits = digits.Left(9)
		    While digits.Length < 9
		      digits = digits + "0"
		    Wend
		    nanoseconds = digits.ToInteger
		  End If

		  Var offsetSeconds As Integer = 0
		  Var zone As String = value.Middle(pos)

		  If zone = "Z" Or zone = "" Then
		    offsetSeconds = 0
		  ElseIf zone.Length = 6 And (zone.Left(1) = "+" Or zone.Left(1) = "-") And zone.Middle(3, 1) = ":" Then
		    offsetSeconds = zone.Middle(1, 2).ToInteger * 3600 + zone.Middle(4, 2).ToInteger * 60
		    If zone.Left(1) = "-" Then offsetSeconds = -offsetSeconds
		  Else
		    Return Nil
		  End If

		  Try
		    Return New DateTime(year, month, day, hour, minute, second, nanoseconds, New TimeZone(offsetSeconds))
		  Catch err As InvalidArgumentException
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsDigit(character As String) As Boolean
		  Return character >= "0" And character <= "9" And character.Length = 1
		End Function
	#tag EndMethod


End Module
#tag EndModule
