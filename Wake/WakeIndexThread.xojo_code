#tag Class
Protected Class WakeIndexThread
Inherits Thread
	#tag Event
		Sub Run()
		  // Runs on a preemptive thread with its own connection. Nothing here touches the UI:
		  // progress goes through AddUserInterfaceUpdate and arrives in UserInterfaceUpdate.
		  Var index As New WakeIndex(IndexFile)

		  Try
		    index.Open
		  Catch err As DatabaseException
		    AddUserInterfaceUpdate("error" : "Could not open the index: " + err.Message)
		    Return
		  Catch err As IOException
		    AddUserInterfaceUpdate("error" : "Could not open the index: " + err.Message)
		    Return
		  End Try

		  Var indexer As New WakeIndexer(index)
		  For Each root As WakeIndexRoot In Roots
		    indexer.AddRoot(root)
		  Next

		  AddHandler indexer.Progress, AddressOf Indexer_Progress
		  mIndexer = indexer

		  Try
		    Var result As WakeIndexRunResult = indexer.Run
		    AddUserInterfaceUpdate("finished" : result)
		  Catch err As DatabaseException
		    AddUserInterfaceUpdate("error" : "Indexing failed: " + err.Message)
		  End Try

		  mIndexer = Nil
		  RemoveHandler indexer.Progress, AddressOf Indexer_Progress
		  index.Close
		End Sub
	#tag EndEvent

	#tag Event
		Sub UserInterfaceUpdate(data() As Dictionary)
		  For Each update As Dictionary In data
		    If update.HasKey("progress") Then
		      RaiseEvent Progress(update.Value("done").IntegerValue, update.Value("total").IntegerValue, update.Value("path").StringValue)
		    ElseIf update.HasKey("finished") Then
		      RaiseEvent Finished(WakeIndexRunResult(update.Value("finished").ObjectValue))
		    ElseIf update.HasKey("error") Then
		      RaiseEvent Failed(update.Value("error").StringValue)
		    End If
		  Next
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Cancel()
		  Var indexer As WakeIndexer = mIndexer
		  If indexer <> Nil Then indexer.Cancel
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(databaseFile As FolderItem, folders() As WakeIndexRoot)
		  // databaseFile Nil keeps the index in memory.
		  IndexFile = databaseFile
		  Roots = folders
		  Self.Type = Thread.Types.Preemptive

		  // The registry fills its parser list on first use. Do that here, on the main thread,
		  // rather than racing for it from the indexer thread.
		  Var parsers() As IAgentParser = AgentRegistry.Parsers
		  #Pragma Unused parsers
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Indexer_Progress(sender As WakeIndexer, done As Integer, total As Integer, currentPath As String)
		  #Pragma Unused sender
		  AddUserInterfaceUpdate("progress" : True, "done" : done, "total" : total, "path" : currentPath)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Failed(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Finished(result As WakeIndexRunResult)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Progress(done As Integer, total As Integer, currentPath As String)
	#tag EndHook


	#tag Property, Flags = &h0
		IndexFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndexer As WakeIndexer
	#tag EndProperty

	#tag Property, Flags = &h0
		Roots() As WakeIndexRoot
	#tag EndProperty


End Class
#tag EndClass
