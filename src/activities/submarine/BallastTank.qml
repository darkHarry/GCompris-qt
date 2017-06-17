/* GCompris - BallastTank.qml
 *
 * Copyright (C) 2017 RUDRA NIL BASU <rudra.nil.basu.1996@gmail.com>
 *
 * Authors:
 *   Pascal Georges <pascal.georges1@free.fr> (GTK+ version)
 *   Rudra Nil Basu <rudra.nil.basu.1996@gmail.com> (Qt Quick port)
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

Item {
    property int initialWaterLevel
    property int waterLevel: 0
    property int maxWaterLevel
    property int waterRate: 10
    property bool waterFilling: false
    property bool waterFlushing: false

    function getCurrentWaterLevel() {
        return waterLevel
    }

    function getMaximumWaterLevel() {
        return maxWaterLevel
    }

    function fillBallastTanks() {
        waterFilling = !waterFilling

        if (waterFilling) {
            fillBallastTanks.start()
        } else {
            fillBallastTanks.stop()
        }
    }

    function flushBallastTanks() {
        waterFlushing = !waterFlushing

        if (waterFlushing) {
            flushBallastTanks.start()
        } else {
            flushBallastTanks.stop()
        }
    }

    function updateWaterLevel(isInflow) {
        if (isInflow) {
            if (waterLevel < maxWaterLevel) {
                waterLevel += waterRate

            }
        } else {
            if (waterLevel > 0) {
                waterLevel -= waterRate
            }
        }

        if (waterLevel > maxWaterLevel) {
            waterLevel = maxWaterLevel
        }

        if (waterLevel < 0) {
            waterLevel = 0
        }
        console.log("Current water level: "+waterLevel)
    }

    function resetBallastTanks() {
        waterFilling = false
        waterFlushing = false

        waterLevel = initialWaterLevel

        fillBallastTanks.stop()
        flushBallastTanks.stop()
    }

    Timer {
        id: fillBallastTanks
        interval: 500
        running: false
        repeat: true

//        onTriggered: submarine.updateWaterLevel(true)
        onTriggered: updateWaterLevel(true)
    }

    Timer {
        id: flushBallastTanks
        interval: 500
        running: false
        repeat: true

//        onTriggered: submarine.updateWaterLevel(false)
        onTriggered: updateWaterLevel(false)
    }
}