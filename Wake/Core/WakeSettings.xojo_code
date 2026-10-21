#tag Class
Protected Class WakeSettings
	#tag Method, Flags = &h0
		Sub Constructor()
		  // Wake's own preferences. Keys this version doesn't know are kept, so saving never drops
		  // what a newer version wrote.
		  mValues = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Load(f As FolderItem) As WakeSettings
		  // Reads a JSON object. A missing or unreadable file, or a value of the wrong type, means
		  // the default.
		  Var result As New WakeSettings
		  If f Is Nil Or Not f.Exists Then Return result

		  Try
		    Var input As TextInputStream = TextInputStream.Open(f)
		    input.Encoding = Encodings.UTF8
		    Var json As String = input.ReadAll
		    input.Close

		    Var d As Dictionary = WakeCore.AsDictionary(ParseJSON(json))
		    If d Is Nil Then Return result
		    result.mValues = d

		    Var watch As Variant = d.Lookup(kWatchKey, Nil)
		    If watch.Type = Variant.TypeBoolean Then result.WatchForChanges = watch.BooleanValue
		  Catch err As IOException
		  Catch err As JSONException
		  Catch err As TypeMismatchException
		  End Try

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Save(f As FolderItem)
		  // Raises IOException when the file can't be written.
		  mValues.Value(kWatchKey) = WatchForChanges

		  Var folder As FolderItem = f.Parent
		  If folder <> Nil And Not folder.Exists Then folder.CreateFolder

		  Var output As TextOutputStream = TextOutputStream.Create(f)
		  output.Encoding = Encodings.UTF8
		  output.Write(GenerateJSON(mValues, True))
		  output.Close
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mValues As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		WatchForChanges As Boolean = True
	#tag EndProperty


	#tag Constant, Name = kWatchKey, Type = String, Dynamic = False, Default = \"watchForChanges", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
