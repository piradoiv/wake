#tag Class
Protected Class WakeIndexRoot
	#tag Method, Flags = &h0
		Sub Constructor(agentID As String, folder As FolderItem, isCustom As Boolean = False)
		  Self.AgentID = agentID
		  Self.Folder = folder
		  Self.IsCustom = isCustom
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Folder As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		IsCustom As Boolean
	#tag EndProperty


End Class
#tag EndClass
