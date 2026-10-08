#tag Class
Protected Class WakeStatsTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the fixtures and read it through a separate connection.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("projects"), mScratch.Child("projects"))
		  
		  Var writer As New WakeIndex(mScratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("projects")))
		  Call indexer.Run
		  writer.Close
		  
		  mIndex = New WakeIndex(mScratch.Child("index.sqlite"))
		  mIndex.Open
		  mCatalog = New WakeCatalog(mIndex)
		End Sub
	#tag EndEvent

	#tag Event
		Sub TearDown()
		  mCatalog = Nil
		  If mIndex <> Nil Then mIndex.Close
		  mIndex = Nil
		  TestSupport.RemoveScratchFolder(mScratch)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub CostFormatTest()
		  Var table As New WakePriceTable
		  table.SetPrice(OpusPrice)
		  
		  Var priced As New WakeTokenUsage
		  priced.OutputTokens = 1000000
		  Var unpriced As New WakeTokenUsage
		  unpriced.InputTokens = 10
		  
		  Var byModel As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  Assert.AreEqual(WakeFormat.kUnknown, WakeFormat.Cost(table.Estimate(byModel)), "no tokens")
		  
		  byModel.Value("claude-opus-5-5") = priced
		  Var amount As Double = 25.0
		  Var dollars As String = "$" + amount.ToString(Locale.Current, "#,##0.00")
		  Assert.AreEqual(dollars, WakeFormat.Cost(table.Estimate(byModel)))
		  
		  byModel.Value("local-model") = unpriced
		  Assert.AreEqual("≥ " + dollars, WakeFormat.Cost(table.Estimate(byModel)), "some models have no price")
		  
		  byModel.Remove("claude-opus-5-5")
		  Assert.AreEqual(WakeFormat.kNoPrice, WakeFormat.Cost(table.Estimate(byModel)))
		  
		  Assert.AreEqual("<$0.01", WakeFormat.USD(0.001))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EstimateTest()
		  Var table As New WakePriceTable
		  table.SetPrice(OpusPrice)
		  
		  Var opus As New WakeTokenUsage
		  opus.InputTokens = 1000000
		  Var other As New WakeTokenUsage
		  other.OutputTokens = 500
		  Var unused As New WakeTokenUsage
		  
		  Var byModel As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  byModel.Value("claude-opus-5-5") = opus
		  byModel.Value("local-model") = other
		  byModel.Value("idle-model") = unused
		  
		  Var estimate As WakeCostEstimate = table.Estimate(byModel)
		  Assert.AreEqual(5.0, estimate.AmountUSD, 0.000001)
		  Assert.IsFalse(estimate.IsComplete)
		  Assert.AreEqual(1000000, estimate.PricedTokens)
		  Assert.AreEqual(500, estimate.UnpricedTokens)
		  Var unpricedCount As Integer = estimate.UnpricedModels.Count
		  Assert.AreEqual(1, unpricedCount, "a model with no tokens needs no price")
		  Assert.AreEqual("local-model", estimate.UnpricedModels(0))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindGroup(groups() As WakeUsageGroup, key As String) As WakeUsageGroup
		  For Each g As WakeUsageGroup In groups
		    If g.Key = key Then Return g
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LocalDay(isoTime As String) As String
		  // The calendar day of isoTime in the local time zone, as the catalog groups it.
		  Var utc As DateTime = WakeCore.ParseISO8601(isoTime)
		  Var localTime As New DateTime(utc.SecondsFrom1970)
		  Return localTime.SQLDate
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ModelPriceCostTest()
		  Var usage As New WakeTokenUsage
		  usage.InputTokens = 1000000
		  usage.OutputTokens = 200000
		  usage.CacheWriteTokens = 400000
		  usage.CacheWrite1hTokens = 100000
		  usage.CacheReadTokens = 1000000
		  
		  // 5 + 5 + 300K × 6.25 + 100K × 10 + 0.5
		  Var price As WakeModelPrice = OpusPrice
		  Assert.AreEqual(13.375, price.Cost(usage), 0.000001)
		  
		  // Without a one-hour price, every cache write uses the five-minute price.
		  price.CacheWrite1hPerMillion = 0
		  Assert.AreEqual(13.0, price.Cost(usage), 0.000001)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OpusPrice() As WakeModelPrice
		  // Made-up prices, in dollars per million tokens.
		  Var price As New WakeModelPrice("claude-opus-5-5")
		  price.InputPerMillion = 5
		  price.OutputPerMillion = 25
		  price.CacheWritePerMillion = 6.25
		  price.CacheWrite1hPerMillion = 10
		  price.CacheReadPerMillion = 0.5
		  Return price
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParsePriceTest()
		  Var value As Double
		  
		  Assert.IsTrue(WakePriceTable.ParsePrice("3", value))
		  Assert.AreEqual(3.0, value, 0.000001)
		  
		  // The text the Prices window shows for a stored price must read back as the same price,
		  // whatever the locale. String.ToDouble read "3.00" as 300 in a Spanish locale.
		  Var shown As Double = 3.0
		  Assert.IsTrue(WakePriceTable.ParsePrice(shown.ToString(Locale.Raw, "0.00####"), value))
		  Assert.AreEqual(3.0, value, 0.000001, "round trip")
		  
		  Assert.IsTrue(WakePriceTable.ParsePrice("3,5", value))
		  Assert.AreEqual(3.5, value, 0.000001, "decimal comma")
		  Assert.IsTrue(WakePriceTable.ParsePrice(" $0.30 ", value))
		  Assert.AreEqual(0.3, value, 0.000001, "dollar sign")
		  Assert.IsTrue(WakePriceTable.ParsePrice(".5", value))
		  Assert.AreEqual(0.5, value, 0.000001)
		  
		  For Each bad As String In Array("", "abc", "-1", "1.2.3", "1,234.5", "1e3", ".")
		    Assert.IsFalse(WakePriceTable.ParsePrice(bad, value), "rejects """ + bad + """")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParserCountsUsagePerResponseTest()
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var count As Integer = session.UsageEntries.Count
		  Assert.AreEqual(6, count, "one entry per response")
		  Assert.AreEqual("claude-opus-5-5", session.UsageEntries(0).Model)
		  Assert.IsNotNil(session.UsageEntries(0).Timestamp)
		  Assert.AreEqual(10, session.UsageEntries(0).Usage.InputTokens)
		  
		  // The fixtures write every cache write with a one-hour lifetime.
		  Assert.AreEqual(700, session.Usage.CacheWrite1hTokens)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PriceFileTest()
		  Var f As FolderItem = mScratch.Child("prices.json")
		  
		  Var missing As WakePriceTable = WakePriceTable.Load(f)
		  Var modelCount As Integer = missing.Models.Count
		  Assert.AreEqual(0, modelCount)
		  Assert.AreEqual("", missing.LoadError, "a missing file is not an error")
		  
		  Var table As New WakePriceTable
		  table.SetPrice(OpusPrice)
		  table.Save(f)
		  
		  Var loaded As WakePriceTable = WakePriceTable.Load(f)
		  Assert.AreEqual("", loaded.LoadError)
		  Var price As WakeModelPrice = loaded.PriceFor("claude-opus-5-5")
		  Assert.IsNotNil(price)
		  Assert.AreEqual(5.0, price.InputPerMillion, 0.000001)
		  Assert.AreEqual(25.0, price.OutputPerMillion, 0.000001)
		  Assert.AreEqual(6.25, price.CacheWritePerMillion, 0.000001)
		  Assert.AreEqual(10.0, price.CacheWrite1hPerMillion, 0.000001)
		  Assert.AreEqual(0.5, price.CacheReadPerMillion, 0.000001)
		  
		  loaded.RemovePrice("claude-opus-5-5")
		  Assert.IsNil(loaded.PriceFor("claude-opus-5-5"))
		  
		  TestSupport.AppendLine(f, "not json")
		  Var broken As WakePriceTable = WakePriceTable.Load(f)
		  Assert.AreNotEqual("", broken.LoadError, "a damaged file is reported")
		  modelCount = broken.Models.Count
		  Assert.AreEqual(0, modelCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PriceForDatedModelTest()
		  Var table As New WakePriceTable
		  Var haiku As New WakeModelPrice("claude-haiku-4-5")
		  table.SetPrice(haiku)
		  Var opus As New WakeModelPrice("claude-opus-5")
		  table.SetPrice(opus)
		  
		  Assert.AreSame(haiku, table.PriceFor("claude-haiku-4-5"))
		  Assert.AreSame(haiku, table.PriceFor("claude-haiku-4-5-20251001"), "dated name")
		  Assert.IsNil(table.PriceFor("claude-haiku-4-5-preview"))
		  Assert.IsNil(table.PriceFor("claude-opus-5-5"), "a different model, not a dated name")
		  Assert.IsNil(table.PriceFor("Claude-Haiku-4-5"), "names are case-sensitive")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionUsageTest()
		  Var s4 As WakeSessionInfo
		  For Each s As WakeSessionInfo In mCatalog.Sessions("", 0)
		    If s.UID = TestSupport.ClaudeFixtureID(4) Then s4 = s
		  Next
		  
		  Var g As WakeUsageGroup = mCatalog.SessionUsage(s4.ID)
		  Assert.AreEqual(25, WakeTokenUsage(g.ByModel.Value("claude-opus-5-5").ObjectValue).InputTokens)
		  Assert.AreEqual(110, WakeTokenUsage(g.ByModel.Value("claude-haiku-4-5-20251001").ObjectValue).InputTokens, "subagent included")
		  Assert.AreEqual(s4.TotalUsage.Total, g.Total.Total)
		  Assert.AreEqual(100, g.Total.CacheWrite1hTokens)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsageByDayTest()
		  Var groups() As WakeUsageGroup = mCatalog.Usage(WakeCatalog.UsageGroupings.Day)
		  Var count As Integer = groups.Count
		  Assert.AreEqual(5, count, "one day per session with responses")
		  Assert.AreEqual(LocalDay("2026-09-05T18:30:01.000Z"), groups(0).Key, "newest first")
		  
		  Var day1 As WakeUsageGroup = FindGroup(groups, LocalDay("2026-09-01T10:00:02.000Z"))
		  Assert.IsNotNil(day1)
		  Assert.AreEqual(100, day1.Total.InputTokens)
		  Assert.AreEqual(1000, day1.Total.CacheWrite1hTokens)
		  Assert.AreEqual(1, day1.SessionCount)
		  
		  Var day4 As WakeUsageGroup = FindGroup(groups, LocalDay("2026-09-04T12:00:01.000Z"))
		  Assert.AreEqual(135, day4.Total.InputTokens, "subagent usage counts toward its day")
		  Assert.AreEqual(1, day4.SessionCount, "a subagent is not a session of its own")
		  
		  // Only responses from the start of 4 September (UTC) on.
		  Var periodStart As DateTime = WakeCore.ParseISO8601("2026-09-04T00:00:00.000Z")
		  groups = mCatalog.Usage(WakeCatalog.UsageGroupings.Day, periodStart)
		  count = groups.Count
		  Assert.AreEqual(2, count, "period")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsageByModelTest()
		  Var groups() As WakeUsageGroup = mCatalog.Usage(WakeCatalog.UsageGroupings.Model)
		  Var count As Integer = groups.Count
		  Assert.AreEqual(2, count)
		  
		  Assert.AreEqual("claude-opus-5-5", groups(0).Key, "most tokens first")
		  Assert.AreEqual(164, groups(0).Total.InputTokens)
		  Assert.AreEqual(5, groups(0).SessionCount)
		  
		  Assert.AreEqual("claude-haiku-4-5-20251001", groups(1).Key)
		  Assert.AreEqual(110, groups(1).Total.InputTokens)
		  Assert.AreEqual(25, groups(1).Total.OutputTokens)
		  Assert.AreEqual(1, groups(1).SessionCount)
		  
		  Var models() As String = mCatalog.Models
		  count = models.Count
		  Assert.AreEqual(2, count)
		  Assert.AreEqual("claude-haiku-4-5-20251001", models(0))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsageByProjectTest()
		  Var projects() As WakeProjectInfo = mCatalog.Projects
		  Var demoApp As WakeProjectInfo = projects(0)
		  Assert.AreEqual("demo.app", demoApp.Name)
		  
		  Var groups() As WakeUsageGroup = mCatalog.Usage(WakeCatalog.UsageGroupings.Project)
		  Var count As Integer = groups.Count
		  Assert.AreEqual(2, count)
		  Assert.AreEqual("/Users/dev/demo", groups(0).Label)
		  Assert.AreEqual("claude-code", groups(0).AgentID)
		  Assert.AreEqual(267, groups(0).Total.InputTokens)
		  Assert.AreEqual(4, groups(0).SessionCount)
		  Assert.AreEqual(demoApp.ID.ToString, groups(1).Key)
		  Assert.AreEqual(7, groups(1).Total.InputTokens)
		  
		  // Filtered to one project.
		  groups = mCatalog.Usage(WakeCatalog.UsageGroupings.Model, Nil, "", demoApp.ID)
		  count = groups.Count
		  Assert.AreEqual(1, count)
		  Assert.AreEqual(7, groups(0).Total.InputTokens)
		  
		  groups = mCatalog.Usage(WakeCatalog.UsageGroupings.Model, Nil, "other-agent")
		  count = groups.Count
		  Assert.AreEqual(0, count, "agent filter")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsageBySessionTest()
		  Var groups() As WakeUsageGroup = mCatalog.Usage(WakeCatalog.UsageGroupings.Session)
		  Var count As Integer = groups.Count
		  Assert.AreEqual(5, count, "the empty session has no usage")
		  
		  Var s2 As WakeUsageGroup = FindGroup(groups, "")
		  Assert.IsNil(s2)
		  For Each g As WakeUsageGroup In groups
		    If g.Label = TestSupport.ClaudeFixtureID(2) Then s2 = g
		  Next
		  Assert.IsNotNil(s2)
		  Assert.AreEqual(22, s2.Total.InputTokens)
		  Assert.AreEqual(17500, s2.Total.CacheReadTokens)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCatalog As WakeCatalog
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScratch As FolderItem
	#tag EndProperty


End Class
#tag EndClass
