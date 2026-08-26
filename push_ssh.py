import subprocess, sys, os

REPO = r"G:\Minke\OtterKeyboardTool"
BRANCH = "main"
REF = "refs/heads/" + BRANCH
SSH = r"C:\Windows\System32\OpenSSH\ssh.exe"
KEY = r"G:\Minke\OtterKeyboardTool\id_otter"
REMOTE = "git@github.com"
REPO_PATH = "flexcool/OtterKeyboardTool.git"

def git(args, capture=True):
    return subprocess.run(["git"] + args, cwd=REPO,
                           stdout=subprocess.PIPE if capture else None,
                           stderr=subprocess.PIPE if capture else None)

def pkt_line(data: bytes) -> bytes:
    if len(data) == 0:
        return b"0000"
    return ("%04x" % (len(data) + 4)).encode() + data

def read_pktlines(stream):
    lines = []
    while True:
        hdr = stream.read(4)
        if len(hdr) < 4:
            break
        if hdr == b"0000":
            break
        n = int(hdr.decode(), 16)
        body = stream.read(n - 4)
        lines.append(body)
    return lines

# 1) local sha
new_sha = git(["rev-parse", BRANCH]).stdout.decode().strip()
print("local", BRANCH, "=", new_sha)

# 2) advertisement
cmd = [SSH, "-i", KEY, "-o", "UserKnownHostsFile=NUL",
       "-o", "StrictHostKeyChecking=accept-new", "-T", REMOTE,
       "git-receive-pack '%s'" % REPO_PATH]
print("ssh:", " ".join(cmd))
proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
advert = read_pktlines(proc.stdout)
print("advertisement lines:", len(advert))
old_sha = "0" * 40
for line in advert:
    if REF.encode() in line:
        # format: <40hex> SP <ref> [NUL caps]
        old_sha = line.split(b" ")[0].decode()
        print("remote existing", REF, "=", old_sha)
        break
else:
    print("remote has no", REF, "-> creating")

# 3) pack all objects
po = git(["pack-objects", "--all", "--stdout"])
pack = po.stdout
print("pack bytes:", len(pack), "stderr:", po.stderr.decode().strip()[:120])

# 4) command + flush + pack
caps = b"report-status agent=git/2.0"
cmd_line = ("%s %s %s\x00%s\n" % (old_sha, new_sha, REF, caps.decode())).encode()
payload = pkt_line(cmd_line) + b"0000" + pack
proc.stdin.write(payload)
proc.stdin.flush()
proc.stdin.close()

# 5) read report
report = proc.stdout.read()
proc.stdout.close()
err = proc.stderr.read()
proc.wait()
print("=== report (stdout) ===")
print(report.decode(errors="replace"))
print("=== stderr ===")
print(err.decode(errors="replace")[:400])
print("ssh exit:", proc.returncode)
if b"unpack ok" in report or b"ok" in report:
    print("PUSH LIKELY SUCCEEDED")
else:
    print("PUSH may have failed")
