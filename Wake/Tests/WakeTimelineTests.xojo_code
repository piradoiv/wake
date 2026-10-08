#tag Class
Protected Class WakeTimelineTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function BlockID(html As String, method As String) As String
		  // The id in the first wakeLoad('<method>','<id>', ...) call of the page.
		  Var marker As String = "wakeLoad('" + method + "','"
		  Var start As Integer = html.IndexOf(marker)
		  If start < 0 Then Return ""
		  
		  start = start + marker.Length
		  Var finish As Integer = html.IndexOf(start, "'")
		  If finish < 0 Then Return ""
		  Return html.Middle(start, finish - start)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CountOf(text As String, find As String) As Integer
		  Var total As Integer
		  Var pos As Integer = text.IndexOf(find)
		  While pos >= 0
		    total = total + 1
		    pos = text.IndexOf(pos + find.Length, find)
		  Wend
		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EditDiffTest()
		  Var html As String = FixturePage(2)
		  
		  Assert.IsTrue(html.IndexOf("<div class=""dl hunk"">@@ -1,3 +1,3 @@</div>") >= 0, "hunk header")
		  Assert.IsTrue(html.IndexOf("<div class=""dl del"">-  return split(s, &#39;,&#39;);</div>") >= 0, "removed line")
		  Assert.IsTrue(html.IndexOf("<div class=""dl add"">+  return split_quoted(s, &#39;,&#39;);</div>") >= 0, "added line")
		  Assert.IsTrue(html.IndexOf("<div class=""dl add"">+# Notes</div>") >= 0, "Write shows the new file as added")
		  Assert.IsTrue(html.IndexOf("<span class=""add"">+1</span> <span class=""del"">−1</span>") >= 0, "edit line counts")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EscapesTranscriptTextTest()
		  Var s As New WakeSession
		  Var e As WakeEvent = s.AddEvent(WakeEvent.Kinds.UserPrompt, Nil)
		  e.Text = "<script>alert(""x"")</script> & 'co'"
		  
		  Var timeline As New WakeTimeline(s)
		  Var html As String = timeline.HTML
		  Assert.IsTrue(html.IndexOf("&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt; &amp; &#39;co&#39;") >= 0, "escaped")
		  Assert.AreEqual(-1, html.IndexOf("<script>alert"), "never raw")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FixturePage(sessionNumber As Integer) As String
		  Var timeline As New WakeTimeline(TestSupport.ParseClaudeFixture(sessionNumber))
		  Return timeline.HTML
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LongOutputExpandsOnDemandTest()
		  Var lines() As String
		  For i As Integer = 1 To 500
		    lines.Add("line " + i.ToString)
		  Next
		  
		  Var s As New WakeSession
		  Var e As WakeEvent = s.AddEvent(WakeEvent.Kinds.ToolCall, Nil)
		  e.ToolName = "Read"
		  e.HasResult = True
		  e.ResultText = String.FromArray(lines, &u0A)
		  
		  Var timeline As New WakeTimeline(s)
		  Var html As String = timeline.HTML
		  Assert.IsTrue(html.IndexOf("line 40" + &u0A) < 0 And html.IndexOf("line 40<") >= 0, "preview ends at line 40")
		  Assert.AreEqual(-1, html.IndexOf("line 499"), "the rest is not in the page")
		  Assert.IsTrue(html.IndexOf("Show all 500 lines") >= 0, "expand button")
		  
		  Var id As String = BlockID(html, "expand")
		  Assert.AreNotEqual("", id)
		  Var expanded As String = timeline.Request("expand", id)
		  Assert.IsTrue(expanded.IndexOf("line 499" + &u0A + "line 500") >= 0, "full text on request")
		  Assert.IsTrue(expanded.BeginsWith("line 1" + &u0A), expanded.Left(40))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MissingTranscriptTest()
		  Var timeline As WakeTimeline = WakeTimeline.Load("claude-code", "/no/such/folder/session.jsonl")
		  Var html As String = timeline.HTML
		  Assert.IsTrue(html.IndexOf("Partially parsed") >= 0)
		  Assert.IsTrue(html.IndexOf("no longer at /no/such/folder/session.jsonl") >= 0)
		  
		  timeline = WakeTimeline.Load("no-such-agent", "")
		  html = timeline.HTML
		  Assert.IsTrue(html.IndexOf("can&#39;t read sessions of agent &quot;no-such-agent&quot;") >= 0, "unknown agent")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NoRemoteResourcesTest()
		  For Each n As Integer In Array(1, 2, 3, 4)
		    Var html As String = FixturePage(n)
		    Var label As String = "fixture " + n.ToString
		    
		    Assert.IsTrue(html.IndexOf("Content-Security-Policy"" content=""default-src 'none';") >= 0, label + ": content policy")
		    Assert.AreEqual(-1, html.IndexOf(" src="), label + ": src")
		    Assert.AreEqual(-1, html.IndexOf("href="), label + ": href")
		    Assert.AreEqual(-1, html.IndexOf("<link"), label + ": link")
		    Assert.AreEqual(-1, html.IndexOf("@import"), label + ": @import")
		    Assert.AreEqual(-1, html.IndexOf("url("), label + ": url(")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseNoteTest()
		  Var html As String = FixturePage(3)
		  Assert.IsTrue(html.IndexOf("<b>Partially parsed.</b>") >= 0)
		  Assert.IsTrue(html.IndexOf("3 malformed lines") >= 0)
		  Assert.IsTrue(html.IndexOf("&quot;future-record-kind&quot;") >= 0)
		  
		  html = FixturePage(1)
		  Assert.AreEqual(-1, html.IndexOf("Partially parsed"), "complete session has no note")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PersistedOutputOnDemandTest()
		  Var timeline As New WakeTimeline(TestSupport.ParseClaudeFixture(2))
		  Var html As String = timeline.HTML
		  
		  Assert.IsTrue(html.IndexOf("Saved separately, 2.0 KB.") >= 0)
		  Assert.AreEqual(-1, html.IndexOf("test_case_1"), "not read until asked for")
		  
		  Var id As String = BlockID(html, "persisted")
		  Assert.AreNotEqual("", id)
		  Var loaded As String = timeline.Request("persisted", id)
		  Assert.IsTrue(loaded.IndexOf("ok 1 - test_case_1" + &u0A) >= 0, loaded.Left(200))
		  Assert.IsTrue(loaded.IndexOf("Show all 120 lines") >= 0, "the file itself is long, so it is previewed too")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SubagentTest()
		  Var html As String = FixturePage(4)
		  
		  Assert.AreEqual(1, CountOf(html, "<details class=""subagent"">"))
		  Assert.IsTrue(html.IndexOf("Subagent · Explore · Find TODOs") >= 0)
		  Assert.IsTrue(html.IndexOf("main.c:10: // TODO handle escapes") >= 0, "subagent's own tool result")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SystemEventsTest()
		  // The /clear wrapper is summarised without its tags; the full text stays in the body.
		  Var html As String = FixturePage(3)
		  
		  Assert.IsTrue(html.IndexOf("/clear clear</summary>") >= 0, "summary drops the tags")
		  Assert.IsTrue(html.IndexOf("&lt;command-name&gt;/clear&lt;/command-name&gt;") >= 0, "full text in the body")
		  Assert.IsTrue(html.IndexOf("Context limit nearly reached</div>") >= 0, "one-line system message")
		  Assert.IsTrue(html.IndexOf("<section class=""card error"">") >= 0, "synthetic API error")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToolCallsTest()
		  Var html As String = FixturePage(2)
		  
		  Assert.AreEqual(6, CountOf(html, "<details class=""tool-call"), "every tool call is collapsible")
		  Assert.AreEqual(1, CountOf(html, "<details class=""tool-call failed"">"), "the failing Bash call")
		  Assert.IsTrue(html.IndexOf("<code>$ make test</code><span class=""badge error"">error</span>") >= 0)
		  Assert.IsTrue(html.IndexOf("FAIL test_csv: expected 3 fields, got 2") >= 0, "stdout")
		  Assert.IsTrue(html.IndexOf("<span class=""tool"">Read</span> /Users/dev/demo/test.c") >= 0, "input summary")
		  Assert.AreEqual(-1, html.IndexOf("has been updated successfully"), "successful edit results are hidden")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UnknownRequestTest()
		  Var timeline As New WakeTimeline(TestSupport.ParseClaudeFixture(1))
		  Call timeline.HTML
		  Assert.AreEqual("", timeline.Request("bogus", "b1"))
		  Assert.AreEqual("", timeline.Request("expand", "b999"))
		  Assert.AreEqual("", timeline.Request("persisted", ""))
		End Sub
	#tag EndMethod


End Class
#tag EndClass
