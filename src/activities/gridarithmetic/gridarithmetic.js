/* GCompris - gridarithmetic.js
 *
 * Copyright (C) 2018 YOUR NAME <xx@yy.org>
 *
 * Authors:
 *   <THE GTK VERSION AUTHOR> (GTK+ version)
 *   "YOUR NAME" <YOUR EMAIL> (Qt Quick port)
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
.pragma library
.import QtQuick 2.6 as Quick

// FORMAT: X+Y=Z
var equations = ["12+10=22",
                 "56+7=63",
                 "99+99=198",
                 "1234+3214=4448"]

var currentLevel = 0
var numberOfLevel = 4
var currentEquation = ""
var items

function start(items_) {
    items = items_
    currentLevel = 0
    initLevel()
}

function stop() {
}

function initLevel() {
    items.bar.level = currentLevel + 1
    currentEquation = equations[currentLevel]
    setExpression()
    clearGrid()
}

// iterate through grid and set text empty and color to black
function clearGrid() {

    for (var i = 0; i < items.cells; ++i) {
        var currentCell = items.repeater.itemAt(i)
        currentCell.cellText = ""
        currentCell.cellTextColor = "#000000"
    }
}

// TODO make scalable
function currentEquationToArray() {
    var equationArray = []
    var indexOfOperator = currentEquation.indexOf("+")
    var indexOfEqual = currentEquation.indexOf("=")
    equationArray.push(currentEquation.slice(0, indexOfOperator))
    equationArray.push(currentEquation.slice(indexOfOperator, indexOfEqual))
    equationArray.push(currentEquation.slice(indexOfEqual))

    return equationArray
}

function getRowString(currentRow) {
    var rowString = "", rowStartIndex = currentRow * items.rows

    // iterate each column
    for (var j = 0; j < items.columns; ++j) {
        var index = j + rowStartIndex
        rowString += items.repeater.itemAt(index).cellText  //accumulate strings in a row
    }

    return rowString
}

function setRowStringColor(currentRow, color) {
    var rowStartIndex = currentRow * items.rows

    for (var j = 0; j < items.columns; ++j) {
        var index = j + rowStartIndex
        items.repeater.itemAt(index).cellTextColor = color
    }
}

function checkWin() {
    if (isSolved())
        console.log("WIN")
    else
        console.log("LOSE")
}

function isSolved() {
    // current equation array
    var currentEquationArray = currentEquationToArray()

    // current equation array index
    var currentEquationArrayIndex = 0

    var solveFlag = false

    // iterate each row
    for (var i = 0; i < items.rows; ++i) {

        var rowString = getRowString(i)

        // non-empty rowString
        if (rowString !== "") {

            //
            if (rowString === currentEquationArray[currentEquationArrayIndex]) {
                currentEquationArrayIndex++;
                setRowStringColor(i, "#00FF00") // green
                // All values equal then set solved flag to true
                if (currentEquationArrayIndex === currentEquationArray.length)
                    solveFlag = true

            } else {
                setRowStringColor(i, "#FF0000") // red
                solveFlag = false
                return solveFlag
            }
        }

    }
    return solveFlag
}

function nextLevel() {
    if(numberOfLevel <= ++currentLevel) {
        currentLevel = 0
    }
    initLevel();
}

function previousLevel() {
    if(--currentLevel < 0) {
        currentLevel = numberOfLevel - 1
    }
    initLevel();
}

function setExpression() {
    var indexOfequal = currentEquation.indexOf("=")
    items.expression = currentEquation.substr(0, indexOfequal)
}
