#tag Class
Protected Class WakeBlame
	#tag Method, Flags = &h0
		Sub AddChange(patch As String, action As String)
		  // Adds a change's patch, oldest change first. Its removed lines cancel lines that earlier
		  // changes added, and its added lines become candidates for the blame. A create, or a write
		  // with no hunks, replaced the whole file.
		  Var change As Integer = mChangeCount
		  mChangeCount = mChangeCount + 1

		  Var patchLines() As String
		  If patch <> "" Then patchLines = patch.Split(&u0A)
		  Var hasHunks As Boolean
		  For Each patchLine As String In patchLines
		    If patchLine.BeginsWith("@@") Then
		      hasHunks = True
		      Exit
		    End If
		  Next

		  Var wholeFile As Boolean = action = WakeEvent.kChangeCreate Or (action = WakeEvent.kChangeWrite And Not hasHunks)
		  If wholeFile Then
		    For i As Integer = 0 To mEntryLive.LastIndex
		      mEntryLive(i) = False
		    Next
		  End If

		  Var removed(), added() As String
		  Var removedAt(), addedAt() As Integer
		  If hasHunks Then
		    // Hunks give each line its position, in the old file for removed lines and the new one for
		    // added lines.
		    Var oldLine, newLine As Integer
		    For Each patchLine As String In patchLines
		      If patchLine.BeginsWith("@@") Then
		        oldLine = HunkStart(patchLine, "-")
		        newLine = HunkStart(patchLine, "+")
		        Continue
		      End If
		      Select Case patchLine.Left(1)
		      Case "+"
		        added.Add(patchLine.Middle(1))
		        addedAt.Add(newLine)
		        newLine = newLine + 1
		      Case "-"
		        removed.Add(patchLine.Middle(1))
		        removedAt.Add(oldLine)
		        oldLine = oldLine + 1
		      Case " "
		        oldLine = oldLine + 1
		        newLine = newLine + 1
		      End Select
		    Next
		  Else
		    // A patch made from the tool input has no positions, unless it is the whole file, and each
		    // edit is its old lines and then its new ones, with the lines they share left in.
		    Var dels(), adds() As String
		    For Each patchLine As String In patchLines
		      Var marker As String = patchLine.Left(1)
		      If marker = "-" And adds.Count > 0 Then
		        AddSection(dels, adds, removed, added)
		        dels.RemoveAll
		        adds.RemoveAll
		      End If
		      If marker = "-" Then
		        dels.Add(patchLine.Middle(1))
		      ElseIf marker = "+" Then
		        adds.Add(patchLine.Middle(1))
		      End If
		    Next
		    AddSection(dels, adds, removed, added)
		    For i As Integer = 0 To removed.LastIndex
		      removedAt.Add(-1)
		    Next
		    For i As Integer = 0 To added.LastIndex
		      addedAt.Add(If(wholeFile, i + 1, -1))
		    Next
		  End If

		  For i As Integer = 0 To removed.LastIndex
		    Cancel(removed(i), removedAt(i))
		  Next

		  For i As Integer = 0 To added.LastIndex
		    Var entry As Integer = mEntryText.Count
		    mEntryChange.Add(change)
		    mEntryText.Add(added(i))
		    mEntryPosition.Add(addedAt(i))
		    mEntryLive.Add(True)
		    If mByText.HasKey(added(i)) Then
		      Var entries() As Integer = mByText.Value(added(i))
		      entries.Add(entry)
		    Else
		      Var entries() As Integer
		      entries.Add(entry)
		      mByText.Value(added(i)) = entries
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub AddSection(dels() As String, adds() As String, removed() As String, added() As String)
		  // Adds one edit's old and new lines without the lines both start or end with, which the edit
		  // only repeated.
		  Var first As Integer
		  While first < dels.Count And first < adds.Count
		    If dels(first).Compare(adds(first), ComparisonOptions.CaseSensitive) <> 0 Then Exit
		    first = first + 1
		  Wend

		  Var lastDel As Integer = dels.LastIndex
		  Var lastAdd As Integer = adds.LastIndex
		  While lastDel >= first And lastAdd >= first
		    If dels(lastDel).Compare(adds(lastAdd), ComparisonOptions.CaseSensitive) <> 0 Then Exit
		    lastDel = lastDel - 1
		    lastAdd = lastAdd - 1
		  Wend

		  For i As Integer = first To lastDel
		    removed.Add(dels(i))
		  Next
		  For i As Integer = first To lastAdd
		    added.Add(adds(i))
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Blame(text As String) As Integer()
		  // For each line of text, the change (in the order they were added) whose added lines produce
		  // it, or -1. The latest change claims first. Each added line accounts for one line of text
		  // with the same content, the one nearest its position. It's a heuristic: transcripts hold
		  // patches, not the file, so moved, repeated or retyped lines can be credited wrongly.
		  Var fileLines() As String = Lines(text)
		  Var owners() As Integer
		  Var unclaimed As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  For i As Integer = 0 To fileLines.LastIndex
		    owners.Add(-1)
		    If unclaimed.HasKey(fileLines(i)) Then
		      Var positions() As Integer = unclaimed.Value(fileLines(i))
		      positions.Add(i)
		    Else
		      Var positions() As Integer
		      positions.Add(i)
		      unclaimed.Value(fileLines(i)) = positions
		    End If
		  Next

		  // Entries were added in change order, so going backwards takes the latest change first.
		  For entry As Integer = mEntryText.LastIndex DownTo 0
		    If Not mEntryLive(entry) Or Not unclaimed.HasKey(mEntryText(entry)) Then Continue
		    Var positions() As Integer = unclaimed.Value(mEntryText(entry))
		    If positions.Count = 0 Then Continue

		    Var best As Integer
		    If mEntryPosition(entry) > 0 Then
		      For i As Integer = 1 To positions.LastIndex
		        If Abs(positions(i) + 1 - mEntryPosition(entry)) < Abs(positions(best) + 1 - mEntryPosition(entry)) Then best = i
		      Next
		    End If
		    owners(positions(best)) = mEntryChange(entry)
		    positions.RemoveAt(best)
		  Next

		  Return owners
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Cancel(text As String, position As Integer)
		  // A removed line takes back a line an earlier change added with the same content: the one
		  // nearest its position, or the latest when positions are unknown or as near.
		  If Not mByText.HasKey(text) Then Return
		  Var entries() As Integer = mByText.Value(text)

		  Var best As Integer = -1
		  For i As Integer = entries.LastIndex DownTo 0
		    Var entry As Integer = entries(i)
		    If Not mEntryLive(entry) Then Continue
		    If best < 0 Then
		      best = entry
		      If position <= 0 Then Exit
		    ElseIf mEntryPosition(entry) > 0 And Abs(mEntryPosition(entry) - position) < Abs(mEntryPosition(best) - position) Then
		      best = entry
		    End If
		  Next

		  If best >= 0 Then mEntryLive(best) = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChangeCount() As Integer
		  Return mChangeCount
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mByText = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function HunkStart(header As String, marker As String) As Integer
		  // The first line of a hunk header such as "@@ -12,3 +12,4 @@", on the side marker names.
		  For Each word As String In header.Split(" ")
		    If word.BeginsWith(marker) And word.Length > 1 Then
		      Var start As Integer = Val(word.Middle(1).NthField(",", 1))
		      Return start
		    End If
		  Next
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Lines(text As String) As String()
		  // The lines of a text, without the empty line after a final line break.
		  Var result() As String
		  If text = "" Then Return result

		  Var normalized As String = text.ReplaceLineEndings(&u0A)
		  If normalized.EndsWith(&u0A) Then normalized = normalized.Left(normalized.Length - 1)
		  Return normalized.Split(&u0A)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mByText As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChangeCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEntryChange() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEntryLive() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEntryPosition() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEntryText() As String
	#tag EndProperty


End Class
#tag EndClass
