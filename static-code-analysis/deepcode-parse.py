import json
import xml.sax.saxutils
import os

cwd = str(os.getcwd())
with open('deepcode.txt') as jf:
    data = json.load(jf)

    with open('reports/deepcode-report.xml', 'w') as f:
        for filename in data["results"]["files"].keys():
            for ffk, ffv in data["results"]["files"][filename].items():
                msg = data["results"]["suggestions"][ffk]["message"]
                msg = xml.sax.saxutils.escape(msg, {'"' : "&quot;", "'" : "&apos;"}).strip()
                line = data["results"]["files"][filename][ffk][0]["rows"][0]

                f.write('''<error id="err" severity="error" msg="%s" verbose="%s">\n''' % (msg, msg))
                f.write('''<location file="%s" line="%s"/>\n''' % (cwd + filename.strip(), line))
                f.write('''</error>\n''')
