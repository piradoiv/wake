#tag Class
Protected Class WakeMarkdownTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function Report(sessionNumber As Integer, prices As WakePriceTable = Nil) As String
		  Var md As New WakeMarkdown(TestSupport.ParseClaudeFixture(sessionNumber), prices)
		  Return md.Markdown
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CommandsTest()
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var md As New WakeMarkdown(session)
		  Var text As String = md.Markdown
		  
		  Assert.IsTrue(text.IndexOf("## Commands" + &u0A + &u0A + "```sh" + &u0A + "$ make test") >= 0, "commands in one shell block")
		  Assert.IsTrue(text.IndexOf("$ make test VERBOSE=1") >= 0)
		  Assert.IsTrue(text.IndexOf("  # failed" + &u0A) >= 0, "failed command marked")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FenceTest()
		  Assert.AreEqual("```diff" + &u0A + "+a" + &u0A + "```", WakeMarkdown.Fence("+a" + &u0A, "diff"), "one trailing line break dropped")
		  
		  // Text that holds a fence gets a longer one, so it can't close the block early.
		  Var tricky As String = "before" + &u0A + "```" + &u0A + "after"
		  Assert.AreEqual("````" + &u0A + tricky + &u0A + "````", WakeMarkdown.Fence(tricky, ""))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FileChangesTest()
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var md As New WakeMarkdown(session)
		  Var text As String = md.Markdown
		  
		  Var edits As Integer
		  For Each e As WakeEvent In session.Events
		    If e.Kind <> WakeEvent.Kinds.FileEdit Then Continue
		    edits = edits + 1
		    Assert.IsTrue(text.IndexOf("### `" + e.FilePath + "` (" + e.ToolName + ", +") >= 0, e.FilePath)
		  Next
		  Assert.AreEqual(2, edits, "Edit and Write")
		  Assert.IsTrue(text.IndexOf("```diff" + &u0A) >= 0, "changes as fenced diffs")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MissingTranscriptTest()
		  Var md As New WakeMarkdown(WakeCore.LoadSession("claude-code", "/no/such/folder/session.jsonl"))
		  Var text As String = md.Markdown
		  Assert.IsTrue(text.IndexOf("**Could not read the transcript:**") >= 0)
		  Assert.IsTrue(text.IndexOf("No tokens recorded.") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PartialTest()
		  Assert.IsTrue(Report(3).IndexOf("> **Partially parsed:**") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PromptsTest()
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(1)
		  Var md As New WakeMarkdown(session)
		  Var text As String = md.Markdown
		  
		  Var firstLine As String = session.FirstPrompt.ReplaceLineEndings(&u0A).NthField(&u0A, 1)
		  Assert.IsTrue(text.IndexOf("## Prompts" + &u0A + &u0A + "### 1. ") >= 0)
		  Assert.IsTrue(text.IndexOf("> " + firstLine) >= 0, "prompt quoted")
		  Assert.IsTrue(text.IndexOf("### 2. ") < 0, "one prompt")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SubagentTest()
		  Var text As String = Report(4)
		  Assert.IsTrue(text.IndexOf("| Subagents | 1 |") >= 0)
		  Assert.IsTrue(text.IndexOf("| `claude-haiku-4-5-20251001` | 110 | 25 |") >= 0, "subagent tokens in the table")
		  Assert.IsTrue(text.IndexOf("| **Total** | 135 |") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SummaryTest()
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var md As New WakeMarkdown(session)
		  Var text As String = md.Markdown
		  
		  Assert.IsTrue(text.BeginsWith("# Fix failing CSV quoting test" + &u0A), "title")
		  Assert.IsTrue(text.IndexOf("| Branch | `feature/csv` |") >= 0)
		  Assert.IsTrue(text.IndexOf("| Project | `/Users/dev/demo` |") >= 0)
		  
		  Var started As New DateTime(session.StartTime.SecondsFrom1970, TimeZone.Current)
		  Assert.IsTrue(text.IndexOf("| Started | " + started.SQLDateTime + " |") >= 0, "local start time")
		  Assert.IsTrue(text.IndexOf("| Tool calls | 6 (2 commands, 2 file changes) |") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TokensTest()
		  Var text As String = Report(2)
		  Assert.IsTrue(text.IndexOf("| **Total** | 22 | 190 | 700 | " + WakeFormat.Count(17500) + " | " + _
		  WakeFormat.Count(18412) + " | **" + WakeFormat.kNoPrice + "** |") >= 0, "totals without prices")
		  Assert.IsTrue(text.IndexOf("Cost reported by agent: " + WakeFormat.USD(0.1234) + ".") >= 0)
		  
		  Var prices As New WakePriceTable
		  Var price As New WakeModelPrice("claude-opus-5-5")
		  price.OutputPerMillion = 1000000
		  prices.SetPrice(price)
		  text = Report(2, prices)
		  Assert.IsTrue(text.IndexOf("**" + WakeFormat.USD(190) + "**") >= 0, "estimate from the price table")
		End Sub
	#tag EndMethod


End Class
#tag EndClass
