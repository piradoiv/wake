#tag Menu
Begin Menu MainMenuBar
   Begin DesktopMenuItem FileMenu
      SpecialMenu = 0
      Index = -2147483648
      Text = "&File"
      Symbol = ""
      AutoEnabled = True
      AutoEnable = True
      Visible = True
      Begin DesktopQuitMenuItem FileQuit
         SpecialMenu = 0
         Index = -2147483648
         Text = "#App.kFileQuit"
         Symbol = ""
         ShortcutKey = "#App.kFileQuitShortcut"
         Shortcut = "#App.kFileQuitShortcut"
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
   End
   Begin DesktopMenuItem EditMenu
      SpecialMenu = 0
      Index = -2147483648
      Text = "&Edit"
      Symbol = ""
      AutoEnabled = True
      AutoEnable = True
      Visible = True
      Begin DesktopMenuItem EditUndo
         SpecialMenu = 0
         Index = -2147483648
         Text = "&Undo"
         Symbol = ""
         ShortcutKey = "Z"
         Shortcut = "Cmd+Z"
         MenuModifier = True
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditSeparator1
         SpecialMenu = 0
         Index = -2147483648
         Text = "-"
         Symbol = ""
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditCut
         SpecialMenu = 0
         Index = -2147483648
         Text = "Cu&t"
         Symbol = ""
         ShortcutKey = "X"
         Shortcut = "Cmd+X"
         MenuModifier = True
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditCopy
         SpecialMenu = 0
         Index = -2147483648
         Text = "&Copy"
         Symbol = ""
         ShortcutKey = "C"
         Shortcut = "Cmd+C"
         MenuModifier = True
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditPaste
         SpecialMenu = 0
         Index = -2147483648
         Text = "&Paste"
         Symbol = ""
         ShortcutKey = "V"
         Shortcut = "Cmd+V"
         MenuModifier = True
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditClear
         SpecialMenu = 0
         Index = -2147483648
         Text = "#App.kEditClear"
         Symbol = ""
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditSeparator2
         SpecialMenu = 0
         Index = -2147483648
         Text = "-"
         Symbol = ""
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
      Begin DesktopMenuItem EditSelectAll
         SpecialMenu = 0
         Index = -2147483648
         Text = "Select &All"
         Symbol = ""
         ShortcutKey = "A"
         Shortcut = "Cmd+A"
         MenuModifier = True
         AutoEnabled = True
         AutoEnable = True
         Visible = True
      End
   End
   Begin DesktopMenuItem WindowMenu
      SpecialMenu = 0
      Index = -2147483648
      Text = "Window"
      Symbol = ""
      AutoEnabled = True
      AutoEnable = True
      Visible = True
   End
   Begin DesktopMenuItem HelpMenu
      SpecialMenu = 0
      Index = -2147483648
      Text = "&Help"
      Symbol = ""
      AutoEnabled = True
      AutoEnable = True
      Visible = True
   End
End
#tag EndMenu
