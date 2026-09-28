import hashlib

def uid(seed: str) -> str:
    return hashlib.sha1(seed.encode("utf-8")).hexdigest()[:24]

def last_type(full):
    if full.endswith(".swift"): return "sourcecode.swift"
    if full.endswith(".strings"): return "text.plist.strings"
    if full.endswith(".xcassets"): return "folder.assetcatalog"
    if full.endswith(".xcdatamodeld"): return "wrapper.xcdatamodeld"
    if full.endswith(".entitlements"): return "text.plist.entitlements"
    if full.endswith(".plist"): return "text.plist.xml"
    return "text"

def cfg(u, name, pairs):
    out = []
    out.append('\t\t\t%s /* %s */ = {' % (u, name))
    out.append('\t\t\t\tisa = XCBuildConfiguration;')
    out.append('\t\t\t\tbuildSettings = {')
    for k, v in pairs:
        out.append('\t\t\t\t\t%s = %s;' % (k, v))
    out.append('\t\t\t\t};')
    out.append('\t\t\t\tname = %s;' % name)
    out.append('\t\t\t};')
    return "\n".join(out)

ROOT = "OtterKeyboardTool"

APP_GROUP_FILES = [
    ("OtterKeyboardTool", "OtterKeyboardToolApp.swift", "OtterKeyboardTool/OtterKeyboardToolApp.swift"),
    ("OtterKeyboardTool", "ContentView.swift", "OtterKeyboardTool/ContentView.swift"),
    ("OtterKeyboardTool", "Screens/ClipboardListView.swift", "OtterKeyboardTool/Screens/ClipboardListView.swift"),
    ("OtterKeyboardTool", "Screens/PhraseSetsView.swift", "OtterKeyboardTool/Screens/PhraseSetsView.swift"),
    ("OtterKeyboardTool", "Screens/ScriptsView.swift", "OtterKeyboardTool/Screens/ScriptsView.swift"),
    ("OtterKeyboardTool", "Screens/SettingsView.swift", "OtterKeyboardTool/Screens/SettingsView.swift"),
    ("OtterKeyboardTool", "Screens/InfoViews.swift", "OtterKeyboardTool/Screens/InfoViews.swift"),
    ("OtterKeyboardTool", "Assets.xcassets", "OtterKeyboardTool/Assets.xcassets"),
    ("OtterKeyboardTool", "en.lproj/Localizable.strings", "OtterKeyboardTool/en.lproj/Localizable.strings"),
    ("OtterKeyboardTool", "zh-Hans.lproj/Localizable.strings", "OtterKeyboardTool/zh-Hans.lproj/Localizable.strings"),
    ("OtterKeyboardTool", "Info.plist", "OtterKeyboardTool/Info.plist"),
    ("OtterKeyboardTool", "OtterKeyboardTool.entitlements", "OtterKeyboardTool/OtterKeyboardTool.entitlements"),
]

EXT_GROUP_FILES = [
    ("KeyboardExtension", "KeyboardViewController.swift", "KeyboardExtension/KeyboardViewController.swift"),
    ("KeyboardExtension", "KeyboardRootView.swift", "KeyboardExtension/KeyboardRootView.swift"),
    ("KeyboardExtension", "Panels.swift", "KeyboardExtension/Panels.swift"),
    ("KeyboardExtension", "ExplosionView.swift", "KeyboardExtension/ExplosionView.swift"),
    ("KeyboardExtension", "en.lproj/Localizable.strings", "KeyboardExtension/en.lproj/Localizable.strings"),
    ("KeyboardExtension", "zh-Hans.lproj/Localizable.strings", "KeyboardExtension/zh-Hans.lproj/Localizable.strings"),
    ("KeyboardExtension", "Info.plist", "KeyboardExtension/Info.plist"),
    ("KeyboardExtension", "KeyboardExtension.entitlements", "KeyboardExtension/KeyboardExtension.entitlements"),
]

SHARED_GROUP_FILES = [
    ("Shared", "Persistence.swift", "Shared/Persistence.swift"),
    ("Shared", "Models.swift", "Shared/Models.swift"),
    ("Shared", "Localized.swift", "Shared/Localized.swift"),
    ("Shared", "ScriptRunner.swift", "Shared/ScriptRunner.swift"),
    ("Shared", "OtterKeyboardTool.xcdatamodeld", "Shared/OtterKeyboardTool.xcdatamodeld"),
]

FRAMEWORKS = ["UIKit", "Foundation", "SwiftUI", "CoreData", "WebKit"]

fileref = {}
for _, _, full in APP_GROUP_FILES + EXT_GROUP_FILES + SHARED_GROUP_FILES:
    fileref[full] = uid("FR:" + full)
fwref = {fw: uid("FW:" + fw) for fw in FRAMEWORKS}

APP_TARGET = uid("TGT:app")
EXT_TARGET = uid("TGT:ext")
PROJECT = uid("PROJECT")
MAIN_GROUP = uid("GRP:main")
PRODUCTS_GROUP = uid("GRP:products")
FW_GROUP = uid("GRP:frameworks")
APP_GROUP = uid("GRP:OtterKeyboardTool")
EXT_GROUP = uid("GRP:KeyboardExtension")
SHARED_GROUP = uid("GRP:Shared")
APP_PROD = uid("PROD:app")
EXT_PROD = uid("PROD:ext")

APP_SOURCES_PHASE = uid("PH:src:app")
APP_FW_PHASE = uid("PH:fw:app")
APP_RES_PHASE = uid("PH:res:app")
APP_EMBED_PHASE = uid("PH:embed:app")
EXT_SOURCES_PHASE = uid("PH:src:ext")
EXT_FW_PHASE = uid("PH:fw:ext")
EXT_RES_PHASE = uid("PH:res:ext")

def buildfile(key): return uid("BF:" + key)
app_source_bfs = []
ext_source_bfs = []
for _, _, full in SHARED_GROUP_FILES:
    if full.endswith((".swift", ".xcdatamodeld")):
        app_source_bfs.append(buildfile("app:" + full))
        ext_source_bfs.append(buildfile("ext:" + full))
for _, _, full in APP_GROUP_FILES:
    if full.endswith((".swift", ".xcdatamodeld")):
        app_source_bfs.append(buildfile("app:" + full))
for _, _, full in EXT_GROUP_FILES:
    if full.endswith(".swift"):
        ext_source_bfs.append(buildfile("ext:" + full))

app_res_bfs = [buildfile("app:" + full) for _, _, full in APP_GROUP_FILES if full.endswith((".xcassets", ".strings"))]
ext_res_bfs = [buildfile("ext:" + full) for _, _, full in EXT_GROUP_FILES if full.endswith(".strings")]
app_fw_bfs = [buildfile("appfw:" + fw) for fw in FRAMEWORKS]
ext_fw_bfs = [buildfile("extfw:" + fw) for fw in FRAMEWORKS]
app_embed_bf = buildfile("embed:ext")

PROJ_DEBUG = uid("XC:proj:Debug"); PROJ_RELEASE = uid("XC:proj:Release"); PROJ_XCL = uid("XCL:proj")
APP_DEBUG = uid("XC:app:Debug"); APP_RELEASE = uid("XC:app:Release"); APP_XCL = uid("XCL:app")
EXT_DEBUG = uid("XC:ext:Debug"); EXT_RELEASE = uid("XC:ext:Release"); EXT_XCL = uid("XCL:ext")
DEP = uid("DEP:ext"); CIP = uid("CIP:ext")

L = []
def w(s=""): L.append(s)
w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {")
w("\t};")
w("\tobjectVersion = 56;")
w("\tobjects = {")

w("\t\t/* Begin PBXBuildFile section */")
for _, _, full in APP_GROUP_FILES:
    if full.endswith((".swift", ".xcdatamodeld")):
        w('\t\t%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("app:" + full), full, fileref[full]))
for _, _, full in EXT_GROUP_FILES:
    if full.endswith(".swift"):
        w('\t\t%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("ext:" + full), full, fileref[full]))
for _, _, full in SHARED_GROUP_FILES:
    if full.endswith((".swift", ".xcdatamodeld")):
        w('\t\t%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("app:" + full), full, fileref[full]))
        w('\t\t%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("ext:" + full), full, fileref[full]))
for _, _, full in APP_GROUP_FILES:
    if full.endswith((".xcassets", ".strings")):
        w('\t\t%s /* %s in Resources */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("app:" + full), full, fileref[full]))
for _, _, full in EXT_GROUP_FILES:
    if full.endswith(".strings"):
        w('\t\t%s /* %s in Resources */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("ext:" + full), full, fileref[full]))
for fw in FRAMEWORKS:
    w('\t\t%s /* %s.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("appfw:" + fw), fw, fwref[fw]))
    w('\t\t%s /* %s.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = %s; };' % (buildfile("extfw:" + fw), fw, fwref[fw]))
w('\t\t%s /* KeyboardExtension.appex in Embed App Extensions */ = {isa = PBXBuildFile; fileRef = %s; settings = {ATTRIBUTES = (RemoveHeadersOnCopy, ); }; };' % (app_embed_bf, EXT_PROD))
w("\t\t/* End PBXBuildFile section */")

w("\t\t/* Begin PBXContainerItemProxy section */")
w('\t\t%s /* PBXContainerItemProxy */ = {isa = PBXContainerItemProxy; containerPortal = %s; proxyType = 1; remoteGlobalIDString = %s; remoteInfo = "KeyboardExtension"; };' % (CIP, PROJECT, EXT_TARGET))
w("\t\t/* End PBXContainerItemProxy section */")

w("\t\t/* Begin PBXFileReference section */")
for _, ref, full in APP_GROUP_FILES:
    w('\t\t%s /* %s */ = {isa = PBXFileReference; lastKnownFileType = %s; path = "%s"; sourceTree = "<group>"; };' % (fileref[full], ref, last_type(full), ref))
for _, ref, full in EXT_GROUP_FILES:
    w('\t\t%s /* %s */ = {isa = PBXFileReference; lastKnownFileType = %s; path = "%s"; sourceTree = "<group>"; };' % (fileref[full], ref, last_type(full), ref))
for _, ref, full in SHARED_GROUP_FILES:
    w('\t\t%s /* %s */ = {isa = PBXFileReference; lastKnownFileType = %s; path = "%s"; sourceTree = "<group>"; };' % (fileref[full], ref, last_type(full), ref))
for fw in FRAMEWORKS:
    w('\t\t%s /* %s.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = "%s.framework"; path = "System/Library/Frameworks/%s.framework"; sourceTree = SDKROOT; };' % (fwref[fw], fw, fw, fw))
w('\t\t%s /* OtterKeyboardTool.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; path = "OtterKeyboardTool.app"; sourceTree = BUILT_PRODUCTS_DIR; };' % APP_PROD)
w('\t\t%s /* KeyboardExtension.appex */ = {isa = PBXFileReference; explicitFileType = wrapper.app-extension; path = "KeyboardExtension.appex"; sourceTree = BUILT_PRODUCTS_DIR; };' % EXT_PROD)
w("\t\t/* End PBXFileReference section */")

w("\t\t/* Begin PBXFrameworksBuildPhase section */")
w('\t\t%s /* Frameworks */ = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (' % APP_FW_PHASE)
for b in app_fw_bfs: w('\t\t\t%s,' % b)
w("\t\t); runOnlyForDeploymentPostprocessing = 0; };")
w('\t\t%s /* Frameworks */ = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (' % EXT_FW_PHASE)
for b in ext_fw_bfs: w('\t\t\t%s,' % b)
w("\t\t); runOnlyForDeploymentPostprocessing = 0; };")
w("\t\t/* End PBXFrameworksBuildPhase section */")

w("\t\t/* Begin PBXGroup section */")
w('\t\t%s = {isa = PBXGroup; children = (' % MAIN_GROUP)
w('\t\t\t%s,' % APP_GROUP); w('\t\t\t%s,' % EXT_GROUP); w('\t\t\t%s,' % SHARED_GROUP)
w('\t\t\t%s,' % PRODUCTS_GROUP); w('\t\t\t%s,' % FW_GROUP)
w("\t\t); sourceTree = \"<group>\"; };")
w('\t\t%s /* OtterKeyboardTool */ = {isa = PBXGroup; children = (' % APP_GROUP)
for _, ref, full in APP_GROUP_FILES: w('\t\t\t%s, /* %s */' % (fileref[full], ref))
w('\t\t); path = "OtterKeyboardTool"; sourceTree = "<group>"; };')
w('\t\t%s /* KeyboardExtension */ = {isa = PBXGroup; children = (' % EXT_GROUP)
for _, ref, full in EXT_GROUP_FILES: w('\t\t\t%s, /* %s */' % (fileref[full], ref))
w('\t\t); path = "KeyboardExtension"; sourceTree = "<group>"; };')
w('\t\t%s /* Shared */ = {isa = PBXGroup; children = (' % SHARED_GROUP)
for _, ref, full in SHARED_GROUP_FILES: w('\t\t\t%s, /* %s */' % (fileref[full], ref))
w('\t\t); path = "Shared"; sourceTree = "<group>"; };')
w('\t\t%s /* Products */ = {isa = PBXGroup; children = (' % PRODUCTS_GROUP)
w('\t\t\t%s,' % APP_PROD); w('\t\t\t%s,' % EXT_PROD)
w("\t\t); name = Products; sourceTree = \"<group>\"; };")
w('\t\t%s /* Frameworks */ = {isa = PBXGroup; children = (' % FW_GROUP)
for fw in FRAMEWORKS: w('\t\t\t%s,' % fwref[fw])
w("\t\t); name = Frameworks; sourceTree = \"<group>\"; };")
w("\t\t/* End PBXGroup section */")

w("\t\t/* Begin PBXNativeTarget section */")
w('\t\t%s /* OtterKeyboardTool */ = {isa = PBXNativeTarget; buildConfigurationList = %s; buildPhases = (' % (APP_TARGET, APP_XCL))
w('\t\t\t%s,' % APP_SOURCES_PHASE); w('\t\t\t%s,' % APP_FW_PHASE); w('\t\t\t%s,' % APP_RES_PHASE); w('\t\t\t%s,' % APP_EMBED_PHASE)
w("\t\t); buildRules = (); dependencies = (%s, ); name = OtterKeyboardTool; productName = OtterKeyboardTool; productReference = %s; productType = \"com.apple.product-type.application\"; };" % (DEP, APP_PROD))
w('\t\t%s /* KeyboardExtension */ = {isa = PBXNativeTarget; buildConfigurationList = %s; buildPhases = (' % (EXT_TARGET, EXT_XCL))
w('\t\t\t%s,' % EXT_SOURCES_PHASE); w('\t\t\t%s,' % EXT_FW_PHASE); w('\t\t\t%s,' % EXT_RES_PHASE)
w("\t\t); buildRules = (); dependencies = (); name = KeyboardExtension; productName = KeyboardExtension; productReference = %s; productType = \"com.apple.product-type.app-extension\"; };" % EXT_PROD)
w("\t\t/* End PBXNativeTarget section */")

w("\t\t/* Begin PBXProject section */")
w('\t\t%s /* Project object */ = {' % PROJECT)
w("\t\t\tisa = PBXProject;")
w("\t\t\tattributes = {")
w("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
w("\t\t\t\tLastSwiftUpdateCheck = 1520;")
w("\t\t\t\tLastUpgradeCheck = 1520;")
w("\t\t\t\tTargetAttributes = {")
w("\t\t\t\t\t%s = {CreatedOnToolsVersion = 15.2;};" % APP_TARGET)
w("\t\t\t\t\t%s = {CreatedOnToolsVersion = 15.2;};" % EXT_TARGET)
w("\t\t\t\t};")
w("\t\t\t};")
w("\t\t\tbuildConfigurationList = %s;" % PROJ_XCL)
w("\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
w("\t\t\tdevelopmentRegion = en;")
w("\t\t\thasScannedForEncodings = 0;")
w("\t\t\tknownRegions = (en, zh-Hans, );")
w("\t\t\tmainGroup = %s;" % MAIN_GROUP)
w("\t\t\tproductRefGroup = %s;" % PRODUCTS_GROUP)
w("\t\t\tprojectDirPath = \"\";")
w("\t\t\tprojectRoot = \"\";")
w("\t\t\ttargets = (")
w('\t\t\t\t%s,' % APP_TARGET); w('\t\t\t\t%s,' % EXT_TARGET)
w("\t\t\t);")
w("\t\t};")
w("\t\t/* End PBXProject section */")

w("\t\t/* Begin PBXResourcesBuildPhase section */")
w('\t\t%s /* Resources */ = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (' % APP_RES_PHASE)
for b in app_res_bfs: w('\t\t\t%s,' % b)
w("\t\t); runOnlyForDeploymentPostprocessing = 0; };")
w('\t\t%s /* Resources */ = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (' % EXT_RES_PHASE)
for b in ext_res_bfs: w('\t\t\t%s,' % b)
w("\t\t); runOnlyForDeploymentPostprocessing = 0; };")
w("\t\t/* End PBXResourcesBuildPhase section */")

w("\t\t/* Begin PBXSourcesBuildPhase section */")
w('\t\t%s /* Sources */ = {isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (' % APP_SOURCES_PHASE)
for b in app_source_bfs: w('\t\t\t%s,' % b)
w("\t\t); runOnlyForDeploymentPostprocessing = 0; };")
w('\t\t%s /* Sources */ = {isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (' % EXT_SOURCES_PHASE)
for b in ext_source_bfs: w('\t\t\t%s,' % b)
w("\t\t); runOnlyForDeploymentPostprocessing = 0; };")
w("\t\t/* End PBXSourcesBuildPhase section */")

w("\t\t/* Begin PBXTargetDependency section */")
w('\t\t%s /* PBXTargetDependency */ = {isa = PBXTargetDependency; target = %s; targetProxy = %s; };' % (DEP, EXT_TARGET, CIP))
w("\t\t/* End PBXTargetDependency section */")

w("\t\t/* Begin PBXCopyFilesBuildPhase section */")
w('\t\t%s /* Embed App Extensions */ = {isa = PBXCopyFilesBuildPhase; buildActionMask = 2147483647; dstPath = ""; dstSubfolderSpec = 13; files = (' % APP_EMBED_PHASE)
w('\t\t\t%s,' % app_embed_bf)
w("\t\t); name = \"Embed App Extensions\"; runOnlyForDeploymentPostprocessing = 0; };")
w("\t\t/* End PBXCopyFilesBuildPhase section */")

# configs
proj_debug_pairs = [
    ("ALWAYS_SEARCH_USER_PATHS","NO"),("CLANG_ANALYZER_NONNULL","YES"),("CLANG_ENABLE_MODULES","YES"),
    ("CLANG_ENABLE_OBJC_ARC","YES"),("CLANG_ENABLE_OBJC_WEAK","YES"),("COPY_PHASE_STRIP","NO"),
    ("DEBUG_INFORMATION_FORMAT","dwarf"),("ENABLE_STRICT_OBJC_MSGSEND","YES"),
    ("ENABLE_USER_SCRIPT_SANDBOXING","NO"),("GCC_C_LANGUAGE_STANDARD","gnu17"),("GCC_NO_COMMON_BLOCKS","YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET","16.0"),("MTL_ENABLE_DEBUG_INFO","INCLUDE_SOURCE"),("MTL_FAST_MATH","YES"),
    ("ONLY_ACTIVE_ARCH","YES"),("SDKROOT","iphoneos"),("SWIFT_VERSION","5.0"),("TARGETED_DEVICE_FAMILY",'"1,2"'),
    ("CODE_SIGN_STYLE","Automatic"),("GCC_OPTIMIZATION_LEVEL","0"),("SWIFT_OPTIMIZATION_LEVEL","-Onone"),
]
proj_release_pairs = [
    ("ALWAYS_SEARCH_USER_PATHS","NO"),("CLANG_ANALYZER_NONNULL","YES"),("CLANG_ENABLE_MODULES","YES"),
    ("CLANG_ENABLE_OBJC_ARC","YES"),("CLANG_ENABLE_OBJC_WEAK","YES"),("COPY_PHASE_STRIP","YES"),
    ("DEBUG_INFORMATION_FORMAT","dwarf-with-dsym"),("ENABLE_STRICT_OBJC_MSGSEND","YES"),
    ("ENABLE_USER_SCRIPT_SANDBOXING","NO"),("GCC_C_LANGUAGE_STANDARD","gnu17"),("GCC_NO_COMMON_BLOCKS","YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET","16.0"),("MTL_ENABLE_DEBUG_INFO","NO"),("MTL_FAST_MATH","YES"),
    ("ONLY_ACTIVE_ARCH","NO"),("SDKROOT","iphoneos"),("SWIFT_VERSION","5.0"),("TARGETED_DEVICE_FAMILY",'"1,2"'),
    ("CODE_SIGN_STYLE","Automatic"),("GCC_OPTIMIZATION_LEVEL","s"),("SWIFT_OPTIMIZATION_LEVEL","-O"),
    ("VALIDATE_PRODUCT","YES"),
]
app_pairs = [
    ("ASSETCATALOG_COMPILER_APPICON_NAME","AppIcon"),
    ("CODE_SIGN_ENTITLEMENTS",'"OtterKeyboardTool/OtterKeyboardTool.entitlements"'),
    ("CURRENT_PROJECT_VERSION","3"),("ENABLE_BITCODE","NO"),("GENERATE_INFOPLIST_FILE","NO"),
    ("INFOPLIST_FILE",'"OtterKeyboardTool/Info.plist"'),
    ("LD_RUNPATH_SEARCH_PATHS",'("$(inherited)", "@executable_path/Frameworks", )'),
    ("MARKETING_VERSION",'"1.2"'),("PRODUCT_BUNDLE_IDENTIFIER","com.cz.czk"),
    ("PRODUCT_NAME",'"$(TARGET_NAME)"'),("SWIFT_EMIT_LOC_STRINGS","YES"),
]
ext_pairs = [
    ("CODE_SIGN_ENTITLEMENTS",'"KeyboardExtension/KeyboardExtension.entitlements"'),
    ("CURRENT_PROJECT_VERSION","3"),("ENABLE_BITCODE","NO"),("GENERATE_INFOPLIST_FILE","NO"),
    ("INFOPLIST_FILE",'"KeyboardExtension/Info.plist"'),
    ("LD_RUNPATH_SEARCH_PATHS",'("$(inherited)", "@executable_path/Frameworks", )'),
    ("MARKETING_VERSION",'"1.2"'),("PRODUCT_BUNDLE_IDENTIFIER","com.cz.czk.keyboard"),
    ("PRODUCT_NAME",'"$(TARGET_NAME)"'),("SKIP_INSTALL","YES"),("SWIFT_EMIT_LOC_STRINGS","YES"),
]

w("\t\t/* Begin XCBuildConfiguration section */")
w(cfg(PROJ_DEBUG, "Debug", proj_debug_pairs))
w(cfg(PROJ_RELEASE, "Release", proj_release_pairs))
w(cfg(APP_DEBUG, "Debug", app_pairs))
w(cfg(APP_RELEASE, "Release", app_pairs))
w(cfg(EXT_DEBUG, "Debug", ext_pairs))
w(cfg(EXT_RELEASE, "Release", ext_pairs))
w("\t\t/* End XCBuildConfiguration section */")

w("\t\t/* Begin XCConfigurationList section */")
w('\t\t%s /* Build configuration list for PBXProject "OtterKeyboardTool" */ = {isa = XCConfigurationList; buildConfigurations = (' % PROJ_XCL)
w('\t\t\t%s,' % PROJ_DEBUG); w('\t\t\t%s,' % PROJ_RELEASE)
w("\t\t); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };")
w('\t\t%s /* Build configuration list for PBXNativeTarget "OtterKeyboardTool" */ = {isa = XCConfigurationList; buildConfigurations = (' % APP_XCL)
w('\t\t\t%s,' % APP_DEBUG); w('\t\t\t%s,' % APP_RELEASE)
w("\t\t); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };")
w('\t\t%s /* Build configuration list for PBXNativeTarget "KeyboardExtension" */ = {isa = XCConfigurationList; buildConfigurations = (' % EXT_XCL)
w('\t\t\t%s,' % EXT_DEBUG); w('\t\t\t%s,' % EXT_RELEASE)
w("\t\t); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };")
w("\t\t/* End XCConfigurationList section */")

w("\t};")
w("\trootObject = %s; /* Project object */" % PROJECT)
w("}")

text = "\n".join(L)
with open(ROOT + ".xcodeproj/project.pbxproj", "w", encoding="utf-8") as f:
    f.write(text)
print("wrote project.pbxproj", len(text), "bytes")
