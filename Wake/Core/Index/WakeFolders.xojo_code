#tag Module
Protected Module WakeFolders
	#tag Method, Flags = &h0
		Function AllRoots() As WakeIndexRoot()
		  // The default roots of every agent, then the folders the user added.
		  Var roots() As WakeIndexRoot = DefaultRoots

		  For Each root As WakeIndexRoot In LoadCustomRoots(CustomRootsFile)
		    roots.Add(root)
		  Next

		  Return roots
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AppDataFolder() As FolderItem
		  // Wake's own folder for the index and settings, created when missing. Transcripts are
		  // never stored here. Child() of a missing folder returns Nil, so it has to exist first.
		  Var folder As FolderItem = SpecialFolder.ApplicationData.Child("Wake")

		  Try
		    If folder <> Nil And Not folder.Exists Then folder.CreateFolder
		  Catch err As IOException
		    System.DebugLog("Wake: could not create " + folder.NativePath + ": " + err.Message)
		  End Try

		  Return folder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomRootsFile() As FolderItem
		  Return AppDataFolder.Child("folders.json")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DefaultIndexFile() As FolderItem
		  Return AppDataFolder.Child("index.sqlite")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DefaultRoots() As WakeIndexRoot()
		  Var roots() As WakeIndexRoot

		  For Each parser As IAgentParser In AgentRegistry.Parsers
		    For Each folder As FolderItem In parser.DefaultRoots
		      roots.Add(New WakeIndexRoot(parser.AgentID, folder))
		    Next
		  Next

		  Return roots
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadCustomRoots(f As FolderItem) As WakeIndexRoot()
		  // Reads [{"agent": "...", "path": "..."}]. A missing or unreadable file means no custom
		  // folders; entries that don't make sense are skipped.
		  Var roots() As WakeIndexRoot
		  If f Is Nil Or Not f.Exists Then Return roots

		  Try
		    Var input As TextInputStream = TextInputStream.Open(f)
		    input.Encoding = Encodings.UTF8
		    Var json As String = input.ReadAll
		    input.Close

		    Var entries As Variant = ParseJSON(json)
		    If Not entries.IsArray Then Return roots

		    Var items() As Variant = entries
		    For Each item As Variant In items
		      Var d As Dictionary = WakeCore.AsDictionary(item)
		      Var agentID As String = WakeCore.JSONString(d, "agent")
		      Var path As String = WakeCore.JSONString(d, "path")
		      If agentID = "" Or path = "" Then Continue

		      Try
		        roots.Add(New WakeIndexRoot(agentID, New FolderItem(path, FolderItem.PathModes.Native), True))
		      Catch err As UnsupportedFormatException
		        // Not a valid path on this system.
		      End Try
		    Next
		  Catch err As IOException
		  Catch err As JSONException
		  Catch err As TypeMismatchException
		  End Try

		  Return roots
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PricesFile() As FolderItem
		  // The user's price table. Wake ships no prices, so it only exists once the user sets one.
		  Return AppDataFolder.Child("prices.json")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveCustomRoots(f As FolderItem, roots() As WakeIndexRoot)
		  // Writes only custom roots. Raises IOException when the file can't be written.
		  Var items() As Variant

		  For Each root As WakeIndexRoot In roots
		    If Not root.IsCustom Or root.Folder Is Nil Then Continue

		    Var d As New Dictionary
		    d.Value("agent") = root.AgentID
		    d.Value("path") = root.Folder.NativePath
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


End Module
#tag EndModule
