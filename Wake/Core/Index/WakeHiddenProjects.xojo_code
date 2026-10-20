#tag Class
Protected Class WakeHiddenProjects
	#tag Method, Flags = &h0
		Sub Constructor()
		  // Projects the user hid from the browser, by agent and path, because index ids change
		  // whenever the index is rebuilt.
		  mEntries = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Contains(agentID As String, path As String) As Boolean
		  Return mEntries.HasKey(Key(agentID, path))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count() As Integer
		  Return mEntries.KeyCount
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Hide(agentID As String, path As String)
		  mEntries.Value(Key(agentID, path)) = agentID : path
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Key(agentID As String, path As String) As String
		  Return agentID + &u0A + path
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Load(f As FolderItem) As WakeHiddenProjects
		  // Reads [{"agent": "...", "path": "..."}]. A missing or unreadable file means nothing is
		  // hidden; entries that don't make sense are skipped.
		  Var result As New WakeHiddenProjects
		  If f Is Nil Or Not f.Exists Then Return result

		  Try
		    Var input As TextInputStream = TextInputStream.Open(f)
		    input.Encoding = Encodings.UTF8
		    Var json As String = input.ReadAll
		    input.Close

		    Var entries As Variant = ParseJSON(json)
		    If Not entries.IsArray Then Return result

		    Var items() As Variant = entries
		    For Each item As Variant In items
		      Var d As Dictionary = WakeCore.AsDictionary(item)
		      Var agentID As String = WakeCore.JSONString(d, "agent")
		      Var path As String = WakeCore.JSONString(d, "path")
		      If agentID <> "" And path <> "" Then result.Hide(agentID, path)
		    Next
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
		  Var items() As Variant
		  For Each entry As Variant In mEntries.Values
		    Var p As Pair = entry
		    Var d As New Dictionary
		    d.Value("agent") = p.Left
		    d.Value("path") = p.Right
		    items.Add(d)
		  Next

		  Var folder As FolderItem = f.Parent
		  If folder <> Nil And Not folder.Exists Then folder.CreateFolder

		  Var output As TextOutputStream = TextOutputStream.Create(f)
		  output.Encoding = Encodings.UTF8
		  output.Write(GenerateJSON(items, True))
		  output.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Unhide(agentID As String, path As String)
		  If mEntries.HasKey(Key(agentID, path)) Then mEntries.Remove(Key(agentID, path))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mEntries As Dictionary
	#tag EndProperty


End Class
#tag EndClass
