import Qt 4.7

/**
 * A LineEdit in Mana style
 */
FocusScope {
    property alias text: textInput.text
    property alias labelText: label.text
    property alias echoMode: textInput.echoMode
    property variant tabTarget: KeyNavigation.down;
    property variant backtabTarget: KeyNavigation.up;

    height: 70;
    anchors.margins: 5;

    Keys.onTabPressed: if (tabTarget) tabTarget.focus = true;
    Keys.onBacktabPressed: if (backtabTarget) backtabTarget.focus = true;

    onActiveFocusChanged: textInput.selectAll();

    BorderImage {
        anchors.fill: parent

        source: "images/lineedit.png"
        border.bottom: 20;
        border.top: 20;
        border.right: 20;
        border.left: 20;
    }

    Text {
        id: label;
        x: textInput.x;
        y: textInput.y;
        color: "darkGray";
        font: textInput.font;
        visible: textInput.text == "";
    }

    TextInput {
        id: textInput

        y: 5
        anchors.verticalCenter: parent.verticalCenter;
        anchors.verticalCenterOffset: 2;
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12

        focus: true

        selectByMouse: true
        passwordCharacter: "●"

        font.pixelSize: 35;
    }
}
