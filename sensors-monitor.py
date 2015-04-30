#!/usr/bin/python2
import sensors
import subprocess

sensorsToShow = {'Physical id 0': ["C", 70,100], 'Left side  ': ["RPM", 3000,5000]}

out = ""
sensors.init()
try:
    for chip in sensors.iter_detected_chips():
        for feature in chip:
            if feature.label in sensorsToShow:
                out += '<span fgcolor="%s">%.f%s</span> ' % ("#00B000" if feature.get_value() < sensorsToShow[feature.label][1] else ("yellow" if feature.get_value() < sensorsToShow[feature.label][2] else "red"), feature.get_value(), sensorsToShow[feature.label][0])
    out += '<span>%.2f%s</span>' % (float(max(subprocess.check_output("cat /proc/cpuinfo | grep MHz | grep -o '[0-9]*'", shell=True).split()))/1000, "GHz")
    print "<txt>" + out + "</txt>"
finally:
    sensors.cleanup()

