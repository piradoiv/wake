#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // The wake command line. Everything it does is in WakeCLI (Core), which the desktop
		  // project's tests cover; this only wires it to Wake's folders and the terminal.
		  // args(0) is the program's own path.
		  Var words() As String
		  For i As Integer = 1 To args.LastIndex
		    words.Add(args(i))
		  Next

		  Var cli As New WakeCLI(WakeFolders.DefaultIndexFile, WakeFolders.AllRoots)
		  cli.Prices = WakePriceTable.Load(WakeFolders.PricesFile)
		  cli.HiddenProjects = WakeHiddenProjects.Load(WakeFolders.HiddenProjectsFile)
		  cli.Version = App.Version

		  Var here As FolderItem = SpecialFolder.CurrentWorkingDirectory
		  If here <> Nil Then cli.WorkingFolder = here.NativePath

		  Var code As Integer = cli.Run(words)
		  If cli.Output <> "" Then Print(cli.Output)
		  If cli.ErrorOutput <> "" Then StdErr.WriteLine(cli.ErrorOutput)
		  Return code
		End Function
	#tag EndEvent


End Class
#tag EndClass
