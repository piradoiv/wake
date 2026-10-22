#tag Class
Protected Class WakeFileNode
	#tag Method, Flags = &h21
		Private Sub AddChild(node As WakeFileNode)
		  node.ProjectID = ProjectID
		  node.ProjectPath = ProjectPath
		  node.AgentID = AgentID
		  Children.Add(node)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTotals(other As WakeFileNode)
		  Edits = Edits + other.Edits
		  LinesAdded = LinesAdded + other.LinesAdded
		  LinesRemoved = LinesRemoved + other.LinesRemoved
		  Reads = Reads + other.Reads
		  Tokens = Tokens + other.Tokens
		  If other.LastChanged <> Nil And (LastChanged Is Nil Or other.LastChanged > LastChanged) Then LastChanged = other.LastChanged
		  For Each key As Variant In other.mSessions.Keys
		    mSessions.Value(key) = True
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Build(files() As WakeChangedFile) As WakeFileNode()
		  // A tree per project of the files in files, in the order their projects first appear. Folders
		  // sum their files, a chain of folders that each hold only one folder becomes one node
		  // (src/app), and files outside the project folder go in a last Outside node. Children are
		  // sorted by name.
		  Var projects() As WakeFileNode
		  Var byProject As New Dictionary

		  For Each f As WakeChangedFile In files
		    Var project As WakeFileNode
		    If byProject.HasKey(f.ProjectID) Then
		      project = WakeFileNode(byProject.Value(f.ProjectID).ObjectValue)
		    Else
		      project = New WakeFileNode(Kinds.Project, f.ProjectPath)
		      project.Path = f.ProjectPath
		      project.ProjectID = f.ProjectID
		      project.ProjectPath = f.ProjectPath
		      project.AgentID = f.AgentID
		      byProject.Value(f.ProjectID) = project
		      projects.Add(project)
		    End If

		    Var parent As WakeFileNode = project
		    If f.IsOutside Then parent = project.Child(Kinds.Outside, kOutsideName)

		    Var separator As String = If(f.Path.IndexOf("/") < 0 And f.Path.IndexOf("\") >= 0, "\", "/")
		    Var parts() As String = SplitPath(f.Path, separator)
		    If parts.Count = 0 Then Continue

		    For i As Integer = 0 To parts.LastIndex - 1
		      parent = parent.Child(Kinds.Folder, parts(i), separator)
		    Next

		    Var leaf As New WakeFileNode(Kinds.File, parts(parts.LastIndex))
		    leaf.Path = f.Path
		    leaf.File = f
		    parent.AddChild(leaf)
		  Next

		  For Each project As WakeFileNode In projects
		    project.Collapse
		    Call project.Total
		    project.Sort(Columns.Name, True)
		  Next

		  Return projects
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Child(kind As Kinds, childName As String, separator As String = "/") As WakeFileNode
		  // The child folder (or Outside node) with that name, added when it isn't there yet.
		  For Each node As WakeFileNode In Children
		    If node.Kind = kind And node.Name.Compare(childName, ComparisonOptions.CaseSensitive) = 0 Then Return node
		  Next

		  Var node As New WakeFileNode(kind, childName)
		  node.Path = If(Self.Kind = Kinds.Folder, Path + separator + childName, childName)
		  node.mSeparator = separator
		  AddChild(node)
		  Return node
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Collapse()
		  // Merges each folder that holds only one folder, and nothing else, with it.
		  For Each node As WakeFileNode In Children
		    If node.Kind = Kinds.Folder Then
		      While node.Children.Count = 1 And node.Children(0).Kind = Kinds.Folder
		        Var only As WakeFileNode = node.Children(0)
		        node.Name = node.Name + node.mSeparator + only.Name
		        node.Path = only.Path
		        node.Children = only.Children
		      Wend
		    End If
		    node.Collapse
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function Compare(a As WakeFileNode, b As WakeFileNode, column As Columns) As Integer
		  // Below zero when a comes first in ascending order. Ties go by name.
		  Var difference As Double
		  Select Case column
		  Case Columns.Edits
		    difference = a.Edits - b.Edits
		  Case Columns.Sessions
		    difference = a.SessionCount - b.SessionCount
		  Case Columns.Lines
		    difference = (a.LinesAdded + a.LinesRemoved) - (b.LinesAdded + b.LinesRemoved)
		  Case Columns.Reads
		    difference = a.Reads - b.Reads
		  Case Columns.LastChanged
		    Var aTime As Double = If(a.LastChanged Is Nil, 0.0, a.LastChanged.SecondsFrom1970)
		    Var bTime As Double = If(b.LastChanged Is Nil, 0.0, b.LastChanged.SecondsFrom1970)
		    difference = aTime - bTime
		  Case Columns.Tokens
		    difference = a.Tokens - b.Tokens
		  End Select

		  If difference < 0 Then Return -1
		  If difference > 0 Then Return 1
		  Return a.Name.Compare(b.Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(kind As Kinds, name As String)
		  Self.Kind = kind
		  Self.Name = name
		  mSessions = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsFolder() As Boolean
		  Return Kind <> Kinds.File
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SessionCount() As Integer
		  Return mSessions.KeyCount
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Sort(column As Columns, ascending As Boolean)
		  // Sorts the children at every level. The Outside node stays last.
		  Var sorted() As WakeFileNode
		  For Each node As WakeFileNode In Children
		    Var at As Integer = sorted.Count
		    If node.Kind <> Kinds.Outside Then
		      For i As Integer = 0 To sorted.LastIndex
		        Var order As Integer = Compare(node, sorted(i), column)
		        If Not ascending Then order = -order
		        If sorted(i).Kind = Kinds.Outside Or order < 0 Then
		          at = i
		          Exit
		        End If
		      Next
		    End If
		    sorted.AddAt(at, node)
		    node.Sort(column, ascending)
		  Next
		  Children = sorted
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function SplitPath(path As String, separator As String) As String()
		  // The parts of a path. A leading separator stays on the first part, so /Users/dev reads as
		  // "/Users" and "dev".
		  Var parts() As String
		  Var leading As String = If(path.BeginsWith(separator), separator, "")
		  For Each part As String In path.Split(separator)
		    If part = "" Then Continue
		    If parts.Count = 0 Then part = leading + part
		    parts.Add(part)
		  Next
		  Return parts
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Total() As WakeFileNode
		  // Fills a folder's figures from its children, and a file's from its WakeChangedFile.
		  If File <> Nil Then
		    Edits = File.Edits
		    LinesAdded = File.LinesAdded
		    LinesRemoved = File.LinesRemoved
		    Reads = File.Reads
		    Tokens = File.Tokens
		    LastChanged = File.LastChanged
		    For Each id As Integer In File.SessionIDs
		      mSessions.Value(id) = True
		    Next
		    Return Self
		  End If

		  For Each node As WakeFileNode In Children
		    AddTotals(node.Total)
		  Next
		  Return Self
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Children() As WakeFileNode
	#tag EndProperty

	#tag Property, Flags = &h0
		Edits As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		File As WakeChangedFile
	#tag EndProperty

	#tag Property, Flags = &h0
		Kind As Kinds
	#tag EndProperty

	#tag Property, Flags = &h0
		LastChanged As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		LinesAdded As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LinesRemoved As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSeparator As String = "/"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSessions As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Reads As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Tokens As Int64
	#tag EndProperty


	#tag Constant, Name = kOutsideName, Type = String, Dynamic = False, Default = \"Outside the project", Scope = Public
	#tag EndConstant


	#tag Enum, Name = Columns, Type = Integer, Flags = &h0
		Name
		  Edits
		  Sessions
		  Lines
		  Reads
		  LastChanged
		Tokens
	#tag EndEnum

	#tag Enum, Name = Kinds, Type = Integer, Flags = &h0
		Project
		  Outside
		  Folder
		File
	#tag EndEnum


End Class
#tag EndClass
