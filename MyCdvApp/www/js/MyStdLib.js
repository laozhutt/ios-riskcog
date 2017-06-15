function myAddEventListener() {
    if (typeof onDeviceReady == "function") { $(document).on("deviceready", onDeviceReady); }
    if (typeof onResume == "function") { $(document).on("resume", onResume); }
    if (typeof onPause == "function") { $(document).on("pause", onPause) }
}

const DEBUG = 1, INFO = 2, ERROR = 3;
function myLog(pLvl, pMsg) {
    var lCls = pLvl == INFO ? "list-group-item-success"
        : pLvl == DEBUG ? "list-group-item-warning"
        : pLvl == ERROR ? "list-group-item-danger"
        : "";
    $("#console").prepend($("<li class='list-group-item'>").addClass(lCls).text(pMsg));
}

const IDLE = 1, COLLECT = 2, SAVE = 3, UPLOAD = 4, ASK = 5, QUERY = 6, FIX = 7;
function onAppStateChanged(pStat) {
    var lTxt = pStat == IDLE ? "Idle"
        : pStat == COLLECT ? "Collect Data"
        : pStat == SAVE ? "Save Data"
        : pStat == UPLOAD ? "Upload Data"
        : pStat == ASK ? "Ask Trained"
        : pStat == QUERY ? "Query Result"
        : pStat == FIX ? "Fix Result"
        : "Unknown State";
    $("#button").text(lTxt);
    $("#button").prop("disabled", pStat != IDLE);
}

const NONE = 1, SIT_MODEL_EXIST = 2, WALK_MODEL_EXIST = 3, MODEL_EXIST = 4, SIT_TRAINED = 5, WALK_TRAINED = 6, TRAINED = 7;
function onModelStateChanged(pStat) {
    var lTxt = pStat == NONE ? "Model Not Exist"
        : pStat == SIT_MODEL_EXIST ? "Sit Model Exist"
        : pStat == WALK_MODEL_EXIST ? "Walk Model Exist"
        : pStat == MODEL_EXIST ? "Sit, Walk Model Exist"
        : pStat == SIT_TRAINED ? "Sit Model Trained"
        : pStat == WALK_TRAINED ? "Walk Model Trained"
        : pStat == TRAINED ? "Sit, Walk Model Trained"
        : "Unknown State";
    $("#text").text(lTxt);
}

function onAlertMessage() {
    navigator.notification.prompt("Please Enter Your Password!", function (pRes) {
        if (pRes.buttonIndex == 1 && pRes.input1 == gPassword) {
            navigator.notification.confirm("You Are Device Owner?", function (pButtonIndex) {
                var lSignal = pButtonIndex == 1 ? "1" : "0";
                MyUtilities.mManualFixUserIdentity(lSignal);
            }, "Select User", ["Yes", "No"])
        } else {
            // onAlertMessage();
            MyUtilities.mReset();
        }
    }, "Check Identity", ["OK", "Cancel"], "")
}

function onUserExist(pExist) {
    if (pExist) {
        location.href = "./debug.html";
    }
}

var gUsername, gPassword;
function onUserInfoChanged(pInfo) {
    gUsername = pInfo[0];
    gPassword = pInfo[1];
}

function onMonitorListChanged(pList) {
    $("#log").empty();
    for (var lIdx in pList) {
        var lItem = pList[lIdx];
        $("#log").append($("<li class=\"list-group-item\">").text("可疑操作")
            .append($("<span class=\"pull-right\">").text(lItem)));
    }
}

$(document).ready(function () {
    myAddEventListener();
});
