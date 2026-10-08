#tag Class
Protected Class WakeParseReport
	#tag Method, Flags = &h0
		Sub Constructor()
		  UnknownRecordTypes = WakeCore.NewCaseSensitiveDictionary
		  UnknownBlockTypes = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CountUnknownBlockType(name As String)
		  If name = "" Then name = "(missing)"
		  UnknownBlockTypes.Value(name) = UnknownBlockTypes.Lookup(name, 0).IntegerValue + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CountUnknownRecordType(name As String)
		  If name = "" Then name = "(missing)"
		  UnknownRecordTypes.Value(name) = UnknownRecordTypes.Lookup(name, 0).IntegerValue + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsPartial() As Boolean
		  // True when something in the file was skipped. The session is still shown, with a note.
		  Return FileError <> "" Or MalformedLines > 0 Or RecordErrors > 0 Or UnknownRecordCount > 0 Or UnknownBlockCount > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Summary() As String
		  // A short, human-readable note about what was skipped, or "" when nothing was.
		  Var parts() As String

		  If FileError <> "" Then parts.Add("file could not be read: " + FileError)
		  If MalformedLines > 0 Then parts.Add(MalformedLines.ToString + " malformed " + If(MalformedLines = 1, "line", "lines"))
		  If RecordErrors > 0 Then parts.Add(RecordErrors.ToString + " unreadable " + If(RecordErrors = 1, "record", "records"))

		  For Each name As Variant In UnknownRecordTypes.Keys
		    parts.Add(UnknownRecordTypes.Value(name).IntegerValue.ToString + " unknown """ + name.StringValue + """ records")
		  Next

		  For Each name As Variant In UnknownBlockTypes.Keys
		    parts.Add(UnknownBlockTypes.Value(name).IntegerValue.ToString + " unknown """ + name.StringValue + """ blocks")
		  Next

		  If parts.Count = 0 Then Return ""
		  Return "Skipped " + String.FromArray(parts, ", ") + "."
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnknownBlockCount() As Integer
		  Var total As Integer
		  For Each name As Variant In UnknownBlockTypes.Keys
		    total = total + UnknownBlockTypes.Value(name).IntegerValue
		  Next
		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnknownRecordCount() As Integer
		  Var total As Integer
		  For Each name As Variant In UnknownRecordTypes.Keys
		    total = total + UnknownRecordTypes.Value(name).IntegerValue
		  Next
		  Return total
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		BlankLines As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FileError As String
	#tag EndProperty

	#tag Property, Flags = &h0
		IgnoredRecords As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LinesRead As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MalformedLines As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		RecordErrors As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		RecordsParsed As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		UnknownBlockTypes As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		UnknownRecordTypes As Dictionary
	#tag EndProperty


End Class
#tag EndClass
