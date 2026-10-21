#tag Module
Protected Module WakeTitleBar
	#tag Method, Flags = &h0
		Function HandleMouseDown(w As DesktopWindow, y As Integer) As Boolean
		  // Called from the window's MouseDown, which only fires outside controls. In the bar, a press
		  // drags the window and a double-click does what the user chose in System Settings, as an
		  // empty part of a native title bar would. True when the press was in the bar.
		  #If TargetMacOS
		    If y >= Height(w) Then Return False

		    Declare Function NSClassFromString Lib "Foundation" (name As CFStringRef) As Ptr
		    Declare Function SharedApplication Lib "AppKit" Selector "sharedApplication" (cls As Ptr) As Ptr
		    Declare Function CurrentEvent Lib "AppKit" Selector "currentEvent" (app As Ptr) As Ptr
		    Declare Function ClickCount Lib "AppKit" Selector "clickCount" (nsEvent As Ptr) As Integer
		    Declare Sub PerformWindowDrag Lib "AppKit" Selector "performWindowDragWithEvent:" (window As Ptr, nsEvent As Ptr)
		    Declare Function StandardUserDefaults Lib "Foundation" Selector "standardUserDefaults" (cls As Ptr) As Ptr
		    Declare Function StringForKey Lib "Foundation" Selector "stringForKey:" (defaults As Ptr, key As CFStringRef) As CFStringRef
		    Declare Sub Miniaturize Lib "AppKit" Selector "miniaturize:" (window As Ptr, sender As Ptr)
		    Declare Sub Zoom Lib "AppKit" Selector "zoom:" (window As Ptr, sender As Ptr)

		    Var nsEvent As Ptr = CurrentEvent(SharedApplication(NSClassFromString("NSApplication")))
		    If nsEvent = Nil Then Return True

		    If ClickCount(nsEvent) = 2 Then
		      Var defaults As Ptr = StandardUserDefaults(NSClassFromString("NSUserDefaults"))
		      Var action As String = StringForKey(defaults, "AppleActionOnDoubleClick")
		      Select Case action
		      Case "None"
		      Case "Minimize"
		        Miniaturize(w.Handle, Nil)
		      Else
		        Zoom(w.Handle, Nil)
		      End Select
		    Else
		      PerformWindowDrag(w.Handle, nsEvent)
		    End If
		    Return True
		  #Else
		    #Pragma Unused w
		    #Pragma Unused y
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Height(w As DesktopWindow) As Integer
		  // The height of the unified bar over the window's content, or 0 for a window that isn't unified.
		  #If TargetMacOS
		    If Not IsUnified(w) Then Return 0

		    Var frame As MemoryBlock = RectOf(w.Handle, "frame")
		    Var content As MemoryBlock = RectOf(w.Handle, "contentLayoutRect")
		    If frame Is Nil Or content Is Nil Then Return 0
		    Return Round(frame.DoubleValue(24) - content.DoubleValue(24))
		  #Else
		    #Pragma Unused w
		    Return 0
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsUnified(w As DesktopWindow) As Boolean
		  // True once Unify has merged the window's title bar with its content.
		  #If TargetMacOS
		    Const kFullSizeContentView As UInteger = &h8000

		    Declare Function StyleMask Lib "AppKit" Selector "styleMask" (window As Ptr) As UInteger

		    Return (StyleMask(w.Handle) And kFullSizeContentView) <> 0
		  #Else
		    #Pragma Unused w
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftInset(w As DesktopWindow) As Integer
		  // Where controls in the bar can start: past the close, minimize and zoom buttons.
		  Const kMargin = 12

		  #If TargetMacOS
		    Const kZoomButton = 2
		    Const kGap = 14

		    Declare Function StandardWindowButton Lib "AppKit" Selector "standardWindowButton:" (window As Ptr, kind As Integer) As Ptr

		    Var zoom As Ptr = StandardWindowButton(w.Handle, kZoomButton)
		    If zoom = Nil Then Return kMargin
		    Var frame As MemoryBlock = RectOf(zoom, "frame")
		    If frame Is Nil Then Return kMargin
		    Return Round(frame.DoubleValue(0) + frame.DoubleValue(16)) + kGap
		  #Else
		    #Pragma Unused w
		    Return kMargin
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RectOf(obj As Ptr, key As String) As MemoryBlock
		  // Reads an NSRect property through key-value coding, which boxes it in an NSValue, so no
		  // declare has to return a structure. Origin x and y, then width and height, as Doubles.
		  #If TargetMacOS
		    Declare Function ValueForKey Lib "Foundation" Selector "valueForKey:" (obj As Ptr, key As CFStringRef) As Ptr
		    Declare Sub GetValue Lib "Foundation" Selector "getValue:size:" (value As Ptr, buffer As Ptr, size As UInteger)

		    Var value As Ptr = ValueForKey(obj, key)
		    If value = Nil Then Return Nil

		    Var rect As New MemoryBlock(32)
		    GetValue(value, rect, rect.Size)
		    Return rect
		  #Else
		    #Pragma Unused obj
		    #Pragma Unused key
		    Return Nil
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RowTop(w As DesktopWindow, controlHeight As Integer) As Integer
		  // The Top that centres a control of this height on the close, minimize and zoom buttons. They
		  // sit above the middle of the bar, so centring on the bar puts controls too low.
		  #If TargetMacOS
		    Const kZoomButton = 2

		    Declare Function StandardWindowButton Lib "AppKit" Selector "standardWindowButton:" (window As Ptr, kind As Integer) As Ptr
		    Declare Function Superview Lib "AppKit" Selector "superview" (view As Ptr) As Ptr
		    Declare Function IsFlipped Lib "AppKit" Selector "isFlipped" (view As Ptr) As Boolean

		    Var fallback As Integer = (Height(w) - controlHeight) \ 2
		    Var zoom As Ptr = StandardWindowButton(w.Handle, kZoomButton)
		    If zoom = Nil Then Return fallback
		    Var parent As Ptr = Superview(zoom)
		    If parent = Nil Then Return fallback

		    // The buttons' view runs along the top of the window, so its top is the window's top.
		    Var button As MemoryBlock = RectOf(zoom, "frame")
		    Var bar As MemoryBlock = RectOf(parent, "frame")
		    If button Is Nil Or bar Is Nil Then Return fallback

		    Var middle As Double
		    If IsFlipped(parent) Then
		      middle = button.DoubleValue(8) + button.DoubleValue(24) / 2
		    Else
		      middle = bar.DoubleValue(24) - button.DoubleValue(8) - button.DoubleValue(24) / 2
		    End If
		    Return Round(middle - controlHeight / 2)
		  #Else
		    #Pragma Unused w
		    #Pragma Unused controlHeight
		    Return 0
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetToolbarSymbols(w As DesktopWindow, symbols() As String)
		  // Gives the window's toolbar items, in order, these SF Symbols as AppKit's own images, which the
		  // toolbar sizes as in Apple's apps (Xojo's own symbol images come out smaller), and shows the
		  // arrow on items with a menu. Xojo may redraw an item when its caption changes, so call this
		  // again after changing one.
		  #If TargetMacOS
		    Declare Function NSClassFromString Lib "Foundation" (name As CFStringRef) As Ptr
		    Declare Function NSSelectorFromString Lib "Foundation" (name As CFStringRef) As Ptr
		    Declare Function RespondsToSelector Lib "Foundation" Selector "respondsToSelector:" (obj As Ptr, sel As Ptr) As Boolean
		    Declare Function Toolbar Lib "AppKit" Selector "toolbar" (window As Ptr) As Ptr
		    Declare Function Items Lib "AppKit" Selector "items" (toolbar As Ptr) As Ptr
		    Declare Function ItemCount Lib "Foundation" Selector "count" (nsArray As Ptr) As UInteger
		    Declare Function ObjectAtIndex Lib "Foundation" Selector "objectAtIndex:" (nsArray As Ptr, index As UInteger) As Ptr
		    Declare Function ImageWithSymbol Lib "AppKit" Selector "imageWithSystemSymbolName:accessibilityDescription:" (cls As Ptr, name As CFStringRef, description As Ptr) As Ptr
		    Declare Sub SetImage Lib "AppKit" Selector "setImage:" (item As Ptr, image As Ptr)
		    Declare Sub SetShowsIndicator Lib "AppKit" Selector "setShowsIndicator:" (item As Ptr, value As Boolean)
		    Declare Sub SetBordered Lib "AppKit" Selector "setBordered:" (item As Ptr, value As Boolean)
		    Declare Function View Lib "AppKit" Selector "view" (item As Ptr) As Ptr
		    Declare Function ClassOf Lib "Foundation" Selector "class" (obj As Ptr) As Ptr
		    Declare Function NSStringFromClass Lib "Foundation" (cls As Ptr) As CFStringRef
		    Declare Function Cell Lib "AppKit" Selector "cell" (control As Ptr) As Ptr
		    Declare Sub SetArrowPosition Lib "AppKit" Selector "setArrowPosition:" (cell As Ptr, position As UInteger)
		    Declare Function PullsDown Lib "AppKit" Selector "pullsDown" (button As Ptr) As Boolean
		    Declare Function UsesItemFromMenu Lib "AppKit" Selector "usesItemFromMenu" (cell As Ptr) As Boolean
		    Declare Function NumberOfItems Lib "AppKit" Selector "numberOfItems" (button As Ptr) As Integer
		    Declare Function ImageOf Lib "AppKit" Selector "image" (obj As Ptr) As Ptr

		    Var bar As Ptr = Toolbar(w.Handle)
		    If bar = Nil Then Return
		    Var imageClass As Ptr = NSClassFromString("NSImage")
		    If Not RespondsToSelector(imageClass, NSSelectorFromString("imageWithSystemSymbolName:accessibilityDescription:")) Then Return

		    Var list As Ptr = Items(bar)
		    Var available As Integer = ItemCount(list)
		    Var last As Integer = Min(available, symbols.Count) - 1
		    For index As Integer = 0 To last
		      Var item As Ptr = ObjectAtIndex(list, index)
		      Var image As Ptr = ImageWithSymbol(imageClass, symbols(index), Nil)
		      If image <> Nil Then SetImage(item, image)
		      If RespondsToSelector(item, NSSelectorFromString("setShowsIndicator:")) Then SetShowsIndicator(item, True)
		      // Bordered items get a capsule, drawn in Liquid Glass on macOS 26, as in Apple's apps.
		      If RespondsToSelector(item, NSSelectorFromString("setBordered:")) Then SetBordered(item, True)
		      
		      // Xojo puts a popup button in the item, which keeps room for a menu arrow it doesn't draw.
		      // That made the button wider than tall, so the hover highlight came out stretched.
		      Const kNoArrow As UInteger = 0
		      Var itemView As Ptr = View(item)
		      If itemView <> Nil And RespondsToSelector(itemView, NSSelectorFromString("cell")) Then
		        Var buttonCell As Ptr = Cell(itemView)
		        If RespondsToSelector(buttonCell, NSSelectorFromString("setArrowPosition:")) Then SetArrowPosition(buttonCell, kNoArrow)
		        
		        // Spike only: how Xojo's button gets its image, and its size.
		        Var frame As MemoryBlock = RectOf(itemView, "frame")
		        If frame Is Nil Then Continue
		        Var note As String = "item " + index.ToString + " " + frame.DoubleValue(16).ToString + " x " + frame.DoubleValue(24).ToString
		        If RespondsToSelector(itemView, NSSelectorFromString("pullsDown")) Then
		          note = note + ", pulls down " + If(PullsDown(itemView), "yes", "no") _
		          + ", uses item from menu " + If(UsesItemFromMenu(buttonCell), "yes", "no") _
		          + ", items " + NumberOfItems(itemView).ToString _
		          + ", button image " + If(ImageOf(itemView) = Nil, "nil", "set") _
		          + ", cell image " + If(ImageOf(buttonCell) = Nil, "nil", "set")
		        End If
		        System.DebugLog("WakeTitleBar: " + note)
		      End If
		    Next
		  #Else
		    #Pragma Unused w
		    #Pragma Unused symbols
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Unify(w As DesktopWindow, compact As Boolean)
		  // On macOS 11 and later, merges the window's title bar and its top row of controls into one
		  // unified bar, as Finder and Mail do. The content view then runs under the bar, the title is
		  // hidden (it still names the window in the Window menu), and an empty toolbar gives the bar
		  // its height, unless the window has a toolbar of its own. The window lays its content out
		  // with Height, and any controls it keeps in the bar with LeftInset and RowTop. Elsewhere
		  // this does nothing.
		  #If TargetMacOS
		    Const kFullSizeContentView As UInteger = &h8000
		    Const kTitleHidden = 1
		    Const kToolbarStyleUnified = 3
		    Const kToolbarStyleUnifiedCompact = 4

		    Declare Function NSClassFromString Lib "Foundation" (name As CFStringRef) As Ptr
		    Declare Function NSSelectorFromString Lib "Foundation" (name As CFStringRef) As Ptr
		    Declare Function RespondsToSelector Lib "Foundation" Selector "respondsToSelector:" (obj As Ptr, sel As Ptr) As Boolean
		    Declare Function Alloc Lib "Foundation" Selector "alloc" (cls As Ptr) As Ptr
		    Declare Function InitWithIdentifier Lib "AppKit" Selector "initWithIdentifier:" (obj As Ptr, identifier As CFStringRef) As Ptr
		    Declare Sub Release Lib "Foundation" Selector "release" (obj As Ptr)
		    Declare Function Toolbar Lib "AppKit" Selector "toolbar" (window As Ptr) As Ptr
		    Declare Sub SetToolbar Lib "AppKit" Selector "setToolbar:" (window As Ptr, toolbar As Ptr)
		    Declare Sub SetToolbarStyle Lib "AppKit" Selector "setToolbarStyle:" (window As Ptr, style As Integer)
		    Declare Function StyleMask Lib "AppKit" Selector "styleMask" (window As Ptr) As UInteger
		    Declare Sub SetStyleMask Lib "AppKit" Selector "setStyleMask:" (window As Ptr, mask As UInteger)
		    Declare Sub SetTitlebarAppearsTransparent Lib "AppKit" Selector "setTitlebarAppearsTransparent:" (window As Ptr, value As Boolean)
		    Declare Sub SetTitleVisibility Lib "AppKit" Selector "setTitleVisibility:" (window As Ptr, visibility As Integer)

		    Var window As Ptr = w.Handle
		    If Not RespondsToSelector(window, NSSelectorFromString("setToolbarStyle:")) Then Return

		    // The style goes on before the toolbar. The other way round, the regular bar first measured
		    // 66 points instead of 52.
		    SetStyleMask(window, StyleMask(window) Or kFullSizeContentView)
		    SetTitlebarAppearsTransparent(window, True)
		    SetTitleVisibility(window, kTitleHidden)
		    SetToolbarStyle(window, If(compact, kToolbarStyleUnifiedCompact, kToolbarStyleUnified))

		    If Toolbar(window) = Nil Then
		      Var bar As Ptr = InitWithIdentifier(Alloc(NSClassFromString("NSToolbar")), "WakeTitleBar")
		      SetToolbar(window, bar)
		      Release(bar)
		    End If
		  #Else
		    #Pragma Unused w
		    #Pragma Unused compact
		  #EndIf
		End Sub
	#tag EndMethod


End Module
#tag EndModule
