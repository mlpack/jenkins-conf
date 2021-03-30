import json
import xml.sax.saxutils
import re

with open('build/project.tasks') as f: lines = [line.rstrip('\n') for line in f]

r = re.compile('(.*)(\D+)(\d+)(\D+)(V\d+)(.*)')
with open('reports/pvs-report.xml', 'w') as f:
    for l in lines:
        m = r.match(l.strip())

        if not m:
            continue

        g = m.groups()
        if len(g) != 6:
            continue

        fname, misc, lineno, label, reference, rawmsg = g
        lineno = lineno.strip()
        msg = xml.sax.saxutils.escape(rawmsg, {'"' : "&quot;", "'" : "&apos;"}).strip()

        f.write('''<error id="%s" severity="error" msg="%s" verbose="%s">\n'''%(label.strip(), msg, msg))
        f.write('''<location file="%s" line="%s"/>\n'''%(fname.strip(), lineno))
        f.write('''</error>\n''')