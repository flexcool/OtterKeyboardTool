import re, glob, os

keys = set()
for f in ['OtterKeyboardTool/en.lproj/Localizable.strings',
         'KeyboardExtension/en.lproj/Localizable.strings']:
    txt = open(f, encoding='utf-8').read()
    for m in re.findall(r'^\s*"([^"]+)"\s*=', txt, re.M):
        keys.add(m)

used = set()
for path in glob.glob('**/*.swift', recursive=True):
    txt = open(path, encoding='utf-8').read()
    for m in re.findall(r'TL\(\s*"([^"]+)"', txt):
        used.add(m)

missing = sorted(k for k in used if k not in keys)
print('strings keys:', len(keys))
print('TL() keys used:', len(used))
print('MISSING:', len(missing))
for k in missing:
    print('  ', k)
