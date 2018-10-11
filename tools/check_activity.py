#!/usr/bin/python3
#
# GCompris - check_activity.py
#
# Copyright (C) 2018 Harry Mecwan <harry.mecwan91@gmail.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, see <http://www.gnu.org/licenses/>.

import sys
import os
import glob
import re
import subprocess

def initialize(activity_dir_name):	
    
    # js file name array
    js_files_array = glob.glob(
                        "../src/activities/" + activity_dir_name + "/**/*.js",
                        recursive=True)

    # qml file name array
    qml_files_array = glob.glob(
                        "../src/activities/" + activity_dir_name + "/**/*.qml",
                        recursive=True)

    return js_files_array, qml_files_array


# create elements to escape list
def read_elements_to_escape():
    with open("./check_activities_ids_to_escape.txt", "r") as ids_file:
        print("Element ids escaped:")
        elements_to_escape = [print(ids, end="") for ids in ids_file]    
    return elements_to_escape


# print error
def print_error(error):
    print("\tERROR:  ", error)


# print warning
def print_warning(error):
    print("\tWARNING:", error)


# checks 'variant' used instead of 'var'
def check_var(line_str, line_number):
    if "property variant" in line_str:
        print_warning("line:{} replace variant with var".format(line_number))


# checks import version
def check_import_version(line_str):
    # add modules and version in dictionary
    module_version_dict = { "QtQuick" : "2.6",
                            "QtGraphicalEffects" : "1.0",
                            "QtQuick.Controls" : "1.5",
                            "QtQml" : "2.2",
                            "QtQuick.Controls.Styles" : "1.4",
                            "QtQuick.Particles" : "2.0",
                            "QtSensors" : "5.0",
                            "QtMultimedia" : "5.0",
                            "GCompris" : "1.0",
                            "Box2D" : "2.0",
                            "QtQuick.Window" : "2.2"}
    
    regex_string = re.compile(r"import (\w+) (\d+.\d+)")
    match_string = regex_string.search(line_str)
    if match_string:
        module_name = match_string.group(1)
        module_ver = match_string.group(2)
        correct_module_ver = module_version_dict[module_name]
        if module_ver != correct_module_ver:
            print_error("{} version must be {}".format(module_name, module_ver))


# checks credit updation
def check_credits_update(line_str):
    if "THE GTK VERSION AUTHOR" in line_str:
        print_error("Replace original GTK VERSION AUTHOR label by your own name")

    if "YOUR NAME <YOUR EMAIL>" in line_str or "\"YOUR NAME\" <YOUR EMAIL>" in line_str:
        print_error("Replace original Qt Quick copyright label email by your own email address")


# checks whether qsTr can be used in the line_str
def qsTr_use(line_str, line_number, elements_to_escape):
    regex_string = re.compile("""([^ ]+): ["][^"]+""")
    match_string = regex_string.search(line_str)
    if match_string:
        if match_string.group(1) not in elements_to_escape:
            print_warning("line:{} {} qsTr may not be used".format(line_number, match_string.group(1)))


# checks copyrights updated
def activity_info_qml_file(line_str):
    values_to_test = ["author: \"Your Name &lt;yy@zz.org&gt;\"",
                      "name: \"test/Test.qml\"",
                      "difficulty: 1",
                      "icon: \"test/test.svg\"",
                      "demo: false",
                      "title: \"Test activity\"",
                      "description: \"\"",
                      "goal: \"\"",
                      "prerequisite: \"\"",
                      "manual: \"\"",
                      "credit: \"\"",
                      "section: \"\"",
                      "intro: \"put here in comment the " 
                      "text for the intro voice\""]
    
    for value in values_to_test:
        if value in line_str:
            if value == "difficulty: 1":
                print_warning("{} may not be updated.".format(value))
            else:
                print_error("{} may not be updated.".format(value))


# checks js files
def check_js_files(js_files_array):
    
    for js_file in js_files_array:
        with open(js_file, "r") as current_js_file:
            
            print("\nFilePath:", js_file)
            for line in current_js_file:
                check_credits_update(line)
                check_import_version(line)


# checks qml files
def check_qml_files(qml_files_array, elements_to_escape):
    for qml_file in qml_files_array:
        with open(qml_file, "r") as current_qml_file:

            line_number = 1
            print("\nFilePath:", qml_file)
            if os.path.basename(qml_file) == "ActivityInfo.qml":
                if "createdInVersion" not in current_qml_file.read():
                    print_error("ActivityInfo.qml does not have \"createdInVersion\":\n")
                # reset file pointer to the start
                current_qml_file.seek(0)
            
            for line in current_qml_file:
                if os.path.basename(qml_file) == "ActivityInfo.qml":
                    activity_info_qml_file(line)

                check_credits_update(line)
                qsTr_use(line, line_number, elements_to_escape)
                check_var(line, line_number)
                check_import_version(line)

                line_number += 1


# check if directory empty
def empty_directory(js_files_array, qml_files_array):

    if not js_files_array and not qml_files_array:
        sys.exit("No file to check! Did you enter a correct directory?")


# check all activites
def check_all_activities():

    path = "../src/activities"
    activity_list = [ activity for activity in os.listdir(path)
                      if os.path.isdir(os.path.join(path, activity))]
    activity_list.sort()

    elements_to_escape = read_elements_to_escape()
    
    for activity in activity_list:
        js_files_array, qml_files_array = initialize(activity)
        empty_directory(js_files_array, qml_files_array)
        check_js_files(js_files_array)
        check_qml_files(qml_files_array, elements_to_escape)


# check author name
def check_author_name():
    
    command = ["git", "config", "user.name"]
    author_name = subprocess.run(command, check=True, stdout=subprocess.PIPE)
    author_name = author_name.stdout.decode()[:-1]

    if len(author_name.split()) != 2:
        print("Author name format violation: {}".format(author_name))
        print_error("Author name format <FirstName LastName>")


def main():
    
    if len(sys.argv) < 2:
        sys.exit("\nMissing input filename."
                 "\nUsage: ./check_activity.py activity_directory_name"
                 "\neg: ./check_activity.py reversecount")
    
    if sys.argv[1] == "all":
        check_all_activities()
    else:
        js_files_array, qml_files_array = initialize(sys.argv[1])
        empty_directory(js_files_array, qml_files_array)
        check_js_files(js_files_array)
        elements_to_escape = read_elements_to_escape()
        check_qml_files(qml_files_array, elements_to_escape)

    check_author_name()


# if this file runs
if __name__ == "__main__":
    main()