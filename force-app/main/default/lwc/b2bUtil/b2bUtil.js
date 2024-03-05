/**
 * @description a util class for storing Constants
 import loggingToken from '@salesforce/apex/B2BUtils.handleApplicationLogging';
 import {LightningElement, wire} from "lwc";
 */
 import B2B_logging_identifier from '@salesforce/label/c.B2B_logging_identifier';

const getConstants = () =>{
    return {
        NO_ACCESS_MSG : "You don't have sufficient access to configure Products, Please contact System Admin."
    }
};

const applicationLogging = (loggingList) => {
    if(showLog())
    {
        let logMessages = JSON.parse(loggingList);
        logMessages.forEach(function (item, index)
        {
            if (item.loggingLevel === 'DEBUG')
            {
                console.log(item.entryPoint + item.className + ':' + item.methodName + ': ' + item.message);
            }
            else if (item.loggingLevel === 'ERROR')
            {
                console.error(item.entryPoint + item.className + ':' + item.methodName + ': ' + item.message);
            }
        });
    }
};

const consoleLogging = (message) => {
    if(showLog())
    {
        console.log(message);
    }
};

function showLog()
{
    let showLogs = false;
    let params = getUrlVars(window.location.href);
    if(params.hasOwnProperty('loggingToken') && params['loggingToken'] === B2B_logging_identifier)
    {
        showLogs = true;
    }
    return showLogs;
}

function getUrlVars(urlParams) {
    var vars = [], hash;
    if(urlParams)
    {
        var hashes = urlParams.slice(urlParams.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            vars.push(hash[0]);
            vars[hash[0]] = hash[1];
        }
    }
    return vars;
}

function replaceUrlParam(url, paramName, paramValue)
{
    if (paramValue == null) {
        paramValue = '';
    }
    var pattern = new RegExp('\\b('+paramName+'=).*?(&|#|$)');
    if (url.search(pattern)>=0) {
        return url.replace(pattern,'$1' + paramValue + '$2');
    }
    url = url.replace(/[?#]$/,'');
    return url + (url.indexOf('?')>0 ? '&' : '?') + paramName + '=' + paramValue;
}

function removeURLParameter(url, parameter) {
    //prefer to use l.search if you have a location/link object
    var urlparts = url.split('?');
    if (urlparts.length >= 2) {
        var prefix = encodeURIComponent(parameter) + '=';
        var pars = urlparts[1].split(/[&;]/g);
        //reverse iteration as may be destructive
        for (var i = pars.length; i-- > 0;) {
            //idiom for string.startsWith
            if (pars[i].lastIndexOf(prefix, 0) !== -1) {
                pars.splice(i, 1);
            }
        }
        return urlparts[0] + (pars.length > 0 ? '?' + pars.join('&') : '');
    }
    return url;
}

export { getConstants , applicationLogging , consoleLogging , getUrlVars , replaceUrlParam , removeURLParameter};