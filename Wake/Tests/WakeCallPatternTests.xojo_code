#tag Class
Protected Class WakeCallPatternTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub AdviceTest()
		  Var seen As New Dictionary
		  For Each key As String In Array(WakeCallPattern.kKeyLineRange, WakeCallPattern.kKeySection, WakeCallPattern.kKeyWholeFile, _
		    WakeCallPattern.kKeySearch, WakeCallPattern.kKeyListing, WakeCallPattern.kKeyEdit, WakeCallPattern.kKeyWeb, _
		    WakeCallPattern.kKeyRun, WakeCallPattern.kKeyOther, WakeCallPattern.kKeyReread)
		    Var advice As String = WakeCallPattern.Advice(key)
		    Assert.AreNotEqual("", advice, key)
		    Assert.IsFalse(seen.HasKey(advice), "advice of its own: " + key)
		    seen.Value(advice) = True
		    Assert.AreNotEqual("", WakeCallPattern.Label(key))
		  Next
		  Assert.AreEqual("Re-read", WakeCallPattern.Label(WakeCallPattern.kKeyReread))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AssertShell(expected As WakeCallPattern.Patterns, command As String)
		  Var actual As WakeCallPattern.Patterns = WakeCallPattern.Classify(Shell(command))
		  Assert.AreEqual(WakeCallPattern.Key(expected), WakeCallPattern.Key(actual), command)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AssertTool(expected As WakeCallPattern.Patterns, name As String, toolInputJSON As String = "")
		  Var e As New WakeEvent
		  e.Kind = WakeEvent.Kinds.ToolCall
		  e.ToolName = name
		  e.ToolInputJSON = toolInputJSON
		  Var actual As WakeCallPattern.Patterns = WakeCallPattern.Classify(e)
		  Assert.AreEqual(WakeCallPattern.Key(expected), WakeCallPattern.Key(actual), name + " " + toolInputJSON)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadsInSessionTest()
		  // Session 7 reads config.py with sed, again with Read (a re-read), edits it, and reads it
		  // whole after the edit, which is not a re-read.
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(7, "-Users-dev-lab", "patterns")
		  Var calls() As WakeEvent
		  For Each e As WakeEvent In session.Events
		    If e.IsToolCall Then calls.Add(e)
		  Next
		  Var count As Integer = calls.Count
		  Assert.AreEqual(8, count)
		  If count <> 8 Then Return
		  
		  Var expected() As String = Array(WakeCallPattern.kKeyLineRange, WakeCallPattern.kKeyWholeFile, _
		  WakeCallPattern.kKeyLineRange, WakeCallPattern.kKeySection, WakeCallPattern.kKeyLineRange, _
		  WakeCallPattern.kKeyEdit, WakeCallPattern.kKeyWholeFile, WakeCallPattern.kKeySearch)
		  For i As Integer = 0 To calls.LastIndex
		    Assert.AreEqual(expected(i), WakeCallPattern.Key(calls(i).Pattern), calls(i).Summary)
		    If i = 4 Then
		      Assert.IsTrue(calls(i).IsReread, "read again: " + calls(i).Summary)
		    Else
		      Assert.IsFalse(calls(i).IsReread, calls(i).Summary)
		    End If
		  Next
		  
		  Assert.AreEqual("/Users/dev/lab/src/config.py", calls(0).ResolvedTargetPath(session.ProjectPath), "relative to the session's folder")
		  Assert.AreEqual("/Users/dev/lab/docs/user guide.md", calls(1).ResolvedTargetPath(session.ProjectPath))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResolvedTargetTest()
		  Assert.AreEqual("/work/app/src/my module.py", Shell("cat 'src/my module.py'").ResolvedTargetPath("/work/app"))
		  Assert.AreEqual("/work/app/web/src/app.ts", Shell("cd web && head -5 ./src/app.ts").ResolvedTargetPath("/work/app"))
		  Assert.AreEqual("/srv/lib/x.rs", Shell("cd /srv && cat lib/x.rs").ResolvedTargetPath("/work/app"))
		  Assert.AreEqual("/abs/main.go", Shell("cat /abs/main.go").ResolvedTargetPath("/work/app"))
		  Assert.AreEqual("C:\work\app\main.cs", Shell("type main.cs").ResolvedTargetPath("C:\work\app"))
		  Assert.AreEqual("main.cs", Shell("type main.cs").ResolvedTargetPath(""), "no folder")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Shell(command As String) As WakeEvent
		  Var e As New WakeEvent
		  e.Kind = WakeEvent.Kinds.ShellCommand
		  e.ToolName = "Bash"
		  e.Command = command
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShellPatternsTest()
		  AssertShell(WakeCallPattern.Patterns.LineRange, "sed -n '10,80p' app/main.py")
		  AssertShell(WakeCallPattern.Patterns.LineRange, "sed -n 5p cmd/server.go")
		  AssertShell(WakeCallPattern.Patterns.LineRange, "sed -n -e '1,$p' lib.rb")
		  AssertShell(WakeCallPattern.Patterns.LineRange, "awk 'NR>=3 && NR<=9' src/lib.rs")
		  AssertShell(WakeCallPattern.Patterns.LineRange, "head -50 ""My Project/notes.txt""")
		  AssertShell(WakeCallPattern.Patterns.LineRange, "tail -n 30 build.log")
		  AssertShell(WakeCallPattern.Patterns.Section, "cd web && sed -n '/export function/,/^}/p' src/app.ts")
		  AssertShell(WakeCallPattern.Patterns.Section, "sed -n '120,/^end/p' lib/parser.rb")
		  AssertShell(WakeCallPattern.Patterns.Section, "awk '/^fn main/,/^}/' src/main.rs")
		  AssertShell(WakeCallPattern.Patterns.WholeFile, "cat ""src/my module.py""")
		  AssertShell(WakeCallPattern.Patterns.WholeFile, "less README.md")
		  AssertShell(WakeCallPattern.Patterns.WholeFile, "cat pkg/handler.go | head -20")
		  AssertShell(WakeCallPattern.Patterns.Edit, "cat > out.go << 'EOF'")
		  AssertShell(WakeCallPattern.Patterns.Edit, "sed -i 's/old/new/' src/x.ts")
		  AssertShell(WakeCallPattern.Patterns.Run, "sed 's/old/new/' src/x.ts")
		  AssertShell(WakeCallPattern.Patterns.Run, "cat << 'EOF'")
		  AssertShell(WakeCallPattern.Patterns.Search, "sed -n '/TODO/p' main.py")
		  AssertShell(WakeCallPattern.Patterns.Search, "grep -rn TODO src")
		  AssertShell(WakeCallPattern.Patterns.Search, "rg ""fn main"" --type rust")
		  AssertShell(WakeCallPattern.Patterns.Search, "git grep -n parse")
		  AssertShell(WakeCallPattern.Patterns.Listing, "ls -la")
		  AssertShell(WakeCallPattern.Patterns.Listing, "find . -name '*.ts'")
		  AssertShell(WakeCallPattern.Patterns.Listing, "git ls-files")
		  AssertShell(WakeCallPattern.Patterns.Run, "go test ./...")
		  AssertShell(WakeCallPattern.Patterns.Run, "cargo build --release")
		  AssertShell(WakeCallPattern.Patterns.Run, "FOO=1 npm test")
		  AssertShell(WakeCallPattern.Patterns.Run, "git status")
		  AssertShell(WakeCallPattern.Patterns.Run, "")
		  
		  // Command substitution runs its own program.
		  AssertShell(WakeCallPattern.Patterns.Search, "f=$(grep -rl ""class Parser"" src); echo $f")
		  AssertShell(WakeCallPattern.Patterns.Section, "BODY=$(sed -n '/^def load/,$p' app/config.py)")
		  Assert.AreEqual("grep", Shell("f=$(grep -rl ""class Parser"" src)").ShellProgram)
		  Assert.AreEqual("printf", Shell("(printf 'a'; echo b) | sort").ShellProgram)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToolPatternsTest()
		  AssertTool(WakeCallPattern.Patterns.LineRange, "Read", "{""file_path"": ""/a/b.py"", ""offset"": 10, ""limit"": 40}")
		  AssertTool(WakeCallPattern.Patterns.WholeFile, "Read", "{""file_path"": ""/a/b.py""}")
		  AssertTool(WakeCallPattern.Patterns.WholeFile, "Read", "not json")
		  AssertTool(WakeCallPattern.Patterns.Search, "Grep")
		  AssertTool(WakeCallPattern.Patterns.Listing, "Glob")
		  AssertTool(WakeCallPattern.Patterns.Web, "WebFetch")
		  AssertTool(WakeCallPattern.Patterns.Web, "WebSearch")
		  AssertTool(WakeCallPattern.Patterns.Web, "mcp__claude-in-chrome__navigate")
		  AssertTool(WakeCallPattern.Patterns.Web, "mcp__Claude_Browser__read_page")
		  AssertTool(WakeCallPattern.Patterns.Other, "TodoWrite")
		  AssertTool(WakeCallPattern.Patterns.Other, "Agent")
		  
		  Var edit As New WakeEvent
		  edit.Kind = WakeEvent.Kinds.FileEdit
		  edit.ToolName = "Write"
		  Var actual As WakeCallPattern.Patterns = WakeCallPattern.Classify(edit)
		  Assert.AreEqual(WakeCallPattern.kKeyEdit, WakeCallPattern.Key(actual))
		  
		  Var prompt As New WakeEvent
		  prompt.Kind = WakeEvent.Kinds.UserPrompt
		  actual = WakeCallPattern.Classify(prompt)
		  Assert.AreEqual(WakeCallPattern.kKeyOther, WakeCallPattern.Key(actual), "not a tool call")
		End Sub
	#tag EndMethod


End Class
#tag EndClass
