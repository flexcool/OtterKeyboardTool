import hashlib, os

def uid(seed: str) -> str:
    return hashlib.sha1(seed.encode("utf-8")).hexdigest()[:24]

APP_TARGET = uid("TGT:app")   # matches gen_pbx.py
PROJECT = uid("PROJECT")

SCHEME = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1520"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{APP_TARGET}"
               BuildableName = "OtterKeyboardTool.app"
               BlueprintName = "OtterKeyboardTool"
               ReferencedContainer = "container:OtterKeyboardTool.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.RustDebuger"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.RustDebuger"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{APP_TARGET}"
            BuildableName = "OtterKeyboardTool.app"
            BlueprintName = "OtterKeyboardTool"
            ReferencedContainer = "container:OtterKeyboardTool.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{APP_TARGET}"
            BuildableName = "OtterKeyboardTool.app"
            BlueprintName = "OtterKeyboardTool"
            ReferencedContainer = "container:OtterKeyboardTool.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
'''

out = os.path.join("OtterKeyboardTool.xcodeproj", "xcshareddata", "xcschemes")
os.makedirs(out, exist_ok=True)
with open(os.path.join(out, "OtterKeyboardTool.xcscheme"), "w", encoding="utf-8") as f:
    f.write(SCHEME)
print("wrote scheme; APP_TARGET=", APP_TARGET, "PROJECT=", PROJECT)
