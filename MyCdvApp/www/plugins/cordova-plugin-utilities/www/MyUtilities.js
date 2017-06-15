/*
 *   这个文件是在webviwe里面调用的所有js函数的接口，对应的函数在Plugins／cordova-plugin-utilities／MyCdvUtlities.swift里面
 */


cordova.define("cordova-plugin-utilities.MyUtilities", function(require, exports, module) {
var exec = require("cordova/exec");

var MyUtilities = {
    mRegisterLogListener: function () {
        exec(function (pLogs) {
            for (var i = 0; i < pLogs.length; i += 1) {
                myLog(pLogs[i][0], pLogs[i][1]);
            }
        }, null, "Utilities", "mRegisterLogListener", []);
    },
    mRegisterAppStateListener: function () {
        exec(function (pStat) {
            onAppStateChanged(pStat);
        }, null, "Utilities", "mRegisterAppStateListener", []);
    },
    mRegisterModelStateListener: function () {
        exec(function (pStat) {
            onModelStateChanged(pStat);
        }, null, "Utilities", "mRegisterModelStateListener", []);
    },
    mStart: function () {
        exec(null, null, "Utilities", "mStart", []);
    },
    mRegisterAlertMessageListener: function () {
        exec(function () {
            onAlertMessage();
        }, null, "Utilities", "mRegisterAlertMessageListener", []);
    },
    mSetDataSource: function (pSrc) {
        exec(null, null, "Utilities", "mSetDataSource", [pSrc]);
    },
    mSetDetectMode: function (pMod) {
        exec(null, null, "Utilities", "mSetDetectMode", [pMod]);
    },
    mManualFixUserIdentity: function (pSig) {
        exec(null, null, "Utilities", "mManualFixUserIdentity", [pSig]);
    },
    mReset: function () {
        exec(null, null, "Utilities", "mReset", []);
    },
    mIsUserExist: function () {
        exec(function (pExist) {
            onUserExist(pExist);
        }, null, "Utilities", "mIsUserExist", []);
    },
    mGetUserInfo: function () {
        exec(function (pInfo) {
            onUserInfoChanged(pInfo);
        }, null, "Utilities", "mGetUserInfo", []);
    },
    mSetUserInfo: function (pInfo) {
        exec(null, null, "Utilities", "mSetUserInfo", pInfo);
    },
    mGetMonitorList: function () {
        exec(function (pList) {
            onMonitorListChanged(pList);
        }, null, "Utilities", "mGetMonitorList", []);
    }
};

module.exports = MyUtilities;

});
