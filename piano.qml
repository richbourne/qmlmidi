import QtQuick 2.3

import org.komplex.qmlmidi 1.0

Rectangle
{
    id: main

    width: 640
    height: 480

    color: "slategrey"

    property font defaultFont
    defaultFont.family: "Helvetica Neue"
    defaultFont.pixelSize: 24

    property color textColor: "ivory"

    Column
    {
        id: column
        anchors.fill: parent

        Repeater {
            model: [
                "Input Port Count: " + synth.portCount,
                "Input Port: "+synth.portName,
                "Output Port: "+synthOut.portName,
                "Output Program: #"+synthOut.program,
            ]
            Text {
                x: 6
                width: column.width - 6
                text: modelData
                font: defaultFont
                color: textColor
                wrapMode: Text.WordWrap
            }
        }
    }

    MidiIn
    {
        id:synth
        port:0
        active: true

        property int program: 0

        onData: {
            console.log("data: " + data);
        }
    }

    MidiOut
    {
        id:synthOut
        port:0

        property int program: 0


        onPortChanged: {
            program=0;
        }


        onProgramChanged: {
            sendMessage(0xc0, program, 0);
        }
    }


    Item {
        id:piano
        anchors.fill: parent
        focus: true

        property bool lights: false

        function key2note(keycode)
        {
            var ch=String.fromCharCode(keycode);
            var n = "Q2W3ER5T6Y7UI9O0P".indexOf(ch);
            if(n==-1) return -1;
            return n+60;
        }

        Keys.onTabPressed:
        {
            console.log("lights on?");
            synthOut.sendMessage(0xB0, 0x00, lights ? 0x00 : 0x7F);
            lights = !lights
        }

        Keys.onPressed:
        {
            if(event.isAutoRepeat) return;
            var k=key2note(event.key);
            //synth.sendMessage(0x90, k, 100);
        }
        Keys.onReleased:
        {
            var k=key2note(event.key);
            //synth.sendMessage(0x80, k, 0);
        }

        Keys.onUpPressed:
        {
            if (synth.port+1<synth.portCount)
            {
                synth.port++;
                synthOut.port++;
            }
        }

        Keys.onDownPressed:
        {
            if(synth.port>0)
            {
                synth.port--;
                synthOut.port--;
            }
        }

        Keys.onLeftPressed:
        {
            synth.program--;
            //synthOut.program--;
        }

        Keys.onRightPressed:
        {
            synth.program++;
            //synthOut.program++;
        }
    }

    Component.onCompleted:
    {
        console.log(synth.portNames[0])
    }
}
