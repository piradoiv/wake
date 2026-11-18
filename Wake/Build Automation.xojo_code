#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyResources
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vVGVzdHMvWG9qb1VuaXQvTElDRU5TRS50eHQ=
					FolderItem = Li4vLi4vTElDRU5TRQ==
					FolderItem = Li4vLi4vQXJ0d29yay9JY29uU2V0L3dha2UtMjU2LnBuZw==
				End
				Begin CopyFilesBuildStep CopyCLI
					AppliesTo = 2
					Architecture = 0
					Target = 0
					Destination = 4
					Subdirectory = Helpers
					FolderItem = Li4vLi4vV2FrZUNMSS9CdWlsZHMlMjAtJTIwV2FrZUNMSS9tYWNPUyUyMEFSTSUyMDY0JTIwYml0L3dha2Uv
				End
				Begin SignProjectStep Sign
				  DeveloperID=Developer ID Application: Ricardo Angel Cruz Fernandez (76GS9GQ3ZE)
				  macOSEntitlements={"App Sandbox":"False","Hardened Runtime":"True","Notarize":"True","UserEntitlements":""}
				End
				Begin IDEScriptBuildStep CheckCLI , AppliesTo = 2, Architecture = 0, Target = 0
					Var code As Integer
					Var output As String = DoShellCommand("""$PROJECT_PATH""/../scripts/check-cli.sh " + CurrentBuildLocation, 600000, code)
					If InStr(output, "CLI CHECK OK") = 0 Then
					Print("The wake CLI can't ship: " + output)
					Else
					DebugLog(output)
					End If
				End
				Begin IDEScriptBuildStep ReleaseScript , AppliesTo = 2, Architecture = 0, Target = 0
					Var code As Integer
					Var output As String = DoShellCommand("""$PROJECT_PATH""/../scripts/make-dmg.sh " + CurrentBuildLocation, 1800000, code)
					If InStr(output, "DMG OK:") = 0 Then
					Print("The disk image wasn't made: " + output)
					Else
					DebugLog(output)
					End If
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
