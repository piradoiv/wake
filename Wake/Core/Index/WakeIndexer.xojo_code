#tag Class
Protected Class WakeIndexer
	#tag Method, Flags = &h0
		Sub AddRoot(root As WakeIndexRoot)
		  If root <> Nil Then mRoots.Add(root)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Cancel()
		  // Safe to call from another thread. The run stops after the current file.
		  mCancelRequested = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(index As WakeIndex)
		  mIndex = index
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindSessionFiles(parsers As Dictionary) As FolderItem()
		  // Every session file under the roots, once each even when roots overlap. parsers is
		  // filled with path -> IAgentParser.
		  Var files() As FolderItem

		  For Each root As WakeIndexRoot In mRoots
		    Var parser As IAgentParser = AgentRegistry.ParserFor(root.AgentID)
		    If parser Is Nil Or root.Folder Is Nil Then Continue

		    For Each f As FolderItem In parser.SessionFiles(root.Folder)
		      Var path As String = f.NativePath
		      If parsers.HasKey(path) Then Continue
		      parsers.Value(path) = parser
		      files.Add(f)
		    Next
		  Next

		  Return files
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ModifiedMs(f As FolderItem) As Int64
		  Var modified As DateTime = f.ModificationDateTime
		  If modified Is Nil Then Return 0
		  Return Round(modified.SecondsFrom1970 * 1000)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RelatedSignature(parser As IAgentParser, f As FolderItem) As String
		  // A fingerprint of the side files parsed with a session (e.g. subagent transcripts).
		  Var entries() As String

		  For Each related As FolderItem In parser.RelatedFiles(f)
		    entries.Add(related.Name + ":" + related.Length.ToString + ":" + ModifiedMs(related).ToString)
		  Next

		  entries.Sort
		  Return String.FromArray(entries, ";")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As WakeIndexRunResult
		  // Brings the index in line with the files under the roots: new and changed files are
		  // parsed and stored, unchanged ones are skipped and vanished ones are removed.
		  // Raises DatabaseException only if the index itself can't be read.
		  Var result As New WakeIndexRunResult

		  Var parsers As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  Var files() As FolderItem = FindSessionFiles(parsers)
		  Var known As Dictionary = mIndex.IndexedFiles
		  result.FilesFound = files.Count

		  // Remove first, so deleted sessions disappear before the slow part starts.
		  For Each path As Variant In known.Keys
		    If parsers.HasKey(path.StringValue) Then Continue

		    Try
		      mIndex.RemoveFile(WakeIndexedFile(known.Value(path).ObjectValue).ID)
		      result.FilesRemoved = result.FilesRemoved + 1
		    Catch err As DatabaseException
		      result.Errors.Add(path.StringValue + ": " + err.Message)
		    End Try
		  Next

		  For i As Integer = 0 To files.LastIndex
		    If mCancelRequested Then
		      result.Cancelled = True
		      Exit
		    End If

		    Var f As FolderItem = files(i)
		    RaiseEvent Progress(i, files.Count, f.NativePath)

		    Var previous As WakeIndexedFile = Nil
		    If known.HasKey(f.NativePath) Then previous = WakeIndexedFile(known.Value(f.NativePath).ObjectValue)

		    Select Case UpdateFile(f, IAgentParser(parsers.Value(f.NativePath).ObjectValue), previous, result)
		    Case kIndexed
		      result.FilesIndexed = result.FilesIndexed + 1
		    Case kSkipped
		      result.FilesSkipped = result.FilesSkipped + 1
		    Else
		      result.FilesFailed = result.FilesFailed + 1
		    End Select
		  Next

		  Try
		    mIndex.TidyProjects
		  Catch err As DatabaseException
		    result.Errors.Add("tidying projects: " + err.Message)
		  End Try

		  RaiseEvent Progress(files.Count, files.Count, "")
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UpdateFile(f As FolderItem, parser As IAgentParser, previous As WakeIndexedFile, result As WakeIndexRunResult) As Integer
		  // Returns kIndexed, kSkipped or kFailed. Errors are added to result.
		  Try
		    Var sizeBytes As Int64 = f.Length
		    Var modified As Int64 = ModifiedMs(f)
		    Var related As String = RelatedSignature(parser, f)

		    If previous <> Nil And previous.Size = sizeBytes And previous.ModifiedMs = modified And _
		      previous.RelatedSignature = related Then
		      Return kSkipped
		    End If

		    Var session As WakeSession = parser.ParseSession(f)
		    mIndex.StoreSession(f, sizeBytes, modified, related, session)
		    Return kIndexed
		  Catch err As IOException
		    result.Errors.Add(f.NativePath + ": " + err.Message)
		  Catch err As DatabaseException
		    result.Errors.Add(f.NativePath + ": " + err.Message)
		  Catch err As RuntimeException
		    // A parser bug must not stop the whole run.
		    If err IsA EndException Or err IsA ThreadEndException Then Raise err
		    result.Errors.Add(f.NativePath + ": " + Introspection.GetType(err).Name + " " + err.Message)
		  End Try

		  Return kFailed
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Progress(done As Integer, total As Integer, currentPath As String)
	#tag EndHook


	#tag Property, Flags = &h21
		Private mCancelRequested As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRoots() As WakeIndexRoot
	#tag EndProperty


	#tag Constant, Name = kFailed, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIndexed, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSkipped, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
