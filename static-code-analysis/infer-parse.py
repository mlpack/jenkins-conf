import json
import xml.sax.saxutils

with open('infer-out/report.json') as f:
    issues = json.load(f)

with open('reports/infer-report.xml', 'w') as f:
    for issue in issues:
        msg = xml.sax.saxutils.escape(issue['qualifier'], {'"' : "&quot;", "'" : "&apos;"}).strip()
        f.write('''<error id="err" severity="error" msg="%s" verbose="%s">\n''' % (msg, msg))
        f.write('''<location file="%s" line="%s"/>\n''' % (issue['file'].strip(), issue['line']))
        f.write('''</error>\n''')