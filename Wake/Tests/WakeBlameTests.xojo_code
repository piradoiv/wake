#tag Class
Protected Class WakeBlameTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CaseTest()
		  // Lines match by their exact text, case included.
		  Var blame As New WakeBlame
		  blame.AddChange(Patch("+Return x"), WakeEvent.kChangeCreate)
		  Assert.AreEqual("- 0", Owners(blame, "return x" + &u0A + "Return x"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EditWithoutHunksTest()
		  // A patch made from the tool input repeats the lines the edit kept. They stay with the
		  // change that added them.
		  Var blame As New WakeBlame
		  blame.AddChange(Patch("+def f():", "+    return 1"), WakeEvent.kChangeCreate)
		  blame.AddChange(Patch("-def f():", "-    return 1", "+def f():", "+    return 2"), WakeEvent.kChangeEdit)
		  Assert.AreEqual("0 1", Owners(blame, "def f():" + &u0A + "    return 2" + &u0A))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EmptyTest()
		  // No changes, or no text, leave nothing to credit.
		  Var blame As New WakeBlame
		  Assert.AreEqual("- -", Owners(blame, "a" + &u0A + "b"))
		  blame.AddChange(Patch("+a"), WakeEvent.kChangeCreate)
		  Assert.AreEqual("", Owners(blame, ""))
		  Var count As Integer = WakeBlame.Lines("a" + &u0D + &u0A + "b" + &u0D + &u0A).Count
		  Assert.AreEqual(2, count, "line endings are normalized, and the last break ends a line")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MovedLinesTest()
		  // A line that moved is still credited to the change that added it, and a later change that
		  // moved it takes it over.
		  Var blame As New WakeBlame
		  blame.AddChange(Patch("+a", "+b", "+c"), WakeEvent.kChangeCreate)
		  Var moved As String = "c" + &u0A + "a" + &u0A + "b"
		  Assert.AreEqual("0 0 0", Owners(blame, moved), "moved by hand")

		  blame.AddChange(Patch("@@ -1,3 +1,3 @@", "+c", " a", " b", "-c"), WakeEvent.kChangeEdit)
		  Assert.AreEqual("1 0 0", Owners(blame, moved), "moved by an edit")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OverwrittenEditsTest()
		  // A line a later edit removed no longer counts for the change that added it, and a write of
		  // the whole file replaces everything before it.
		  Var blame As New WakeBlame
		  blame.AddChange(Patch("+a = 1", "+b = 2"), WakeEvent.kChangeCreate)
		  blame.AddChange(Patch("@@ -1,2 +1,2 @@", "-a = 1", "+a = 3", " b = 2"), WakeEvent.kChangeEdit)
		  Assert.AreEqual("1 0", Owners(blame, "a = 3" + &u0A + "b = 2"))
		  Assert.AreEqual("- 0", Owners(blame, "a = 1" + &u0A + "b = 2"), "put back by hand")

		  blame.AddChange(Patch("+b = 2"), WakeEvent.kChangeWrite)
		  Assert.AreEqual("- 2", Owners(blame, "a = 3" + &u0A + "b = 2"))

		  blame.AddChange(Patch("@@ -1,1 +1,2 @@", " b = 2", "+c = 4"), WakeEvent.kChangeWrite)
		  Assert.AreEqual("2 3", Owners(blame, "b = 2" + &u0A + "c = 4"), "a write with hunks keeps the lines it didn't touch")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Owners(blame As WakeBlame, text As String) As String
		  // The blame of text as "0 1 -": each line's change, or "-" for none.
		  Var words() As String
		  For Each owner As Integer In blame.Blame(text)
		    words.Add(If(owner < 0, "-", owner.ToString))
		  Next
		  Return String.FromArray(words, " ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Patch(ParamArray patchLines() As String) As String
		  Return String.FromArray(patchLines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RepeatedLinesTest()
		  // Each added line accounts for one line of the file, the nearest with its text, so a
		  // repeated line typed by hand is left over.
		  Var blame As New WakeBlame
		  blame.AddChange(Patch("+x {", "+}", "+y {", "+}"), WakeEvent.kChangeCreate)
		  blame.AddChange(Patch("@@ -4,1 +4,3 @@", " }", "+z {", "+}"), WakeEvent.kChangeEdit)

		  Var text As String = String.FromArray(Array("x {", "}", "y {", "}", "z {", "}", "}"), &u0A)
		  Assert.AreEqual("0 0 0 0 1 1 -", Owners(blame, text))
		End Sub
	#tag EndMethod


End Class
#tag EndClass
