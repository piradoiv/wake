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
