from xml.sax.saxutils import escape

with open('build/res.txt', 'r') as f:
  lines = f.readlines()

output = '<?xml version="1.0" encoding="UTF-8"?>'

meta = {'duration' : 0}
suiteName = None
error = None
for line in lines:
  line = line.strip()

  if 'Entering test suite "' in line:
    start = line.find('Entering test suite "')
    suiteName = line[start + 21:-2]
    meta[suiteName] = {'time': 0, 'failures': 0, 'tests' : 0}
    meta[suiteName]['cases'] = []

  if 'error: in' in line:
    error = line

  if 'Leaving test case' in line:
    start = line.find('; testing time: ')
    tt = 0
    if start > 0:
      lineType = line[start + 16:len(line)]
      if 'mks' in lineType:
        tt = float(line[start + 16:len(line) - 3]) * 0.001
      elif 'ms' in lineType:
        tt = float(line[start + 16:len(line) - 2]) * 0.001
      elif 'us' in lineType:
        tt = float(line[start + 16:len(line) - 2]) * 0.000001
      else:
        raise ValueError("Can't parse the given format: " + lineType)

    meta['duration'] += tt

    start = line.find('Leaving test case "')
    end = line.find('";', start)
    case = line[start + 19:end]

    if error != None:
      meta[suiteName]['failures'] += 1

    meta[suiteName]['cases'].append((case, tt, error))
    meta[suiteName]['time'] += tt
    meta[suiteName]['tests'] += 1

    error = None

output += '\n<testsuites duration="' + str("{:.5f}".format(meta['duration'])) + '">'

for key, value in meta.items():
  if key != 'duration':
    output += '\n    <testsuite failures="' + str(meta[key]['failures']) + '" name="' + key + '" package="mlpack" tests="' + str(meta[key]['tests']) + '" time="' + str("{:.5f}".format(meta[key]['time'])) + '">'

    for info in meta[key]['cases']:
      if info[2] == None:
        output += '\n        <testcase classname="' + info[0] + '" name="' + info[0] + '" time="' +  str("{:.5f}".format(info[1])) + '"/>'
      else:
        failureMessageStart = info[2].find('":')
        failureMessage = info[2][failureMessageStart + 3:]

        output += '\n        <testcase classname="' + info[0] + '" name="' + info[0] + '" time="' +  str("{:.5f}".format(info[1])) + '">'
        output += '\n            <failure message="' + escape(failureMessage) + '">' +  escape(info[2]) + '</failure>'
        output += '\n        </testcase>'

    output += '\n    </testsuite>'
output += '\n</testsuites>'

print(output)
