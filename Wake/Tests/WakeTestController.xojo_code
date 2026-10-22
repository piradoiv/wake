#tag Class
Protected Class WakeTestController
Inherits TestController
	#tag Event
		Sub InitializeTestGroups()
		  // Every TestGroup subclass registers itself with this controller in its constructor.
		  Var group As TestGroup
		  
		  group = New HarnessTests(Self, "Harness")
		  group = New WakeCoreTests(Self, "WakeCore")
		  group = New ClaudeCodeParserTests(Self, "ClaudeCodeParser")
		  group = New WakeIndexTests(Self, "WakeIndex")
		  group = New WakeCatalogTests(Self, "WakeCatalog")
		  group = New WakeTimelineTests(Self, "WakeTimeline")
		  group = New WakeSearchTests(Self, "WakeSearch")
		  group = New WakeStatsTests(Self, "WakeStats")
		  group = New WakeMarkdownTests(Self, "WakeMarkdown")
		  group = New WakeCallPatternTests(Self, "WakeCallPattern")
		  group = New WakeTokenReportTests(Self, "WakeTokenReport")
		  group = New WakeContextTests(Self, "WakeContext")
		  group = New WakeNowhereTests(Self, "WakeNowhere")
		  group = New WakeFileChangesTests(Self, "WakeFileChanges")
		  group = New WakeFileHistoryTests(Self, "WakeFileHistory")
		  group = New WakeBlameTests(Self, "WakeBlame")
		  
		  #Pragma Unused group
		End Sub
	#tag EndEvent


End Class
#tag EndClass
