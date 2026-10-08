#tag Interface
Protected Interface IAgentParser
	#tag Method, Flags = &h0
		Function AgentID() As String

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DefaultRoots() As FolderItem()

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DisplayName() As String

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSessionFile(f As FolderItem) As Boolean

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParseSession(f As FolderItem) As WakeSession

		End Function
	#tag EndMethod


End Interface
#tag EndInterface
