import os

EN = {
    "bottom_bar.clipboard": "Clipboard",
    "bottom_bar.phrase": "Phrase",
    "bottom_bar.script": "Script",
    "bottom_bar.setting": "Setting",
    "clipboard.list_title": "Clipboard List",
    "clipboard_empty.tip1": "click",
    "clipboard_empty.tip2": "to copy from system clipboard",
    "new_clipboard.title": "add to clipboard list",
    "clipboard.delete_all.tip": "Are you sure to delete all clipboard?",
    "cancel": "Cancel",
    "ok": "OK",
    "save": "Save",
    "delete": "Delete",
    "pasted.tip": "Copied",
    "save.success": "Save Successful",
    "save.to_phrase": "Save as Phrase",
    "phrase_set.list_title": "Common Phrases",
    "phrase_empty.tip1": "phrase is empty, please click",
    "phrase_empty.tip2": "to add",
    "new_phrase_set.name": "name",
    "new_phrase_set.title": "new collection of phrases",
    "new_phrase.title": "new phrase",
    "script.list_title": "Scripts",
    "scripts_empty.tip1": "script is empty,",
    "scripts_empty.tip2": "to add",
    "new_script.is_net_request": "Net Request",
    "new_script.title": "name",
    "new_script.script": "JavaScript code",
    "new_script.is_params": "Parameter",
    "new_script.run_test": "run test",
    "new_script.test_params": "parameter of test",
    "script.net_help": (
        "\nTo facilitate network requests, this app provides a built-in JavaScript function:\n"
        "    async function otterRequest(url, method, params, headers)\n"
        "The parameters are the request address, request method, request parameters, and request headers respectively.\n\n"
        "The return result of this function is an object, containing two fields,\n"
        "One is the statusCode field, which is the code returned by the network request, such as 404, 200, 500, etc;\n"
        "The other is the body field, which is the data returned by the network request and is of a string type;\n\n"
        "Please refer to the following two simple examples:\n\n"
        "   async function main() {\n"
        "      var url = \"https://reqres.in/api/users\";\n"
        "      var params = {\"page\" : 2};\n"
        "      const json = await otterRequest(url, \"get\", params);\n"
        "      return json.body;\n"
        "   }\n\n"
        "    async function main() {\n"
        "        var url = \"https://reqres.in/api/users\";\n"
        "        var params = {\n"
        "            \"name\": \"morpheus\",\n"
        "            \"job\": \"leader\"\n"
        "        };\n"
        "        const json = await otterRequest(url, \"POST\", params);\n"
        "        const res = JSON.parse(json.body);\n"
        "        return res.id;\n"
        "    }\n"
    ),
    "setting.section.about": "About",
    "setting.section.release_notes": "Versions Release Notes",
    "setting.section.q&a": "Questions and Answers",
    "setting.keyboard": "Keyboard",
    "setting.section.auto_save": "Auto Save System Clipboard",
    "setting.section.big_boom": "Explosion Word Segmentation",
    "setting.section.is_emoji": "Using Emoji in the sidebar",
    "setting.keyboard_order.title": "Keyboard Height",
    "setting.menu_order.title": "Menu Order",
    "setting.is_sound.is_sound": "Sound",
    "setting.is_sound.is_vibration": "Haptic",
    "setting.section.jump_to_setting": "System Permission Settings",
    "keyboard.height.portrait": "Height in portrait",
    "keyboard.height.landscape": "Height in landscape",
    "add_keyboard.title": "Add the keyboard",
    "add_keyboard.intro": "\n     Select Keyboards in Settings > Select Otter Keyboard Tools\n",
    "button.add_keyboard.title": "Go to add keyboard",
    "button.into_app.title": "Start adding the keyboard",
    "button.next_setp.title": "Next",
    "app_display_name": "otter keyboard tool",
    "about.version": "version",
    "about.contact_me": "contact us",
    "about.feedback": "feedback",
    "release_note.1.2": (
        "\nNew features:\n"
        "1. Using Emoji in the sidebar of common phrases and scripts in the keyboard, simplified interface display\n"
        "2. Added the keyboard height adjustment\n"
        "3. Add keyboard sound and haptic\n"
        "4. Add space key and enter key to the keyboard, you can send messages directly in the chat app\n"
        "5. The item of the clipboard history can be quickly added to common phrase\n"
    ),
    "release_note.1.1.1": (
        "\nNew features:\n"
        "1. Added network request function to the script, allowing it to retrieve network data.\n\n"
        "Bugs:\n"
        "1. Fixed an issue where the color was incorrect after deselecting the exploding word segmentation in night mode.\n"
    ),
    "release_note.1.1": (
        "\nExplosion Word Segmentation:\n"
        "1. Long press on an item in the Otter keyboard to enter the word segmentation interface for selection and operation.\n"
        "2. In the explosion word segmentation interface, you can perform deletion operations on the clipboard history.\n\n"
        "New features:\n"
        "1. Optimized reminder display.\n"
        "2. Optimized the keyboard selection interface to address the issue of the Otter keyboard name being too long.\n"
    ),
    "release_note.1.0.1": (
        "\nNew Features:\n"
        "1. Added a one-click feature to clear clipboard history.\n"
        "2. Introduced the ability to modify commonly used phrases.\n"
        "3. Added functionality to copy text from the clipboard and commonly used phrases to the system clipboard with a simple click.\n\n"
        "Bugs:\n"
        "1. Fixed the issue where the clipboard wasn't automatically copied when switching to the Water Otter Input Tool keyboard.\n"
        "2. Resolved the problem of script malfunction when parameters are multiline, preventing normal text generation.\n"
    ),
    "script.introduce.question_1": "What should I do if I have scripting needs but can't write code?",
    "script.introduce.answer_1": "Please contact the author through the email in \"Settings>About\" in the app and send the script requirement description to us. We will provide assistance as much as possible.",
    "script.introduce.question_2": "How does the script work?",
    "script.introduce.answer_2": "1. Use the JavaScript runtime container provided by the iOS system to run script code\n2. User-defined JavaScript script code needs to include a main function as a startup entry for the runtime container to call\n3. The main function needs to return a string or string array, and the return value is displayed on the keyboard as input candidates.",
    "script.introduce.question_3": "How to add parameter to script?",
    "script.introduce.answer_3": "1. When adding or editing a script, select the 'Parameter' option\n2. Define the main function as 'function main(arg)', and you can use the arg parameter in the main function",
    "script.introduce.question_4": "For scripts that require parameter, what are the optional parameter?",
    "script.introduce.answer_4": "1. When the keyboard is switched to Otter Keyboard Tool, click the script, click the corresponding script name, and the parameters to be selected will appear.\n2. The clipboard list will appear in the parameters to be selected.",
    "script.introduce.question_5": "How to quickly use the text being entered in the input box as a script parameter?",
    "script.introduce.answer_5": "1. Click Settings in the app > System permission settings, jump to system settings, click Keyboard > Allow full access. Give the app permission to read the current input box\n2. Select the text that needs to be used as a parameter, click the script name, and the selected text will appear first among the parameters to be selected.",
    "script.choose_params.tip": "choose parameter from clipboard list",
    "boom.input": "Choose",
    "big_boom": "Explosion Word Segmentation",
    "fullaccess.tip": "Allow full keyboard access to enable copying.",
    "data_in_app_and_keyboard.tip": "The content can be quickly entered on the keyboard",
}

ZH = {
    "bottom_bar.clipboard": "剪贴板",
    "bottom_bar.phrase": "常用语",
    "bottom_bar.script": "脚本",
    "bottom_bar.setting": "设置",
    "clipboard.list_title": "剪贴板列表",
    "clipboard_empty.tip1": "点击",
    "clipboard_empty.tip2": "从系统剪贴板复制",
    "new_clipboard.title": "添加到剪贴板列表",
    "clipboard.delete_all.tip": "确定删除所有剪贴板记录吗？",
    "cancel": "取消",
    "ok": "确定",
    "save": "保存",
    "delete": "删除",
    "pasted.tip": "已复制",
    "save.success": "保存成功",
    "save.to_phrase": "存为常用语",
    "phrase_set.list_title": "常用语",
    "phrase_empty.tip1": "常用语为空，请点击",
    "phrase_empty.tip2": "添加",
    "new_phrase_set.name": "名称",
    "new_phrase_set.title": "新建常用语分组",
    "new_phrase.title": "新建常用语",
    "script.list_title": "脚本",
    "scripts_empty.tip1": "脚本为空，",
    "scripts_empty.tip2": "去添加",
    "new_script.is_net_request": "网络请求",
    "new_script.title": "名称",
    "new_script.script": "JavaScript 代码",
    "new_script.is_params": "参数",
    "new_script.run_test": "运行测试",
    "new_script.test_params": "测试参数",
    "script.net_help": (
        "\n为方便网络请求，本 App 在 JavaScript 脚本中提供了一个内置函数：\n"
        "    async function otterRequest(url, method, params, headers)\n"
        "参数分别为请求地址、请求方法、请求参数、请求头。\n\n"
        "该函数的返回结果是一个对象，包含两个字段：\n"
        "一个是 statusCode 字段，为网络请求返回的 code，如 404、200、500 等；\n"
        "另一个是 body 字段，为网络请求返回的数据，类型为字符串。\n\n"
        "请参考以下两个简单示例：\n\n"
        "   async function main() {\n"
        "      var url = \"https://reqres.in/api/users\";\n"
        "      var params = {\"page\" : 2};\n"
        "      const json = await otterRequest(url, \"get\", params);\n"
        "      return json.body;\n"
        "   }\n\n"
        "    async function main() {\n"
        "        var url = \"https://reqres.in/api/users\";\n"
        "        var params = {\n"
        "            \"name\": \"morpheus\",\n"
        "            \"job\": \"leader\"\n"
        "        };\n"
        "        const json = await otterRequest(url, \"POST\", params);\n"
        "        const res = JSON.parse(json.body);\n"
        "        return res.id;\n"
        "    }\n"
    ),
    "setting.section.about": "关于",
    "setting.section.release_notes": "版本更新日志",
    "setting.section.q&a": "常见问题",
    "setting.keyboard": "键盘",
    "setting.section.auto_save": "自动保存系统剪贴板",
    "setting.section.big_boom": "爆炸分词",
    "setting.section.is_emoji": "侧栏使用 Emoji",
    "setting.keyboard_order.title": "键盘高度",
    "setting.menu_order.title": "菜单顺序",
    "setting.is_sound.is_sound": "声音",
    "setting.is_sound.is_vibration": "震动",
    "setting.section.jump_to_setting": "系统权限设置",
    "keyboard.height.portrait": "竖屏高度",
    "keyboard.height.landscape": "横屏高度",
    "add_keyboard.title": "添加键盘",
    "add_keyboard.intro": "\n     在 设置 > 键盘 > 键盘 中选择 水獭键盘工具\n",
    "button.add_keyboard.title": "去添加键盘",
    "button.into_app.title": "开始添加键盘",
    "button.next_setp.title": "下一步",
    "app_display_name": "水獭键盘工具",
    "about.version": "版本",
    "about.contact_me": "联系我们",
    "about.feedback": "反馈",
    "release_note.1.2": (
        "\n新功能：\n"
        "1. 常用语和脚本的侧栏使用 Emoji，简化界面显示\n"
        "2. 新增键盘高度调节\n"
        "3. 新增键盘声音和震动\n"
        "4. 键盘新增空格键和回车键，可在聊天 App 中直接发送消息\n"
        "5. 剪贴板历史中的条目可快速添加到常用语"
    ),
    "release_note.1.1.1": (
        "\n新功能：\n"
        "1. 脚本新增网络请求功能，可获取网络数据。\n\n"
        "修复：\n"
        "1. 修复夜间模式下爆炸分词取消选中后颜色错误的问题。"
    ),
    "release_note.1.1": (
        "\n爆炸分词：\n"
        "1. 长按水獭键盘中的条目，进入分词界面进行选择和操作。\n"
        "2. 在爆炸分词界面可对剪贴板历史进行删除操作。\n\n"
        "新功能：\n"
        "1. 优化提醒显示。\n"
        "2. 优化键盘选择界面，解决水獭键盘名称过长的问题。"
    ),
    "release_note.1.0.1": (
        "\n新功能：\n"
        "1. 新增一键清空剪贴板历史功能。\n"
        "2. 新增修改常用语功能。\n"
        "3. 新增从剪贴板和常用语一键复制到系统剪贴板功能。\n\n"
        "修复：\n"
        "1. 修复切换到水獭键盘时剪贴板未自动复制的问题。\n"
        "2. 修复脚本参数为多行时无法正常生成文本的问题。"
    ),
    "script.introduce.question_1": "有脚本需求但不会写代码怎么办？",
    "script.introduce.answer_1": "请在 App 内「设置>关于」中通过邮箱联系作者，发送脚本需求描述，我们会尽量提供帮助。",
    "script.introduce.question_2": "脚本的原理是什么？",
    "script.introduce.answer_2": "1. 使用 iOS 系统提供的 JavaScript 运行容器执行脚本代码\n2. 用户自定义的 JavaScript 代码需要包含一个 main 函数作为运行容器调用的入口\n3. main 函数需要返回一个字符串或字符串数组，返回值会作为候选词显示在键盘上。",
    "script.introduce.question_3": "如何为脚本添加参数？",
    "script.introduce.answer_3": "1. 在新增或编辑脚本时选择「参数」选项\n2. 将 main 函数定义为 function main(arg)，即可在 main 中使用 arg 参数",
    "script.introduce.question_4": "需要参数的脚本，可选参数有哪些？",
    "script.introduce.answer_4": "1. 当键盘切换到水獭键盘工具时，点击脚本，点击对应脚本名称，会出现待选参数\n2. 剪贴板列表会出现在待选参数中",
    "script.introduce.question_5": "如何快速把输入框中正在输入的文字作为脚本参数？",
    "script.introduce.answer_5": "1. 在 App 内点击 设置>系统权限设置，跳转到系统设置，点击 键盘>允许完全访问，赋予 App 读取当前输入框的权限\n2. 选中需要作为参数的文字，点击脚本名称，选中文字会出现在待选参数的第一位",
    "script.choose_params.tip": "从剪贴板列表中选择参数",
    "boom.input": "选择",
    "big_boom": "爆炸分词",
    "fullaccess.tip": "允许键盘完全访问才能启用复制",
    "data_in_app_and_keyboard.tip": "该内容可在键盘上快速输入",
}


def escape(s: str) -> str:
    s = s.replace("\\", "\\\\")
    s = s.replace('"', '\\"')
    s = s.replace("\n", "\\n")
    s = s.replace("\r", "\\r")
    s = s.replace("\t", "\\t")
    return s


def write_table(path, table):
    lines = []
    for k in sorted(table.keys()):
        v = table[k]
        lines.append('"%s" = "%s";' % (escape(k), escape(v)))
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("wrote", path, len(table), "entries")


BASE = os.path.dirname(os.path.abspath(__file__))
write_table(os.path.join(BASE, "OtterKeyboardTool", "en.lproj", "Localizable.strings"), EN)
write_table(os.path.join(BASE, "OtterKeyboardTool", "zh-Hans.lproj", "Localizable.strings"), ZH)
write_table(os.path.join(BASE, "KeyboardExtension", "en.lproj", "Localizable.strings"), EN)
write_table(os.path.join(BASE, "KeyboardExtension", "zh-Hans.lproj", "Localizable.strings"), ZH)
