import json
import xml.sax.saxutils
import re
import os

with open('deepcode.txt', mode="r", encoding="utf-8") as f:
    issues = f.readlines()

cwd = str(os.getcwd())
ansiEscape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
with open('reports/deepcode-report.xml', 'w') as f:
    i = 0
    while i < len(issues):
        if 'Warning issues' in issues[i]:
            filename, msg = issues[i + 1].split(' ', 1)
            linenumber = issues[i + 3].strip().split(' ')[1]
            linenumber = linenumber.split(',')[0]
            msg = ansiEscape.sub('', msg).strip()
            filename = ansiEscape.sub('', filename).strip()
            msg = xml.sax.saxutils.escape(msg, {'"' : "&quot;", "'" : "&apos;"}).strip()

            if len(filename) != 0:
                f.write('''<error id="err" severity="error" msg="%s" verbose="%s">\n''' % (msg, msg))
                f.write('''<location file="%s" line="%s"/>\n''' % (cwd + filename.strip(), linenumber))
                f.write('''</error>\n''')
            i += 3
        elif 'missue helpers' in issues[i]:
            linenumber = issues[i + 1].strip().split(' ')[1]
            linenumber = linenumber.split(',')[0]
            if len(issues[i + 2].split(' ', 1)) > 1:
                filename, msg = issues[i + 2].split(' ', 1)
                filename = ansiEscape.sub('', filename).strip()
                msg = ansiEscape.sub('', msg).strip()
                msg = xml.sax.saxutils.escape(msg, {'"' : "&quot;", "'" : "&apos;"}).strip()
                if len(filename) != 0:
                    f.write('''<error id="err" severity="error" msg="%s" verbose="%s">\n''' % (msg, msg))
                    f.write('''<location file="%s" line="%s"/>\n''' % (cwd + filename.strip(), linenumber))
                    f.write('''</error>\n''')
            i += 3
        else:
            i += 1
