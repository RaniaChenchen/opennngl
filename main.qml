import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import OpenGLRenderer 1.0
import DatabaseHandler 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("OpenGL & MySQL CRUD App")

    // Définition du CustomButton dans un Component
    Component {
        id: customButtonComponent

        Rectangle {
            width: 150
            height: 40
            color: "#0078d4"
            radius: 10
            border.color: "#005a8f"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: parent.text // Affiche le texte passé en paramètre
                color: "white"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.clicked()
                onPressed: parent.color = "#005a8f"
                onReleased: parent.color = "#0078d4"
            }
        }
    }

    // Rectangle pour saisir l'ID et le nom
    Rectangle {
        width: parent.width
        height: 120
        anchors.top: parent.top
        color: "#f0f0f0"

        Column {
            spacing: 10
            anchors.fill: parent

            TextField {
                id: idField
                placeholderText: "Enter User ID"
                width: parent.width - 20
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                id: nameField
                placeholderText: "Enter User Name"
                width: parent.width - 20
            }
        }
    }

    // Rectangle pour les boutons personnalisés
    Rectangle {
        width: parent.width
        height: 100
        anchors.bottom: parent.bottom
        color: "#f0f0f0"
        Row {
            anchors.centerIn: parent
            spacing: 20

            // Bouton personnalisé pour "Read Users"
            Item {
                Component.onCompleted: {
                    var button = customButtonComponent.createObject(parent);
                    button.text = "Read Users";
                    button.clicked = readUsers;
                }
            }

            // Bouton personnalisé pour "Add User"
            Item {
                Component.onCompleted: {
                    var button = customButtonComponent.createObject(parent);
                    button.text = "Add User";
                    button.clicked = function() {
                        var id = parseInt(idField.text);
                        var name = nameField.text;
                        if (id && name) {
                            insertUser(id, name);
                        } else {
                            console.error("ID and Name are required.");
                        }
                    };
                }
            }

            // Bouton personnalisé pour "Update User"
            Item {
                Component.onCompleted: {
                    var button = customButtonComponent.createObject(parent);
                    button.text = "Update User";
                    button.clicked = function() {
                        var id = parseInt(idField.text);
                        var name = nameField.text;
                        if (id && name) {
                            updateUser(id, name);
                        } else {
                            console.error("ID and Name are required to update.");
                        }
                    };
                }
            }

            // Bouton personnalisé pour "Delete User"
            Item {
                Component.onCompleted: {
                    var button = customButtonComponent.createObject(parent);
                    button.text = "Delete User";
                    button.clicked = function() {
                        var id = parseInt(idField.text);
                        if (id) {
                            deleteUser(id);
                        } else {
                            console.error("ID is required to delete.");
                        }
                    };
                }
            }
        }
    }

    // Fonction pour lire les utilisateurs depuis la base de données
    function readUsers() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost/cud/apiget.php?action=read", true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                var jsonResponse = JSON.parse(xhr.responseText);
                var buttonContainer = Qt.createQmlObject('import QtQuick 2.15; Column { width: parent.width; spacing: 10 }', userListView);
                jsonResponse.forEach(function(user) {
                    createUserButtons(user.id, user.name, buttonContainer);
                });
            } else {
                console.error("Error reading users");
            }
        };
        xhr.send();
    }

    // Fonction pour insérer un nouvel utilisateur
    function insertUser(id, name) {
        var xhr = new XMLHttpRequest();
        var url = "http://localhost/crud/apiget.php?action=insert&id=" + encodeURIComponent(id) +
                  "&name=" + encodeURIComponent(name);
        xhr.open("GET", url, true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log("User inserted successfully");
                readUsers();  // Rafraîchir la liste des utilisateurs après l'insertion
            } else {
                console.error("Error inserting user");
            }
        };
        xhr.send();
    }

    // Fonction pour supprimer un utilisateur
    function deleteUser(id) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost/crud/apiget.php?action=delete&id=" + id, true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log("User deleted successfully");
                readUsers();  // Rafraîchir la liste après la suppression
            } else {
                console.error("Error deleting user");
            }
        };
        xhr.send();
    }

    // Fonction pour mettre à jour un utilisateur
    function updateUser(id, name) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost/crud/apiget.php?action=update&id=" + id + "&name=" + encodeURIComponent(name), true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log("User updated successfully");
                readUsers();  // Rafraîchir la liste après la mise à jour
            } else {
                console.error("Error updating user");
            }
        };
        xhr.send();
    }

    // Fonction pour créer les boutons utilisateurs dans la liste
    function createUserButtons(id, name, parent) {
        var userButtons = Qt.createQmlObject('import QtQuick 2.15; Item { width: parent.width; height: 50; Row { spacing: 10; width: parent.width; Text { text: "' + name + '"; width: parent.width * 0.6; anchors.verticalCenter: parent.verticalCenter } Button { text: "Delete"; anchors.verticalCenter: parent.verticalCenter; onClicked: { deleteUser(' + id + ') } } Button { text: "Update"; anchors.verticalCenter: parent.verticalCenter; onClicked: { var newName = prompt("Enter new name", "' + name + '"); if (newName) { updateUser(' + id + ', newName); } } } } }', parent);
    }

    // Charger les utilisateurs au démarrage de l'application
    Component.onCompleted: {
        readUsers();
    }
}
