import QtQuick 2.0
import Mana 1.0

/**
 * The main viewport, showing the map and entities.
 */
Item {
    id: viewport;

    property real centerX: width / 2;
    property real centerY: height / 2;
    property real playerX: gameClient.player ? gameClient.player.x : gameClient.playerStartX;
    property real playerY: gameClient.player ? gameClient.player.y : gameClient.playerStartY;

    // There seems to be no good way to temporarily disable a Behavior. So in
    // order to avoid the smooth following of the player on warps, this
    // this component is re-created, resetting the animation to start from the
    // new player location.
    Component {
        id: smoothFollowComponent;
        Item {
            id: smoothFollow;
            property real smoothPlayerX: viewport.playerX;
            property real smoothPlayerY: viewport.playerY;
            property real mapX: viewport.centerX - smoothPlayerX;
            property real mapY: viewport.centerY - smoothPlayerY;

            Behavior on smoothPlayerX { SpringAnimation { spring: 3; damping: 1 } }
            Behavior on smoothPlayerY { SpringAnimation { spring: 3; damping: 1 } }

            // Math.floor is used to avoid tile drawing glitches
            Binding {
                target: map; property: "x";
                value: {
                    var scale = viewport.scale;
                    Math.floor(smoothFollow.mapX * scale) / scale;
                }
            }
            Binding {
                target: map; property: "y";
                value: {
                    var scale = viewport.scale;
                    Math.floor(smoothFollow.mapY * scale) / scale;
                }
            }
        }
    }

    function toMapPos(viewportX, viewportY) {
        return viewport.mapToItem(map, viewportX, viewportY);
    }

    property var smoothFollowInstance;

    function resetSmoothFollow() {
        if (smoothFollowInstance)
            smoothFollowInstance.destroy();

        smoothFollowInstance = smoothFollowComponent.createObject(viewport);
    }

    Component.onCompleted: resetSmoothFollow();
    Connections {
        target: gameClient;
        onMapChanged: resetSmoothFollow();
    }

    TileMap {
        id: map;
        source: gameClient.currentMap;

        visibleArea: Qt.rect(-map.x,
                             -map.y,
                             viewport.width,
                             viewport.height);

        onStatusChanged: {
            if (status == TileMap.Ready) {
                fadeInMap.start();
            } else {
                fadeInMap.stop();
                blackOverlay.opacity = 1;
            }
        }

        Repeater {
            model: gameClient.beingListModel;
            delegate: Item {
                x: model.being.x;
                y: model.being.y;
                z: y;

                CompoundSprite {
                    id: sprite;
                    sprites: model.being.spriteListModel;
                    action: model.being.action;
                    direction: model.being.spriteDirection;
                }

                MouseArea {
                    width: 64;
                    height: 64;

                    anchors.bottom: parent.bottom;
                    anchors.horizontalCenter: parent.horizontalCenter;

                    onClicked: {
                        if (model.being.type === Being.OBJECT_NPC)
                            gameClient.npcDialogManager.startTalkingTo(model.being);
                    }
                }

                // Player name and chat messages are displayed above the map
                Item {
                    parent: map;
                    x: model.being.x;
                    y: model.being.y;
                    z: 65537; // Layers above the Fringe layer have z 65536

                    OverheadChatMessage {
                        id: chatLabel;
                        anchors.bottom: parent.bottom;
                        anchors.bottomMargin: sprite.maxHeight;
                    }

                    Text {
                        anchors.top: parent.bottom
                        anchors.topMargin: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.being.name;
                        font.pixelSize: 12;
                    }
                }

                Connections {
                    target: model.being;
                    onChatMessage: chatLabel.showText(message);
                }
            }
        }
    }

    Rectangle {
        id: blackOverlay;
        color: "black";
        anchors.fill: parent;

        NumberAnimation on opacity { id: fadeInMap; to: 0; }
    }
}