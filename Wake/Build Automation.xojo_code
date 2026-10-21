#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin SignProjectStep Sign
				  DeveloperID=Developer ID Application: Ricardo Angel Cruz Fernandez (76GS9GQ3ZE)
				  macOSEntitlements={"App Sandbox":"False","Hardened Runtime":"True","Notarize":"True","UserEntitlements":""}
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
