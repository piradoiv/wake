#tag Module
Protected Module WakeSidebar
	#tag Method, Flags = &h0
		Sub MakeTranslucent(list As DesktopTable)
		  // On macOS, puts the list on the sidebar material, as Finder and Mail do: a visual effect view,
		  // blending with what is behind the window and dimming when it is inactive, sits under the
		  // list's scroll view and fills the control. On macOS the list is a view holding a scroll view,
		  // and only the selected rows are drawn opaque, so the material shows through everywhere else.
		  // The border is turned off. Safe to call again. Elsewhere this does nothing, and the list keeps
		  // its look.
		  #If TargetMacOS
		    Const kMaterialSidebar = 7
		    Const kBlendingBehindWindow = 0
		    Const kStateFollowsWindow = 0
		    Const kWindowBelow = -1

		    Declare Function NSClassFromString Lib "Foundation" (name As CFStringRef) As Ptr
		    Declare Function Alloc Lib "Foundation" Selector "alloc" (cls As Ptr) As Ptr
		    Declare Function Init Lib "Foundation" Selector "init" (obj As Ptr) As Ptr
		    Declare Sub Release Lib "Foundation" Selector "release" (obj As Ptr)
		    Declare Function IsKindOfClass Lib "Foundation" Selector "isKindOfClass:" (obj As Ptr, cls As Ptr) As Boolean
		    Declare Function Subviews Lib "AppKit" Selector "subviews" (view As Ptr) As Ptr
		    Declare Function ItemCount Lib "Foundation" Selector "count" (nsArray As Ptr) As UInteger
		    Declare Function ObjectAtIndex Lib "Foundation" Selector "objectAtIndex:" (nsArray As Ptr, index As UInteger) As Ptr
		    Declare Sub AddSubview Lib "AppKit" Selector "addSubview:positioned:relativeTo:" (view As Ptr, subview As Ptr, place As Integer, other As Ptr)
		    Declare Sub SetDrawsBackground Lib "AppKit" Selector "setDrawsBackground:" (view As Ptr, value As Boolean)
		    Declare Sub SetMaterial Lib "AppKit" Selector "setMaterial:" (view As Ptr, material As Integer)
		    Declare Sub SetBlendingMode Lib "AppKit" Selector "setBlendingMode:" (view As Ptr, mode As Integer)
		    Declare Sub SetState Lib "AppKit" Selector "setState:" (view As Ptr, state As Integer)
		    Declare Sub SetTranslatesAutoresizing Lib "AppKit" Selector "setTranslatesAutoresizingMaskIntoConstraints:" (view As Ptr, value As Boolean)
		    Declare Function LeadingAnchor Lib "AppKit" Selector "leadingAnchor" (view As Ptr) As Ptr
		    Declare Function TrailingAnchor Lib "AppKit" Selector "trailingAnchor" (view As Ptr) As Ptr
		    Declare Function TopAnchor Lib "AppKit" Selector "topAnchor" (view As Ptr) As Ptr
		    Declare Function BottomAnchor Lib "AppKit" Selector "bottomAnchor" (view As Ptr) As Ptr
		    Declare Function ConstraintEqualToAnchor Lib "AppKit" Selector "constraintEqualToAnchor:" (anchor As Ptr, other As Ptr) As Ptr
		    Declare Sub SetActive Lib "AppKit" Selector "setActive:" (constraint As Ptr, value As Boolean)

		    Var effectClass As Ptr = NSClassFromString("NSVisualEffectView")
		    Var scrollClass As Ptr = NSClassFromString("NSScrollView")
		    Var control As Ptr = list.Handle
		    If control = Nil Or effectClass = Nil Then Return

		    // The scroll view draws nothing behind the rows today. Turning that off again keeps it so.
		    Var views As Ptr = Subviews(control)
		    For index As Integer = 0 To ItemCount(views) - 1
		      Var child As Ptr = ObjectAtIndex(views, index)
		      If IsKindOfClass(child, effectClass) Then Return
		      If IsKindOfClass(child, scrollClass) Then SetDrawsBackground(child, False)
		    Next

		    Var effect As Ptr = Init(Alloc(effectClass))
		    SetMaterial(effect, kMaterialSidebar)
		    SetBlendingMode(effect, kBlendingBehindWindow)
		    SetState(effect, kStateFollowsWindow)
		    SetTranslatesAutoresizing(effect, False)
		    AddSubview(control, effect, kWindowBelow, Nil)
		    Release(effect)

		    // Constraints keep it the size of the control as the window resizes.
		    SetActive(ConstraintEqualToAnchor(LeadingAnchor(effect), LeadingAnchor(control)), True)
		    SetActive(ConstraintEqualToAnchor(TrailingAnchor(effect), TrailingAnchor(control)), True)
		    SetActive(ConstraintEqualToAnchor(TopAnchor(effect), TopAnchor(control)), True)
		    SetActive(ConstraintEqualToAnchor(BottomAnchor(effect), BottomAnchor(control)), True)

		    list.HasBorder = False
		  #Else
		    #Pragma Unused list
		  #EndIf
		End Sub
	#tag EndMethod


End Module
#tag EndModule
