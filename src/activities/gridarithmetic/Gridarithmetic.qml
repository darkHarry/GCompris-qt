/* GCompris - gridarithmetic.qml
 *
 * Copyright (C) 2018 YOUR NAME <xx@yy.org>
 *
 * Authors:
 *   <THE GTK VERSION AUTHOR> (GTK+ version)
 *   YOUR NAME <YOUR EMAIL> (Qt Quick port)
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.6

import "../../core"
import "gridarithmetic.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    pageComponent: Rectangle {
        id: background
        anchors.fill: parent
        color: "#ABCDEF"
        height: width
        signal start
        signal stop


        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias background: background
            property alias bar: bar
            property alias expression: expression.text
            property alias repeater: repeater
            property alias cells: repeater.model
            property real rows: Math.sqrt(cells)
            property real columns: Math.sqrt(cells)
            property alias bonus: bonus
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        Rectangle {
            id: interactionArea
            width: Math.min(background.width, background.height)
            height: width
            anchors.horizontalCenter: background.horizontalCenter
            anchors.top: background.top

            Column {
                width: interactionArea.width
                height: interactionArea.height

                // Top MenuBar
                Row {
                    id: menuBar
                    width: parent.width
                    spacing: 10

                    GCText {
                        id: expression
                        width: menuBar.width / 2
                        height: menuBar.height
                        color: "#00D0D0"
                    }

                    BarButton {
                        id: okButton
                        source: "qrc:/gcompris/src/core/resource/bar_ok.svg"
                        sourceSize.height: menuBar.height
                        onClicked: Activity.checkWin()
                    }

                }

                // Bottom Grid
                Grid {
                    id: arithmeticBoard
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: interactionArea.height - menuBar.height
                    width: height
                    rows: 5
                    columns: 5

                    Repeater {
                        id: repeater
                        model: 25
                        delegate: cell

                        Component {
                            id: cell

                            Rectangle {
                                id: cellSquare
                                width: arithmeticBoard.width / 5
                                height: arithmeticBoard.height / 5
                                border.width: 2
                                border.color: "#000000"

                                property alias cellText: cellSquareText.text
                                property alias cellTextColor: cellSquareText.color

                                TextInput {
                                    id: cellSquareText
                                    width: cellSquare.width
                                    height: cellSquare.height
                                    font.pixelSize: height * 0.70
                                    padding: 2
                                    maximumLength: 1
                                    horizontalAlignment: TextInput.AlignHCenter
                                    validator: RegExpValidator { regExp: /[0-9+-*=]/ }
                                    text: ""
                                    color: "#000000"
                                }
                            }
                        }
                    }
                }
            }
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: help | home | reload | level }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onReloadClicked: Activity.initLevel()
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(Activity.nextLevel)
        }
    }

}
