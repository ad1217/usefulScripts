#!/usr/bin/python2
import sensors
import subprocess
from glob import glob

sensorsToShow = {'Physical id 0': ["C", 70,100],
                 'Left side  '  : ["RPM", 3000,5000]}

cpuGovernors = { "powersave" :  '<span fgcolor="green">s</span>',
                 "performance": '<span fgcolor="red">p</span>',
                 "ondemand":    '<span fgcolor="yellow">o</span>'}

out = ""
cpuGovernor = ""
sensors.init()
try:
    for chip in sensors.iter_detected_chips():
        for feature in chip:
            if feature.label in sensorsToShow:
                color = ("#00B000" if feature.get_value() < sensorsToShow[feature.label][1]
                         else ("yellow" if feature.get_value() < sensorsToShow[feature.label][2]
                               else "red"))
                out += '<span fgcolor="%s">%.f%s</span> ' % (color, feature.get_value(), sensorsToShow[feature.label][0])
    out += '<span>%.2f%s</span>' % (float(max(subprocess.check_output("grep MHz /proc/cpuinfo | grep -o '[\.0-9]*'", shell=True).split()))/1000, "GHz")

    out += " "
    for i in glob("/sys/devices/system/cpu/cpu[0-9]/cpufreq/scaling_governor"):
        out += cpuGovernors[open(i).read().replace("\n", "")]

    print "<txt>" + out + "</txt>"
finally:
    sensors.cleanup()

