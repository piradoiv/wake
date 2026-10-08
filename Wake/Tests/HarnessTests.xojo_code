#tag Class
Protected Class HarnessTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub FixturesFolderFoundTest()
		  Var f As FolderItem = TestSupport.FixturesFolder("claude-code")
		  Assert.IsNotNil(f, "tests/fixtures/claude-code should be found from the debug executable")
		  If f Is Nil Then Return
		  
		  Assert.IsTrue(f.Child("projects").Child("-Users-dev-demo").Exists, "fixture project folder exists")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseFixtureLineTest()
		  Var f As FolderItem = TestSupport.FixturesFolder("claude-code")
		  If f Is Nil Then
		    Assert.Fail("fixtures folder not found")
		    Return
		  End If
		  
		  f = f.Child("projects").Child("-Users-dev-demo").Child("00000000-0000-4000-8000-000000000001.jsonl")
		  
		  Var line As String
		  Try
		    Var input As TextInputStream = TextInputStream.Open(f)
		    input.Encoding = Encodings.UTF8
		    line = input.ReadLine
		    input.Close
		  Catch err As IOException
		    Assert.Fail("could not read fixture: " + err.Message)
		    Return
		  End Try
		  
		  Var record As Dictionary = ParseJSON(line)
		  Assert.AreEqual("permission-mode", record.Lookup("type", "").StringValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SQLiteFTS5AvailableTest()
		  // Spike: the index relies on FTS5 for full-text search.
		  Var db As New SQLiteDatabase
		  
		  Try
		    db.Connect
		    
		    Var version As RowSet = db.SelectSQL("SELECT sqlite_version() AS v")
		    Assert.Message("SQLite version " + version.Column("v").StringValue)
		    
		    db.ExecuteSQL("CREATE VIRTUAL TABLE docs USING fts5(body)")
		    db.ExecuteSQL("INSERT INTO docs (body) VALUES (?)", "the agent ran make test")
		    db.ExecuteSQL("INSERT INTO docs (body) VALUES (?)", "the agent edited main.c")
		    
		    Var rs As RowSet = db.SelectSQL("SELECT count(*) AS n FROM docs WHERE docs MATCH ?", "make")
		    Assert.AreEqual(1, rs.Column("n").IntegerValue, "FTS5 MATCH finds one row")
		  Catch err As DatabaseException
		    Assert.Fail("FTS5 not available: " + err.Message)
		  End Try
		End Sub
	#tag EndMethod


End Class
#tag EndClass
