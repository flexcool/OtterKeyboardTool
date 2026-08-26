import subprocess

SSH = r"C:\Windows\System32\OpenSSH\ssh.exe"
KEY = r"G:\Minke\OtterKeyboardTool\id_otter"
REPO = "flexcool/OtterKeyboardTool.git"
LOCAL = "1142a985531a6e4fc05815ce921fa8ae74426cde"

cmd = [SSH, "-i", KEY, "-o", "UserKnownHostsFile=NUL",
       "-o", "StrictHostKeyChecking=accept-new", "-T", "git@github.com",
       "git-receive-pack '%s'" % REPO]
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
buf = b""
while True:
    h = p.stdout.read(4)
    if len(h) < 4 or h == b"0000":
        break
    n = int(h.decode(), 16)
    buf += p.stdout.read(n - 4)
p.wait()

found = None
for line in buf.split(b"\n"):
    if b"refs/heads/main" in line:
        found = line.split(b" ")[0].decode()
        print("remote main =", found)
if found == LOCAL:
    print("VERIFIED: remote main matches local commit -> PUSH OK")
else:
    print("remote main != local; check manually")
