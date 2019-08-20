import QtQuick 2.3
import QtQuick.Window 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.0
import QtMultimedia 5.13
import QtGraphicalEffects 1.0

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 303
    height: 67
    title: qsTr("QT音乐播放器")

    color:Qt.rgba(0,0,0,0)

    minimumWidth: 303
    minimumHeight: 67
    maximumWidth: 303
    maximumHeight: 67

    Image{
        id:bug
        source:"qrc:/background.png"
        sourceSize: Qt.size(parent.width, parent.height)
        smooth: true
        visible: false
    }

    /*透明度控件*/
    FastBlur {
        anchors.fill: bug
        source: bug
        transparentBorder: true
        radius: transparencySlider.value
    }

    ColumnLayout {

        anchors.leftMargin : 9
        anchors.rightMargin : 9
        anchors.bottomMargin : -10
        anchors.fill: parent

        Label {
//            Layout.minimumHeight: Qt.implicitHeight
            Layout.fillWidth: true
            Layout.fillHeight: true
        }


        RowLayout {

            Slider {
                id: transparencySlider
                Layout.fillWidth: true
                maximumValue : 100
                minimumValue : 0
                orientation : Qt.Horizontal
                stepSize : 1
                updateValueWhileDragging : true
            }

            Label {
                Layout.topMargin: -13 //距离底端边缘的距离
                text: transparencySlider.value.toString() + '%'
                font.pixelSize: 16
                font.italic: true
                font.letterSpacing:0
                font.strikeout : false
                font.weight : Font.ExtraLight
                font.bold : false
                color: "white"
            }
        }
    }

    MediaPlayer {
        id: mediaPlayer
        autoPlay: true
        source : url
        loops: MediaPlayer.Infinite
        readonly property string title: !!metaData.author && !!metaData.title
                                        ? qsTr("%1 - %2").arg(metaData.author).arg(metaData.title)
                                        : metaData.author || metaData.title || source
    }

    ColumnLayout {
        id: column

        anchors.margins: 9
        anchors.fill: parent

        Label {
           id: infoLabel

            elide: Qt.ElideLeft
            verticalAlignment: Qt.AlignVCenter
            text: mediaPlayer.errorString || mediaPlayer.title
            Layout.minimumHeight: infoLabel.implicitHeight
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: 12
        }


        RowLayout {
            id: row

            Button {
                id: openButton

                text: qsTr("打开音乐文件")
                Layout.preferredWidth: openButton.implicitWidth
                Layout.preferredHeight: openButton.implicitHeight-6
                onClicked: fileDialog.open()

                FileDialog {
                    id: fileDialog

                    folder : musicUrl
                    title: qsTr("选择一个音乐文件")
                    nameFilters: [qsTr("MP3 文件 (*.mp3)"), qsTr("无损 文件 (*.flac && *.ape && *.wav)"), qsTr("所有 文件 (*.*)")]
                    onAccepted: mediaPlayer.source = fileDialog.fileUrl
                }
            }

            Button {
                id: playButton

                enabled: mediaPlayer.hasAudio
                Layout.preferredWidth: playButton.implicitHeight
                iconSource: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "qrc:/pause-16.png" : "qrc:/play-16.png"
                onClicked: mediaPlayer.playbackState === MediaPlayer.PlayingState ? mediaPlayer.pause() : mediaPlayer.play()
            }

            Slider {
                id: positionSlider
//                Layout.topMargin: -7 //距离底端边缘的距离

                Layout.fillWidth: true
                maximumValue: mediaPlayer.duration

                property bool sync: false

                onValueChanged: {
                    if (!sync)
                        mediaPlayer.seek(value)
                }

                Connections {
                    target: mediaPlayer
                    onPositionChanged: {
                        positionSlider.sync = true
                        positionSlider.value = mediaPlayer.position
                        positionSlider.sync = false
                    }
                }
            }

            Label {
                id: positionLabel

                readonly property int minutes: Math.floor(mediaPlayer.position / 60000)
                readonly property int seconds: Math.round((mediaPlayer.position % 60000) / 1000)

                text: Qt.formatTime(new Date(2019, 6, 20, 0, minutes, seconds, 0), qsTr("mm:ss"))
                font.pixelSize: 16
                font.italic: true
                font.letterSpacing:0
                font.strikeout : false
                font.weight : Font.ExtraLight
                font.bold : false
                color: "white"
            }
        }
    }
}
