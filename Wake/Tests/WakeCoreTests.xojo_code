#tag Class
Protected Class WakeCoreTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CaseSensitiveDictionaryTest()
		  Var d As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  d.Value("toolu_aB") = 1
		  d.Value("toolu_Ab") = 2

		  Assert.AreEqual(2, d.KeyCount, "keys differing only in case are distinct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompactionEndsReReadTest()
		  // A context that shrinks to less than half was compacted: what came before isn't read again.
		  Var s As New WakeSession
		  Var prompt As WakeEvent = s.AddEvent(WakeEvent.Kinds.UserPrompt, Nil)
		  prompt.Text = "go"
		  s.NoteInput(prompt, Nil)
		  Call s.AddResponse("m", NewUsage(10, 5, 1000, 0), Nil)

		  Var readCall As WakeEvent = s.AddEvent(WakeEvent.Kinds.ToolCall, Nil)
		  readCall.HasResult = True
		  readCall.ResultText = "contents"
		  s.NoteInput(readCall, Nil)
		  Call s.AddResponse("m", NewUsage(0, 5, 100, 1010), Nil)
		  Call s.AddResponse("m", NewUsage(0, 5, 0, 1110), Nil)
		  Call s.AddResponse("m", NewUsage(0, 5, 200, 0), Nil)
		  Call s.AddResponse("m", NewUsage(0, 5, 0, 200), Nil)
		  s.ComputeStats

		  Assert.AreEqual(95, readCall.AddedTokens, "1110 - 1010 - 5 of output")
		  Assert.AreEqual(95, readCall.CarriedTokens, "only the response before the compaction")
		  Assert.IsTrue(s.Responses(3).StartsNewContext)
		  Assert.AreEqual(95, readCall.AddedUsage.Total.CacheWriteTokens, "the response had no plain input")

		  s.ComputeStats
		  Assert.AreEqual(95, readCall.AddedTokens, "running it again changes nothing")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FormatSecondsTest()
		  Assert.AreEqual("0.4s", WakeFormat.Seconds(0.42))
		  Assert.AreEqual("9.9s", WakeFormat.Seconds(9.9))
		  Assert.AreEqual("12s", WakeFormat.Seconds(12.3))
		  Assert.AreEqual("2m", WakeFormat.Seconds(130))
		  Assert.AreEqual(WakeFormat.kUnknown, WakeFormat.Seconds(-1))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NewUsage(inputTokens As Int64, outputTokens As Int64, cacheWrite As Int64, cacheRead As Int64) As WakeTokenUsage
		  Var u As New WakeTokenUsage
		  u.InputTokens = inputTokens
		  u.OutputTokens = outputTokens
		  u.CacheWriteTokens = cacheWrite
		  u.CacheReadTokens = cacheRead
		  Return u
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub JSONAccessorsTolerateWrongTypesTest()
		  Var d As Dictionary = ParseJSON("{""s"": 5, ""n"": ""x"", ""a"": {}, ""o"": [], ""b"": null, ""i"": 42, ""f"": 1.5}")

		  Assert.AreEqual("", WakeCore.JSONString(d, "s"), "number is not a string")
		  Assert.AreEqual(0, WakeCore.JSONInteger(d, "n"), "string is not a number")
		  Var actualCount As Integer = WakeCore.JSONArray(d, "a").Count
		  Assert.AreEqual(0, actualCount, "object is not an array")
		  Assert.IsNil(WakeCore.JSONDictionary(d, "o"), "array is not an object")
		  Assert.IsFalse(WakeCore.JSONBoolean(d, "b"), "null is not true")
		  Assert.AreEqual(42, WakeCore.JSONInteger(d, "i"))
		  Assert.AreEqual(1.5, WakeCore.JSONDouble(d, "f"), 0.0001)
		  Assert.AreEqual("", WakeCore.JSONString(Nil, "missing"), "Nil dictionary is safe")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseISO8601InvalidTest()
		  Assert.IsNil(WakeCore.ParseISO8601(""))
		  Assert.IsNil(WakeCore.ParseISO8601("yesterday"))
		  Assert.IsNil(WakeCore.ParseISO8601("2026-13-01T00:00:00Z"), "month out of range")
		  Assert.IsNil(WakeCore.ParseISO8601("2026-09-01T10:00:00.000Q"), "unknown zone")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseISO8601OffsetTest()
		  Var utc As DateTime = WakeCore.ParseISO8601("2026-09-01T10:00:00Z")
		  Var plusTwo As DateTime = WakeCore.ParseISO8601("2026-09-01T12:00:00+02:00")

		  Assert.IsNotNil(plusTwo)
		  If utc Is Nil Or plusTwo Is Nil Then Return
		  Assert.AreEqual(utc.SecondsFrom1970, plusTwo.SecondsFrom1970, 0.001, "same instant")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseISO8601UTCTest()
		  Var d As DateTime = WakeCore.ParseISO8601("2026-09-01T10:00:03.500Z")
		  Assert.IsNotNil(d)
		  If d Is Nil Then Return

		  Var expected As New DateTime(2026, 9, 1, 10, 0, 3, 500000000, New TimeZone(0))
		  Assert.AreEqual(expected.SecondsFrom1970, d.SecondsFrom1970, 0.0001)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FormatDurationTest()
		  Assert.AreEqual(WakeFormat.kUnknown, WakeFormat.Duration(-1))
		  Assert.AreEqual("0s", WakeFormat.Duration(0))
		  Assert.AreEqual("45s", WakeFormat.Duration(45.2))
		  Assert.AreEqual("12m", WakeFormat.Duration(12 * 60 + 30))
		  Assert.AreEqual("3h 05m", WakeFormat.Duration(3 * 3600 + 5 * 60))
		  Assert.AreEqual("2d 4h", WakeFormat.Duration(52 * 3600))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FormatPercentTest()
		  Assert.AreEqual(WakeFormat.kUnknown, WakeFormat.Percent(5, 0))
		  Assert.AreEqual("0%", WakeFormat.Percent(0, 10))
		  Assert.AreEqual("<1%", WakeFormat.Percent(1, 1000))
		  Assert.AreEqual("1%", WakeFormat.Percent(6, 1000))
		  Assert.AreEqual("95%", WakeFormat.Percent(9531, 10000))
		  Assert.AreEqual("100%", WakeFormat.Percent(7, 7))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FormatTextTest()
		  Assert.AreEqual("Fix the test", WakeFormat.OneLine("Fix the" + &u0A + "  test", 0), "0 means no limit")
		  Assert.AreEqual("a b c", WakeFormat.OneLine("  a" + &u0D + &u0A + "b" + &u09 + "c  ", 50))
		  Assert.AreEqual("abcd" + WakeFormat.kEllipsis, WakeFormat.OneLine("abcdefgh", 5))

		  Assert.AreEqual("demo", WakeFormat.ProjectName("/Users/dev/demo"))
		  Assert.AreEqual("demo.app", WakeFormat.ProjectName("/Users/dev/Open Source/demo.app/"))
		  Assert.AreEqual("repo", WakeFormat.ProjectName("C:\Users\dev\repo"))
		  
		  Var short() As String = WakeFormat.ShortPaths(Array("/a/web/app/main.go", "/b/api/src/main.go", _
		  "/c/cli/src/main.go", "/d/README.md", "C:\repo\README.md"))
		  Assert.AreEqual("main.go — app", short(0), "one folder is enough")
		  Assert.AreEqual("main.go — api/src", short(1), "two folders needed")
		  Assert.AreEqual("main.go — cli/src", short(2))
		  Assert.AreEqual("README.md — d", short(3))
		  Assert.AreEqual("README.md — repo", short(4))
		  short = WakeFormat.ShortPaths(Array("/x/notes.txt"))
		  Assert.AreEqual("notes.txt", short(0), "unique names stay short")
		  Assert.AreEqual("-Users-dev-demo", WakeFormat.ProjectName("-Users-dev-demo"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FormatBytesTest()
		  Assert.AreEqual("1 byte", WakeFormat.Bytes(1))
		  Assert.AreEqual("999 bytes", WakeFormat.Bytes(999))
		  Assert.AreEqual("2.0 KB", WakeFormat.Bytes(2048))
		  Assert.AreEqual("150 KB", WakeFormat.Bytes(150000))
		  Assert.AreEqual("1.0 MB", WakeFormat.Bytes(999999))
		  Assert.AreEqual("4.0 GB", WakeFormat.Bytes(4000000000))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FormatTokensTest()
		  Assert.AreEqual("0", WakeFormat.Tokens(0))
		  Assert.AreEqual("950", WakeFormat.Tokens(950))
		  Assert.AreEqual("1.0K", WakeFormat.Tokens(1000))
		  Assert.AreEqual("12.3K", WakeFormat.Tokens(12345))
		  Assert.AreEqual("456K", WakeFormat.Tokens(456000))
		  Assert.AreEqual("1.0M", WakeFormat.Tokens(999999))
		  Assert.AreEqual("4.5M", WakeFormat.Tokens(4500000))
		  Assert.AreEqual("1.2B", WakeFormat.Tokens(1200000000))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToolTargetTest()
		  // The program and file a tool call worked on, used to group where the tokens went.
		  Var e As New WakeEvent
		  e.Kind = WakeEvent.Kinds.ShellCommand
		  e.Command = "cd ""/Users/dev/my app"" && sed -n 1,80p Core/WakeTimeline.xojo_code"
		  Assert.AreEqual("sed", e.ShellProgram)
		  Assert.AreEqual("Core/WakeTimeline.xojo_code", e.TargetPath)
		  Assert.AreEqual(".xojo_code", e.FileType)

		  e.Command = "FOO=1 /usr/bin/git log --oneline"
		  Assert.AreEqual("git", e.ShellProgram)
		  Assert.AreEqual("", e.FileType)

		  e.Command = "python3 -I - <<'EOF'" + &u0A + "open('notes.txt')"
		  Assert.AreEqual("python3", e.ShellProgram)
		  Assert.AreEqual("", e.TargetPath, "only the first line is looked at")

		  e.Command = "grep -n ""foo.bar"" README.md"
		  Assert.AreEqual(".md", e.FileType, "the last file-like word wins")

		  e.Command = "sleep 1.5"
		  Assert.AreEqual("", e.FileType, "a number is not a file type")

		  e.Command = "XD=""/Applications/Xojo 2026 Release 3""; grep -rl ""ForeignKeyChecks"" ""$XD"""
		  Assert.AreEqual("grep", e.ShellProgram, "a quoted assignment with spaces is one word")

		  e.Command = "grep -c ""a|b;c"" notes.md | wc -l"
		  Assert.AreEqual("grep", e.ShellProgram)
		  Assert.AreEqual("notes.md", e.TargetPath, "quoted | and ; don't start a command")

		  e.Command = "sed -n 1,20p '/Users/dev/my app/Main.xojo_code'"
		  Assert.AreEqual("/Users/dev/my app/Main.xojo_code", e.TargetPath, "a quoted path keeps its spaces")

		  Var readCall As New WakeEvent
		  readCall.Kind = WakeEvent.Kinds.ToolCall
		  readCall.ToolInputJSON = "{""file_path"": ""/Users/dev/app/Main.XOJO_WINDOW""}"
		  Assert.AreEqual(".xojo_window", readCall.FileType)
		  Assert.AreEqual("", readCall.ShellProgram, "not a shell command")

		  readCall.ToolInputJSON = "{""file_path"": ""/Users/dev/app/.gitignore""}"
		  Assert.AreEqual("", readCall.FileType, "a dot file has no extension")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TokenUsageAddTest()
		  Var a As New WakeTokenUsage
		  a.InputTokens = 1
		  a.OutputTokens = 2
		  a.CacheWriteTokens = 3
		  a.CacheReadTokens = 4

		  Var b As WakeTokenUsage = a.Clone
		  b.Add(a)

		  Assert.AreEqual(10, a.Total)
		  Assert.AreEqual(20, b.Total)
		  Assert.AreEqual(2, b.InputTokens)
		End Sub
	#tag EndMethod


End Class
#tag EndClass
