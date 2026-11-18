#tag Class
Protected Class WakeCLITests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Two fixture roots on a scratch copy: /Users/dev/demo and /Users/dev/Open Source/demo.app
		  // (September 2026), and /Users/dev/lab with every call pattern (30 August 2026). The CLI
		  // indexes them itself, as it does at every run.
		  mScratch = TestSupport.NewScratchFolder
		  Var fixtures As FolderItem = TestSupport.FixturesFolder("claude-code")
		  TestSupport.CopyFolder(fixtures.Child("projects"), mScratch.Child("projects"))
		  TestSupport.CopyFolder(fixtures.Child("patterns"), mScratch.Child("patterns"))
		End Sub
	#tag EndEvent

	#tag Event
		Sub TearDown()
		  TestSupport.RemoveScratchFolder(mScratch)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ArgsTest()
		  Var values() As String = Array("since", "by")
		  Var args As New WakeCLIArgs(Array("usage", "--since", "7d", "--by=file", "--json", "--", "--literal"), Array("json"), values)
		  Assert.AreEqual("", args.Error)
		  Var count As Integer = args.Words.Count
		  Assert.AreEqual(2, count, "words, and everything after --")
		  Assert.AreEqual("usage", args.Words(0))
		  Assert.AreEqual("--literal", args.Words(1))
		  Assert.AreEqual("7d", args.Value("since"))
		  Assert.AreEqual("file", args.Value("by"))
		  Assert.IsTrue(args.Has("json"))
		  
		  args = New WakeCLIArgs(Array("-h"), Array("help"), values)
		  Assert.IsTrue(args.Has("help"), "-h is --help")
		  args = New WakeCLIArgs(Array("--since"), Array("json"), values)
		  Assert.AreEqual("--since needs a value.", args.Error)
		  args = New WakeCLIArgs(Array("--json=yes"), Array("json"), values)
		  Assert.AreEqual("--json takes no value.", args.Error)
		  args = New WakeCLIArgs(Array("-x"), Array("json"), values)
		  Assert.AreEqual("Unknown option -x.", args.Error)
		  args = New WakeCLIArgs(Array("--colour", "--json"), Array("json"), values)
		  Assert.AreEqual("Unknown option --colour.", args.Error, "not taken for an option that needs a value")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BadArgumentsTest()
		  Var cli As WakeCLI = NewCLI
		  Assert.AreEqual(1, cli.Run(Array("frobnicate")))
		  Assert.IsTrue(cli.ErrorOutput.IndexOf("Unknown command ""frobnicate""") >= 0, cli.ErrorOutput)
		  Assert.AreEqual("", cli.Output)
		  
		  Assert.AreEqual(1, cli.Run(Array("usage", "--by", "type")), "a word inside a grouping's name isn't one")
		  Assert.AreEqual(1, cli.Run(Array("usage", "--since", "last week")))
		  Assert.AreEqual(1, cli.Run(Array("usage", "--since", "2026-02-30")), "no such day")
		  Assert.AreEqual(1, cli.Run(Array("usage", "--since", "7d", "--until", "14d")), "ends before it starts")
		  Assert.AreEqual(1, cli.Run(Array("usage", "--limit", "-3")))
		  Assert.AreEqual(1, cli.Run(Array("usage", "--colour")))
		  Assert.IsTrue(cli.ErrorOutput.IndexOf("Unknown option --colour.") >= 0, cli.ErrorOutput)
		  Assert.AreEqual(1, cli.Run(Array("usage", "demo")))
		  
		  Assert.AreEqual(1, cli.Run(Array("usage", "--since", "all", "--project", "nothing-like-it")))
		  Assert.IsTrue(cli.ErrorOutput.IndexOf("/Users/dev/lab") >= 0, "lists the projects it knows" + ": " + cli.ErrorOutput)
		  
		  Assert.AreEqual(1, cli.Run(Array("usage", "--project", ".")), "no working folder to start at")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CallsTest()
		  Var cli As WakeCLI = NewCLI
		  Var lab As String = TestSupport.ClaudeFixtureID(7)
		  
		  Assert.AreEqual(0, cli.Run(Array("calls", "--since", "all", "--project", "lab", "--key", "Re-read")), cli.ErrorOutput)
		  Var text As String = cli.Output
		  Assert.IsTrue(text.BeginsWith("Calls in intent ""Re-read"", all time, /Users/dev/lab."), text)
		  Assert.IsTrue(text.IndexOf(" src/config.py ") >= 0, "the target, relative to the project")
		  Assert.IsTrue(text.IndexOf(lab) >= 0, "the session id")
		  Assert.IsTrue(text.IndexOf("What each call asked for:") < 0, "no transcript text without --snippets")
		  
		  Assert.AreEqual(0, cli.Run(Array("calls", "--since", "all", "--key", "re-read", "--json")))
		  Var root As New JSONItem(cli.Output)
		  Var rows As JSONItem = root.Child("rows")
		  Var count As Integer = rows.Count
		  Assert.AreEqual(1, count)
		  If count = 1 Then
		    Var c As JSONItem = rows.ChildAt(0)
		    Assert.AreEqual("/Users/dev/lab/src/config.py", c.Value("target").StringValue)
		    Assert.AreEqual(lab, c.Value("session").StringValue)
		    Assert.AreEqual("re-read", c.Value("intent").StringValue)
		    Assert.IsTrue(c.Value("transcript").StringValue.EndsWith(lab + ".jsonl"))
		    Assert.IsFalse(c.HasKey("summary"))
		  End If
		  
		  Assert.AreEqual(0, cli.Run(Array("calls", "--since", "all", "--key", "re-read", "--json", "--snippets")))
		  root = New JSONItem(cli.Output)
		  rows = root.Child("rows")
		  If rows.Count = 1 Then Assert.IsTrue(rows.ChildAt(0).HasKey("summary"), "--snippets adds the call's input")
		  
		  // A file's calls, named relative to the project.
		  Assert.AreEqual(0, cli.Run(Array("calls", "--since", "all", "--project", "lab", "--by", "file", "--key", "src/config.py", "--json")))
		  root = New JSONItem(cli.Output)
		  count = root.Child("rows").Count
		  Assert.AreEqual(4, count)
		  Assert.AreEqual("/Users/dev/lab/src/config.py", root.Value("key").StringValue)
		  
		  Assert.AreEqual(0, cli.Run(Array("calls", "--since", "all", "--project", "demo", "--key", "re-read")))
		  Assert.IsTrue(cli.Output.IndexOf("No calls in this group and period.") >= 0, "other projects' calls left out")
		  
		  Assert.AreEqual(1, cli.Run(Array("calls", "--since", "all")), "--key is needed")
		  Assert.AreEqual(1, cli.Run(Array("calls", "--key", "Rereads")))
		  Assert.IsTrue(cli.ErrorOutput.IndexOf("line-range") >= 0, "lists the intents")
		  Assert.AreEqual(1, cli.Run(Array("calls", "--by", "project", "--key", "x")), "not a tool grouping")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompareTest()
		  Var cli As WakeCLI = NewCLI
		  
		  // The two days before 3 September (sessions 1 and 2) and the two from it on (3 and 4).
		  Assert.AreEqual(0, cli.Run(Array("compare", "--at", "2026-09-03", "--days", "2", "--json")), cli.ErrorOutput)
		  Var root As New JSONItem(cli.Output)
		  Assert.AreEqual("2026-09-01", root.Child("before").Value("from").StringValue)
		  Assert.AreEqual("2026-09-02", root.Child("before").Value("to").StringValue)
		  Assert.AreEqual("2026-09-03", root.Child("after").Value("from").StringValue)
		  Assert.AreEqual("2026-09-04", root.Child("after").Value("to").StringValue)
		  Assert.IsTrue(root.Value("few_sessions").BooleanValue)
		  Var rates As New Dictionary
		  Var list As JSONItem = root.Child("rates")
		  For i As Integer = 0 To list.Count - 1
		    rates.Value(list.ChildAt(i).Value("key").StringValue) = list.ChildAt(i)
		  Next
		  Assert.IsTrue(rates.HasKey("tokens_per_session"))
		  Assert.IsTrue(rates.HasKey("led_nowhere_share"))
		  Assert.IsFalse(rates.HasKey("cost_per_session"), "no prices, no cost")
		  Assert.AreEqual(2, JSONItem(rates.Value("sessions")).Value("before").IntegerValue)
		  Assert.AreEqual(2, JSONItem(rates.Value("sessions")).Value("after").IntegerValue)
		  Assert.IsTrue(JSONItem(rates.Value("tokens_per_session")).Value("before").DoubleValue > 0)
		  
		  Assert.AreEqual(0, cli.Run(Array("compare", "--at", "2026-09-03", "--days", "2")))
		  Var text As String = cli.Output
		  Assert.IsTrue(text.BeginsWith("Before: 2026-09-01 to 2026-09-02. After: 2026-09-03 to 2026-09-04. Every project."), text.Left(120))
		  Assert.IsTrue(text.IndexOf("Lower is better for every rate") >= 0)
		  Assert.IsTrue(text.IndexOf("Tokens per session") >= 0)
		  Assert.IsTrue(text.IndexOf("too few to tell a change from chance") >= 0)
		  
		  // An empty side has no rates to compare.
		  Assert.AreEqual(0, cli.Run(Array("compare", "--before", "2026-08-30..2026-08-31", "--after", "2026-09-01..2026-09-05", "--project", "lab", "--json")))
		  root = New JSONItem(cli.Output)
		  list = root.Child("rates")
		  For i As Integer = 0 To list.Count - 1
		    If list.ChildAt(i).Value("key").StringValue = "tokens_per_session" Then
		      Assert.IsTrue(list.ChildAt(i).Value("before").DoubleValue > 0)
		      Assert.IsTrue(list.ChildAt(i).Value("after").IsNull, "no sessions after")
		    End If
		  Next
		  
		  Assert.AreEqual(1, cli.Run(Array("compare")))
		  Assert.AreEqual(1, cli.Run(Array("compare", "--at", "2026-09-03", "--before", "2026-09-01..2026-09-02")))
		  Assert.AreEqual(1, cli.Run(Array("compare", "--before", "2026-09-01", "--after", "2026-09-02..2026-09-03")))
		  Assert.AreEqual(1, cli.Run(Array("compare", "--before", "2026-09-05..2026-09-01", "--after", "2026-09-02..2026-09-03")), "backwards")
		  Assert.AreEqual(1, cli.Run(Array("compare", "--at", "2027-01-01")), "nothing after it yet")
		  Assert.AreEqual(1, cli.Run(Array("compare", "--at", "2026-09-03", "--days", "0")))
		  Assert.AreEqual(1, cli.Run(Array("compare", "--at", "2026-09-03", "--since", "7d")))
		  Assert.IsTrue(cli.ErrorOutput.IndexOf("Unknown option --since.") >= 0, cli.ErrorOutput)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HelpTest()
		  Var cli As WakeCLI = NewCLI
		  Assert.AreEqual(0, cli.Run(Array("help")))
		  Assert.IsTrue(cli.Output.BeginsWith("wake: "))
		  Assert.IsTrue(cli.Output.IndexOf("Exit codes") >= 0)
		  For Each command As String In Array("report", "usage", "calls", "sessions", "compare")
		    Assert.AreEqual(0, cli.Run(Array("help", command)), command)
		    Assert.IsTrue(cli.Output.BeginsWith("Usage: wake " + command), command)
		    Assert.AreEqual(0, cli.Run(Array(command, "-h")), command)
		    Assert.IsTrue(cli.Output.BeginsWith("Usage: wake " + command), command)
		  Next
		  
		  Var none() As String
		  Assert.AreEqual(0, cli.Run(none), "no command shows the help")
		  Assert.IsTrue(cli.Output.BeginsWith("wake: "))
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--help")))
		  Assert.IsTrue(cli.Output.BeginsWith("Usage: wake usage"))
		  Assert.AreEqual(0, cli.Run(Array("help", "usage")))
		  Assert.IsTrue(cli.Output.BeginsWith("Usage: wake usage"))
		  
		  cli.Version = "1.2.0"
		  Assert.AreEqual(0, cli.Run(Array("--version")))
		  Assert.AreEqual("wake 1.2.0", cli.Output)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HiddenProjectsTest()
		  Var cli As WakeCLI = NewCLI
		  cli.HiddenProjects = New WakeHiddenProjects
		  cli.HiddenProjects.Hide("claude-code", "/Users/dev/demo")
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all")))
		  Assert.IsTrue(cli.Output.IndexOf("every project but the 1 hidden in Wake") >= 0)
		  Assert.IsTrue(cli.Output.IndexOf(&u0A + "/Users/dev/demo ") < 0, "hidden project left out")
		  Assert.IsTrue(cli.Output.IndexOf(&u0A + "/Users/dev/lab ") >= 0)
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--all")))
		  Assert.IsTrue(cli.Output.IndexOf(&u0A + "/Users/dev/demo ") >= 0, "--all includes it")
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "demo", "--by", "model")), "named, it's found")
		  Assert.IsTrue(cli.Output.IndexOf("claude-opus-5-5") >= 0)
		  
		  // Tool calls leave hidden projects out too.
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--by", "file", "--limit", "0")))
		  Assert.IsTrue(cli.Output.IndexOf("/Users/dev/demo/") < 0)
		  Assert.IsTrue(cli.Output.IndexOf("/Users/dev/lab/src/config.py") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IndexUnavailableTest()
		  // A folder can't be opened as a database.
		  Var roots() As WakeIndexRoot
		  Var cli As New WakeCLI(mScratch, roots)
		  Assert.AreEqual(2, cli.Run(Array("usage")))
		  Assert.IsTrue(cli.ErrorOutput.BeginsWith("Could not open Wake's index"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NewCLI() As WakeCLI
		  Var roots() As WakeIndexRoot
		  roots.Add(New WakeIndexRoot("claude-code", mScratch.Child("projects")))
		  roots.Add(New WakeIndexRoot("claude-code", mScratch.Child("patterns")))
		  Var cli As New WakeCLI(mScratch.Child("index.sqlite"), roots)
		  cli.CurrentTime = New DateTime(2026, 11, 18, 15, 30, 0, 0, TimeZone.Current)
		  Return cli
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NoIndexTest()
		  Var cli As WakeCLI = NewCLI
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--no-index")))
		  Assert.IsTrue(cli.Output.IndexOf("No usage in this period.") >= 0, "nothing indexed yet")
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all")))
		  Assert.IsTrue(cli.Output.IndexOf("/Users/dev/lab") >= 0, "indexed first")
		  
		  Assert.AreEqual(0, cli.Run(Array("usage")))
		  Assert.IsTrue(cli.Output.IndexOf("2026-11-12 to 2026-11-18") >= 0, "the last 7 days by default")
		  Assert.IsTrue(cli.Output.IndexOf("No usage in this period.") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PeriodTest()
		  Var now As New DateTime(2026, 11, 18, 15, 30, 0, 0, TimeZone.Current)
		  Var d As DateTime
		  
		  Assert.IsTrue(WakeCLIArgs.ParseStart("7d", now, d))
		  Assert.AreEqual("2026-11-12 00:00:00", d.SQLDateTime, "7 days counting today")
		  Assert.IsTrue(WakeCLIArgs.ParseStart("1d", now, d))
		  Assert.AreEqual("2026-11-18 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("today", now, d))
		  Assert.AreEqual("2026-11-18 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("yesterday", now, d))
		  Assert.AreEqual("2026-11-17 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("2w", now, d))
		  Assert.AreEqual("2026-11-05 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("1m", now, d))
		  Assert.AreEqual("2026-10-19 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("1y", now, d))
		  Assert.AreEqual("2025-11-19 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("2026-09-01", now, d))
		  Assert.AreEqual("2026-09-01 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseStart("ALL", now, d))
		  Assert.IsNil(d, "all time")
		  
		  For Each bad As String In Array("", "0d", "7", "d", "7h", "-7d", "2026-13-01", "2026-02-29", "2026-9-1", "last week")
		    Assert.IsFalse(WakeCLIArgs.ParseStart(bad, now, d), """" + bad + """ isn't a start")
		  Next
		  
		  // An end is the moment after the last day it includes.
		  Assert.IsTrue(WakeCLIArgs.ParseEnd("2026-09-02", now, d))
		  Assert.AreEqual("2026-09-03 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseEnd("today", now, d))
		  Assert.AreEqual("2026-11-19 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseEnd("yesterday", now, d))
		  Assert.AreEqual("2026-11-18 00:00:00", d.SQLDateTime)
		  Assert.IsTrue(WakeCLIArgs.ParseEnd("7d", now, d))
		  Assert.AreEqual("2026-11-12 00:00:00", d.SQLDateTime, "ends where the last 7 days start")
		  Assert.IsFalse(WakeCLIArgs.ParseEnd("all", now, d))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ProjectTest()
		  Var cli As WakeCLI = NewCLI
		  
		  // By name, by path, and by a folder inside the project.
		  For Each name As String In Array("lab", "/Users/dev/lab", "/Users/dev/lab/", "/Users/dev/lab/src/deep")
		    Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", name, "--json")), name)
		    Var root As New JSONItem(cli.Output)
		    Assert.AreEqual("/Users/dev/lab", root.Value("project").StringValue, name)
		    Var count As Integer = root.Child("rows").Count
		    Assert.AreEqual(1, count, name)
		  Next
		  
		  // "." and relative paths start at the working folder.
		  cli.WorkingFolder = "/Users/dev/Open Source/demo.app/src"
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", ".", "--json")))
		  Var found As New JSONItem(cli.Output)
		  Assert.AreEqual("/Users/dev/Open Source/demo.app", found.Value("project").StringValue)
		  cli.WorkingFolder = "/Users/dev"
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "./demo", "--json")))
		  found = New JSONItem(cli.Output)
		  Assert.AreEqual("/Users/dev/demo", found.Value("project").StringValue)
		  
		  // A folder above every project matches none.
		  Assert.AreEqual(1, cli.Run(Array("usage", "--since", "all", "--project", "/Users/dev")))
		  
		  // Tool calls within one project.
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "demo", "--by", "file", "--limit", "0")))
		  Assert.IsTrue(cli.Output.IndexOf("/Users/dev/lab/") < 0, "other projects' files left out")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReportTest()
		  Var cli As WakeCLI = NewCLI
		  Assert.AreEqual(0, cli.Run(Array("report", "--since", "all", "--project", "lab")), cli.ErrorOutput)
		  Var text As String = cli.Output
		  Assert.IsTrue(text.BeginsWith("# Where the tokens went: all time, /Users/dev/lab"), text.Left(80))
		  Assert.IsTrue(text.IndexOf(". Re-read: ≈") >= 0)
		  Assert.IsTrue(text.IndexOf(WakeCallPattern.Advice(WakeCallPattern.kKeyReread)) >= 0)
		  Assert.IsTrue(text.IndexOf("in session `" + TestSupport.ClaudeFixtureID(7) + "`") >= 0, "calls name their session by id")
		  Assert.IsTrue(text.IndexOf("$ grep") < 0, "no commands without --snippets")
		  
		  Assert.AreEqual(0, cli.Run(Array("report", "--since", "all", "--project", "lab", "--snippets")))
		  Assert.IsTrue(cli.Output.IndexOf("$ grep") >= 0, "--snippets adds the commands")
		  
		  Assert.AreEqual(0, cli.Run(Array("report", "--since", "all", "--project", "demo")))
		  Assert.IsTrue(cli.Output.IndexOf("/Users/dev/lab") < 0, "other projects left out")
		  
		  Assert.AreEqual(0, cli.Run(Array("report", "--since", "2026-09-01", "--until", "2026-09-01", "--project", "lab")))
		  Assert.IsTrue(cli.Output.IndexOf("No tool calls in this period") >= 0, "lab's calls were on 30 August")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionsTest()
		  Var cli As WakeCLI = NewCLI
		  Var lab As String = TestSupport.ClaudeFixtureID(7)
		  
		  Assert.AreEqual(0, cli.Run(Array("sessions", "--since", "all", "--project", "lab", "--json")), cli.ErrorOutput)
		  Var root As New JSONItem(cli.Output)
		  Assert.AreEqual(1, root.Value("row_count").IntegerValue)
		  Var rows As JSONItem = root.Child("rows")
		  If rows.Count = 1 Then
		    Var s As JSONItem = rows.ChildAt(0)
		    Assert.AreEqual(lab, s.Value("session").StringValue)
		    Assert.AreEqual("/Users/dev/lab", s.Value("project").StringValue)
		    Assert.IsTrue(s.Value("tokens").Int64Value > 0)
		    Assert.IsFalse(s.HasKey("title"), "no titles without --snippets")
		  End If
		  
		  Assert.AreEqual(0, cli.Run(Array("sessions", "--since", "all", "--project", "lab", "--json", "--snippets")))
		  root = New JSONItem(cli.Output)
		  rows = root.Child("rows")
		  If rows.Count = 1 Then Assert.IsTrue(rows.ChildAt(0).HasKey("title"))
		  
		  // Two days of September: sessions 1 and 2, newest first.
		  Assert.AreEqual(0, cli.Run(Array("sessions", "--since", "2026-09-01", "--until", "2026-09-02", "--json")))
		  root = New JSONItem(cli.Output)
		  rows = root.Child("rows")
		  Var count As Integer = rows.Count
		  Assert.AreEqual(2, count)
		  If count = 2 Then
		    Assert.AreEqual(TestSupport.ClaudeFixtureID(2), rows.ChildAt(0).Value("session").StringValue)
		    Assert.AreEqual(TestSupport.ClaudeFixtureID(1), rows.ChildAt(1).Value("session").StringValue)
		  End If
		  
		  Assert.AreEqual(0, cli.Run(Array("sessions", "--since", "all", "--limit", "1")))
		  Assert.IsTrue(cli.Output.IndexOf("showing 1 (--limit 0 for all)") >= 0, cli.Output)
		  Assert.IsTrue(cli.Output.IndexOf("Project") >= 0, "a project column across projects")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToolUsageTest()
		  Var cli As WakeCLI = NewCLI
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "lab", "--by", "intent")))
		  Var text As String = cli.Output
		  Assert.IsTrue(text.BeginsWith("Tool calls by intent, all time, /Users/dev/lab."))
		  Assert.IsTrue(text.IndexOf("Re-read") >= 0)
		  Assert.IsTrue(text.IndexOf("What would send less:") >= 0)
		  Assert.IsTrue(text.IndexOf(WakeCallPattern.Advice(WakeCallPattern.kKeyReread)) >= 0)
		  Assert.IsTrue(text.IndexOf("No prices are set in Wake") >= 0)
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "lab", "--by", "file", "--json")))
		  Var root As New JSONItem(cli.Output)
		  Assert.IsTrue(root.Value("estimated").BooleanValue)
		  Var rows As JSONItem = root.Child("rows")
		  Var config As JSONItem
		  For i As Integer = 0 To rows.Count - 1
		    If rows.ChildAt(i).Value("key").StringValue = "/Users/dev/lab/src/config.py" Then config = rows.ChildAt(i)
		  Next
		  Assert.IsNotNil(config, "relative and absolute paths are one file")
		  If config <> Nil Then
		    Assert.AreEqual(4, config.Value("calls").IntegerValue)
		    Assert.AreEqual(3, config.Value("reads").IntegerValue)
		    Assert.AreEqual(1, config.Value("reads_again").IntegerValue)
		  End If
		  
		  // Within a project, files are named from its folder.
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "lab", "--by", "file", "--limit", "0")))
		  Assert.IsTrue(cli.Output.IndexOf(&u0A + "src/config.py ") >= 0, cli.Output)
		  Assert.IsTrue(cli.Output.IndexOf("/Users/dev/lab/src") < 0)
		  
		  // --limit keeps the totals of every row.
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "lab", "--by", "file", "--limit", "1")))
		  Assert.IsTrue(cli.Output.IndexOf("showing 1 of ") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsageTest()
		  Var cli As WakeCLI = NewCLI
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all")), cli.ErrorOutput)
		  Var text As String = cli.Output
		  Assert.IsTrue(text.BeginsWith("Tokens by project, all time, every project."))
		  Assert.IsTrue(text.IndexOf("Project  ") >= 0, "a header row")
		  Assert.IsTrue(text.IndexOf(&u0A + "Total: ") >= 0)
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--json")))
		  Var root As New JSONItem(cli.Output)
		  Assert.AreEqual("usage", root.Value("command").StringValue)
		  Assert.AreEqual("project", root.Value("by").StringValue)
		  Assert.IsTrue(root.Value("from").IsNull)
		  Assert.AreEqual("2026-11-18", root.Value("to").StringValue)
		  Assert.IsFalse(root.Value("prices_set").BooleanValue)
		  Var rows As JSONItem = root.Child("rows")
		  Var count As Integer = rows.Count
		  Assert.AreEqual(3, count, "demo, demo.app and lab")
		  Assert.AreEqual(3, root.Value("row_count").IntegerValue)
		  Var sum As Int64
		  For i As Integer = 0 To rows.Count - 1
		    sum = sum + rows.ChildAt(i).Value("tokens").Int64Value
		    Assert.IsTrue(rows.ChildAt(i).Value("cost_usd").IsNull, "no prices, no cost")
		  Next
		  Assert.AreEqual(sum, root.Child("total").Value("tokens").Int64Value)
		  
		  // Prices make costs.
		  Var prices As New WakePriceTable
		  Var opus As New WakeModelPrice("claude-opus-5-5")
		  opus.InputPerMillion = 5
		  opus.OutputPerMillion = 25
		  opus.CacheWritePerMillion = 6.25
		  opus.CacheReadPerMillion = 0.5
		  prices.SetPrice(opus)
		  cli.Prices = prices
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "all", "--project", "lab")))
		  Assert.IsTrue(cli.Output.IndexOf("Cost") >= 0)
		  Assert.IsTrue(cli.Output.IndexOf("$") >= 0)
		  
		  // Two days of September, by day.
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "2026-09-01", "--until", "2026-09-02", "--by", "day", "--json")))
		  root = New JSONItem(cli.Output)
		  Assert.AreEqual("2026-09-01", root.Value("from").StringValue)
		  Assert.AreEqual("2026-09-02", root.Value("to").StringValue)
		  rows = root.Child("rows")
		  count = rows.Count
		  Assert.AreEqual(2, count)
		  If count = 2 Then
		    Assert.AreEqual("2026-09-02", rows.ChildAt(0).Value("key").StringValue, "newest first")
		    Assert.AreEqual("2026-09-01", rows.ChildAt(1).Value("key").StringValue)
		  End If
		  
		  Assert.AreEqual(0, cli.Run(Array("usage", "--since", "2026-09-01", "--until", "2026-09-02", "--by", "day")))
		  Assert.IsTrue(cli.Output.BeginsWith("Tokens by day, 2026-09-01 to 2026-09-02, every project."))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mScratch As FolderItem
	#tag EndProperty


End Class
#tag EndClass
