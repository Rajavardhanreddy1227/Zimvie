/*!
 * Flex Microform v0.4.9
 * @copyright CyberSource 2016-2021
 */
!function(e,t){if("object"==typeof exports&&"object"==typeof module)module.exports=t();else if("function"==typeof define&&define.amd)define([],t);else{var n=t();for(var r in n)("object"==typeof exports?exports:e)[r]=n[r]}}("undefined"!=typeof self?self:this,function(){return function(e){function t(r){if(n[r])return n[r].exports;var o=n[r]={i:r,l:!1,exports:{}};return e[r].call(o.exports,o,o.exports,t),o.l=!0,o.exports}var n={};return t.m=e,t.c=n,t.d=function(e,n,r){t.o(e,n)||Object.defineProperty(e,n,{configurable:!1,enumerable:!0,get:r})},t.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(n,"a",n),n},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p="",t(t.s=189)}({0:function(e,t,n){"use strict";function r(e){return null!=e&&"object"===(void 0===e?"undefined":y(e))}function o(e){var t=void 0===e?"undefined":y(e);return null!=e&&("object"===t||"function"===t)}function s(e){var t=o(e)?Object.prototype.toString.call(e):"";return"[object Function]"===t||"[object GeneratorFunction]"===t}function i(e){return"string"==typeof e||!Array.isArray(e)&&r(e)&&"[object String]"===Object.prototype.toString.call(e)}function u(e){return!0===e||!1===e||"[object Boolean]"===Object.prototype.toString.call(e)}function a(e){return"object"===("undefined"==typeof HTMLElement?"undefined":y(HTMLElement))?e instanceof HTMLElement:r(e)&&1===e.nodeType&&"string"==typeof e.nodeName}function c(e){return String.fromCharCode.apply(null,new Uint8Array(e))}function l(e){for(var t=new ArrayBuffer(e.length),n=new Uint8Array(t),r=0,o=e.length;r<o;r+=1)n[r]=e.charCodeAt(r);return t}function f(){window.getSelection&&window.getSelection().empty?window.getSelection().empty():window.getSelection&&window.getSelection().removeAllRanges?window.getSelection().removeAllRanges():document.selection&&document.selection.empty()}function d(){return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(e){var t=16*Math.random()|0;return("x"===e?t:3&t|8).toString(16)})}function p(e){return JSON.parse(JSON.stringify(e))}function b(e){return"string"==typeof e?e.replace(/\D/g,""):""}Object.defineProperty(t,"__esModule",{value:!0});var y="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e};t.isObjectLike=r,t.isObject=o,t.isFunction=s,t.isString=i,t.isBoolean=u,t.isElement=a,t.arrayBufferToString=c,t.stringToArrayBuffer=l,t.clearCurrentSelection=f,t.uuid=d,t.simpleClone=p,t.stripNonDigits=b;t.Base64={encode:function(e){var t=i(e)?l(e):e;if(!(t instanceof ArrayBuffer))throw new TypeError("Input should be of type String or ArrayBuffer");var n=new Uint8Array(t);return window.btoa(String.fromCharCode.apply(null,n))}}},1:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var r=(t.encryptionTypes=["rsaoaep256","rsaoaep","none"],t.cssClasses={FOCUSED:"flex-microform-focused",VALID:"flex-microform-valid",INVALID:"flex-microform-invalid",DISABLED:"flex-microform-disabled",AUTOCOMPLETE:"flex-microform-autocomplete"},t.jsEvents={ENABLE:"enabled",DISABLE:"disabled",FOCUS:"focus",BLUR:"blur",EMPTY:"empty",NOT_EMPTY:"notEmpty",CARD_TYPE_CHANGE:"cardTypeChange",VALIDATION_CHANGE:"validationChange",INPUT_SUBMIT_REQUEST:"inputSubmitRequest",TOKENIZE_LOAD_START:"tokenizeLoadStart",AUTOCOMPLETE:"autocomplete",AUTOCOMPLETE_CHANGE:"autocompleteChange"});t.jsEventsList=Object.keys(r).map(function(e){return r[e]}),t.postMessagesFromParent={FOCUS:"focus",TOKENIZE:"tokenize",CLEAR:"clear",ENABLE:"enable",DISABLE:"disable",SET_PLACEHOLDER:"setPlaceholder"},t.postMessagesFromChild={FOCUS:"focus",BLUR:"blur",EMPTY:"empty",NOT_EMPTY:"notEmpty",CARD_CHANGE_TYPE:"cardTypeChange",VALIDATION_CHANGE:"cardValidationChange",ENABLE:"enable",DISABLE:"disable",INPUT_SUBMIT_REQUEST:"inputSubmitRequest",TOKENIZE_LOAD_START:"tokenizeLoadStart",HANDSHAKE_INIT:"handshakeInit",HANDSHAKE_COMPLETE:"handshakeComplete",AUTOCOMPLETE:"autocomplete",AUTOCOMPLETE_CHANGE:"autocompleteChange"}},189:function(e,t,n){"use strict";var r=n(3).default,o=n(190).default;e.exports={FLEX:{microform:o,version:r}}},190:function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t,n){var r=document.createElement("iframe");return r.setAttribute("hspace","0"),r.setAttribute("vspace","0"),r.setAttribute("frameborder","0"),r.setAttribute("scrolling","no"),r.setAttribute("allowtransparency","true"),r.setAttribute("marginwidth","0"),r.setAttribute("marginheight","0"),r.style.overflow="hidden",r.style.position="relative",r.style.border="none",r.style.width="100%",r.style.height="100%",r.id="flex-microform-"+t,r.setAttribute("src",e+"?keyId="+t+"#"+n),r.innerHTML="<p>Your browser does not support frames.</p>",r}function s(e,t,n,r){e.innerHTML="",t.teardown(),t=null,n&&clearTimeout(n),r(new h.default({message:"Timeout has occurred"}))}function i(e){return new Error('Required parameter "'+e+'" was not supplied')}function u(e,t,n){var r='Invalid value of "'+t+'" for "'+e+'" parameter.',o=" Supported values are ["+n.join(", ")+"]";return new Error(r+o)}function a(e,t,n){return new Error('Invalid value typeof "'+t+'" supplied for parameter "'+e+'". Expected typeof "'+n+'"')}function c(e){var t=(0,p.default)({},w,e);if(Object.keys(j).forEach(function(e){var n=j[e],r=t[e];if(n.required||void 0!==r){if(n.required&&void 0===r)throw i(e);if((void 0===r?"undefined":f(r))!==n.type)throw a(e,void 0===r?"undefined":f(r),n.type);if(n.supportedValues&&n.supportedValues.indexOf(r)<0)throw u(e,r,n.supportedValues)}}),"none"!==t.encryptionType){if(!t.keystore)throw i("keystore");t.keystore=(0,A.default)(t.keystore)}return t}function l(e,t){if(!(0,m.isObject)(e))throw new Error("An options object was not supplied");if(!(0,m.isFunction)(t))throw new Error("A setup callback was not supplied");var n=c(e),r=document.querySelector(n.container);if(!r)throw new Error("Container cannot be located.");r.style.overflow="hidden";var i=(0,m.uuid)(),u=(0,T.default)(n.keyId),a=o(u.iframe,n.keyId,i);r.appendChild(a);var l=new y.default(a.contentWindow,i,u.origin),f=n.timeout>0?setTimeout(function(){s(r,l,f,t)},n.timeout):null,d=function(e,o){l.unsubscribeAll(),l.subscribe(v.postMessagesFromChild.HANDSHAKE_COMPLETE,function(){f&&clearTimeout(f),l.unsubscribeAll(),t(null,new S.default(r,a,n.label,l))}),o(n)};l.subscribe(v.postMessagesFromChild.HANDSHAKE_INIT,d)}Object.defineProperty(t,"__esModule",{value:!0});var f="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e};t.default=l;var d=n(2),p=r(d),b=n(6),y=r(b),E=n(4),h=r(E),m=n(0),v=n(1),g=n(191),A=r(g),O=n(192),T=r(O),C=n(193),S=r(C),w={encryptionType:"rsaoaep256",autocomplete:!0,autoformat:!0,cardDetection:!0,timeout:12e4},L={string:"string",object:"object",boolean:"boolean",number:"number"},j={container:{type:L.string,required:!0},keyId:{type:L.string,required:!0},keystore:{type:L.object,required:!1},label:{type:L.string,required:!1},placeholder:{type:L.string,required:!1},title:{type:L.string,required:!1},description:{type:L.string,required:!1},"aria-label":{type:L.string,required:!1},"aria-required":{type:L.boolean,required:!1},styles:{type:L.object,required:!1},cardDetection:{type:L.boolean,required:!1},autocomplete:{type:L.boolean,required:!1},autoformat:{type:L.boolean,required:!1},timeout:{type:L.number,required:!1},encryptionType:{type:L.string,required:!1,supportedValues:v.encryptionTypes}}},191:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var r=n(0);t.default=function(e){var t=void 0;if((0,r.isString)(e))try{t=JSON.parse(e)}catch(e){throw new Error("Could not parse supplied keystore string")}else{if(!(0,r.isObject)(e))throw new Error('Invalid "keystore" supplied');t=e}if(null==t.kid)throw new Error("No kid supplied");return t}},192:function(e,t,n){"use strict";function r(e){var t=(0,u.isString)(e)?e.trim():"";return/^(01|02|03|04)/.test(t)?c:/^(09|10)/.test(t)?l:a}function o(e){var t=r(e);return{origin:t,iframe:t+f}}Object.defineProperty(t,"__esModule",{value:!0}),t.default=o;var s=n(3),i=function(e){return e&&e.__esModule?e:{default:e}}(s),u=n(0),a="https://testflex.cybersource.com",c="https://flex.cybersource.com",l="https://flex.in.cybersource.com",f="/cybersource/assets/microform/"+i.default+"/iframe.html"},193:function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function s(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function i(e,t,n){e.subscribe(b.jsEvents.FOCUS,function(){(0,p.clearCurrentSelection)(),t.classList.add(b.cssClasses.FOCUSED)}),e.subscribe(b.jsEvents.BLUR,function(e){t.classList.remove(b.cssClasses.FOCUSED),(0,m.default)(n,e)}),e.subscribe(b.jsEvents.ENABLE,function(){t.classList.remove(b.cssClasses.DISABLED)}),e.subscribe(b.jsEvents.DISABLE,function(){t.classList.add(b.cssClasses.DISABLED)}),e.subscribe(b.jsEvents.VALIDATION_CHANGE,function(e){e.valid?(t.classList.remove(b.cssClasses.INVALID),t.classList.add(b.cssClasses.VALID)):e.couldBeValid?(t.classList.remove(b.cssClasses.INVALID),t.classList.remove(b.cssClasses.VALID)):(t.classList.remove(b.cssClasses.VALID),t.classList.add(b.cssClasses.INVALID))}),e.subscribe(b.jsEvents.AUTOCOMPLETE,function(){t.classList.add(b.cssClasses.AUTOCOMPLETE)}),e.subscribe(b.jsEvents.AUTOCOMPLETE_CHANGE,function(){t.classList.remove(b.cssClasses.AUTOCOMPLETE)})}function u(e,t){e.subscribe(b.postMessagesFromChild.FOCUS,function(){t.publish(b.jsEvents.FOCUS)}),e.subscribe(b.postMessagesFromChild.BLUR,function(e){t.publish(b.jsEvents.BLUR,e)}),e.subscribe(b.postMessagesFromChild.ENABLE,function(){t.publish(b.jsEvents.ENABLE)}),e.subscribe(b.postMessagesFromChild.DISABLE,function(){t.publish(b.jsEvents.DISABLE)}),e.subscribe(b.postMessagesFromChild.EMPTY,function(){t.publish(b.jsEvents.EMPTY)}),e.subscribe(b.postMessagesFromChild.NOT_EMPTY,function(){t.publish(b.jsEvents.NOT_EMPTY)}),e.subscribe(b.postMessagesFromChild.CARD_CHANGE_TYPE,function(e){t.publish(b.jsEvents.CARD_TYPE_CHANGE,e)}),e.subscribe(b.postMessagesFromChild.VALIDATION_CHANGE,function(e){t.publish(b.jsEvents.VALIDATION_CHANGE,e)}),e.subscribe(b.postMessagesFromChild.INPUT_SUBMIT_REQUEST,function(){t.publish(b.jsEvents.INPUT_SUBMIT_REQUEST)}),e.subscribe(b.postMessagesFromChild.TOKENIZE_LOAD_START,function(){t.publish(b.jsEvents.TOKENIZE_LOAD_START)}),e.subscribe(b.postMessagesFromChild.AUTOCOMPLETE,function(e){t.publish(b.jsEvents.AUTOCOMPLETE,e)}),e.subscribe(b.postMessagesFromChild.AUTOCOMPLETE_CHANGE,function(){t.publish(b.jsEvents.AUTOCOMPLETE_CHANGE)})}Object.defineProperty(t,"__esModule",{value:!0}),t.default=void 0;var a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),c=n(2),l=r(c),f=n(4),d=r(f),p=n(0),b=n(1),y=n(194),E=r(y),h=n(195),m=r(h),v=function(e){return document.querySelectorAll(e)},g=function(e,t){for(var n=v(e),r=0;r<n.length;r+=1)n[r].addEventListener("click",t)},A=function(e,t){for(var n=v(e),r=0;r<n.length;r+=1)n[r].removeEventListener("click",t)},O=function(){function e(t,n,r,o){var a=this;s(this,e),this.container=t,this.iframe=n,this.telegram=o,this.pubSub=new E.default,i(this.pubSub,this.container,this.iframe),u(this.telegram,this.pubSub),r&&(this.labelSelector=r,this.labelClickHandler=function(e){e.preventDefault(),a.focus()},g(this.labelSelector,this.labelClickHandler))}return a(e,[{key:"focus",value:function(){this.telegram.publish(b.postMessagesFromParent.FOCUS)}},{key:"clear",value:function(){this.telegram.publish(b.postMessagesFromParent.CLEAR)}},{key:"enable",value:function(){var e=this;this.telegram.publish(b.postMessagesFromParent.ENABLE,null,function(){e.iframe.removeAttribute("tabindex")})}},{key:"disable",value:function(){this.iframe.tabIndex=-1,this.telegram.publish(b.postMessagesFromParent.DISABLE)}},{key:"setPlaceholder",value:function(e){this.telegram.publish(b.postMessagesFromParent.SET_PLACEHOLDER,{text:e||""})}},{key:"on",value:function(e,t){if(!(b.jsEventsList.indexOf(e)>=0))throw new d.default({message:"Unsupported event type",details:{event:e}});this.pubSub.subscribe(e,t)}},{key:"off",value:function(e,t){this.pubSub.unsubscribe(e,t)}},{key:"createToken",value:function(e,t){if(!(0,p.isFunction)(t))throw new d.default({message:"A response handler has not been supplied"});var n=["cardType","cardExpirationMonth","cardExpirationYear"],r=Object.keys(e).reduce(function(t,r){return n.indexOf(r)>-1&&(0,l.default)(t,o({},r,e[r])),t},{}),s=function(e){e.error?t(new d.default({message:"Tokens response error",details:e.error})):t(null,e)};this.telegram.publish(b.postMessagesFromParent.TOKENIZE,r,s)}},{key:"teardown",value:function(e){this.container.innerHTML="",this.telegram.teardown(),this.pubSub.unsubscribeAll(),this.labelSelector&&A(this.labelSelector,this.labelClickHandler),this.telegram=null,this.pubSub=null,e&&e()}}]),e}();t.default=O},194:function(e,t,n){"use strict";function r(){var e={};return s.jsEventsList.forEach(function(t){e[t]=[]}),{subscribe:function(t,n){if(!(0,o.isFunction)(n))throw new Error("handler not a function.");return s.jsEventsList.indexOf(t)<0?(console.warn("Unsupported event < "+t+" >"),this):(e[t].push(n),this)},unsubscribe:function(t,n){if(!(0,o.isFunction)(n))throw new Error("handler not a function.");var r=e[t]?e[t].indexOf(n):-1;return~r&&e[t].splice(r,1),this},unsubscribeAll:function(){return e={},this},publish:function(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};return s.jsEventsList.indexOf(t)<0?(console.warn("Unsupported event < "+t+" >"),this):(e.hasOwnProperty.call(e,t)&&e[t].forEach(function(e){e(n)}),this)}}}Object.defineProperty(t,"__esModule",{value:!0}),t.default=r;var o=n(0),s=n(1)},195:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.default=function(e,t){if(t.focusShift&&("next"===t.focusShift||"previous"===t.focusShift)){var n=Array.prototype.slice.call(document.querySelectorAll(o)).filter(function(e){var t=e.getAttribute("tabindex"),n=e.getBoundingClientRect();return(!t||parseInt(t,10)>=0)&&(n.width>0&&n.height>0||"AREA"===e.tagName)}),r=n.indexOf(e)+("previous"===t.focusShift?-1:1);r>=0&&n[r].focus()}};var r=["a[href]","area[href]","input:not([disabled])","select:not([disabled])","textarea:not([disabled])","button:not([disabled])","object","embed","iframe","*[tabindex]","*[contenteditable]"],o=r.join(", ")},2:function(e,t,n){"use strict";function r(e){if(null===e||void 0===e)throw new TypeError("Object.assign cannot be called with null or undefined");return Object(e)}/*
object-assign
(c) Sindre Sorhus
@license MIT
*/
var o=Object.getOwnPropertySymbols,s=Object.prototype.hasOwnProperty,i=Object.prototype.propertyIsEnumerable;e.exports=function(){try{if(!Object.assign)return!1;var e=new String("abc");if(e[5]="de","5"===Object.getOwnPropertyNames(e)[0])return!1;for(var t={},n=0;n<10;n++)t["_"+String.fromCharCode(n)]=n;if("0123456789"!==Object.getOwnPropertyNames(t).map(function(e){return t[e]}).join(""))return!1;var r={};return"abcdefghijklmnopqrst".split("").forEach(function(e){r[e]=e}),"abcdefghijklmnopqrst"===Object.keys(Object.assign({},r)).join("")}catch(e){return!1}}()?Object.assign:function(e,t){for(var n,u,a=r(e),c=1;c<arguments.length;c++){n=Object(arguments[c]);for(var l in n)s.call(n,l)&&(a[l]=n[l]);if(o){u=o(n);for(var f=0;f<u.length;f++)i.call(n,u[f])&&(a[u[f]]=n[u[f]])}}return a}},3:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.default="0.4.9"},4:function(e,t,n){"use strict";function r(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};if(!e.message)throw new Error("Error message required");this.name="MicroformError",this.message=e.message,this.details=e.details}Object.defineProperty(t,"__esModule",{value:!0}),r.prototype=Object.create(Error.prototype),r.prototype.constructor=r,t.default=r},6:function(e,t,n){"use strict";function r(e,t){function n(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:v;return!(!(0,o.isString)(e)||!(0,o.isFunction)(t))&&(E[n]||(E[n]={}),E[n][e]||(E[n][e]=[]),E[n][e].push(t),!0)}function r(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:v;if(!(0,o.isString)(e)||!(0,o.isFunction)(t))return!1;if(!E[n]||!E[n][e])return!1;for(var r=E[n][e],s=0;s<r.length;s+=1)if(r[s]===t)return r.splice(s,1),!0;return!1}function i(e){var t=(0,o.uuid)();return n(t,function n(o){r(t,n),e(o)}),t}function u(e,t,n){var r={event:e,channel:m,contentType:s,data:t||{}};return"function"==typeof n&&(r.reply=i(n)),r}function a(e){return function(t,n){var r=u(e.data.reply,t,n);e.source.postMessage(r,e.origin)}}function c(e,t,n,r){if(E[e]&&E[e][t])for(var o=E[e][t].length,s=0;s<o;s+=1)E[e][t][s].apply(r,n)}function l(e){var t=e.origin||e.originalEvent.origin;if((0,o.isObject)(e.data)&&e.data.contentType===s&&"event"in e.data&&!(!s.indexOf(e.data.event)<0||void 0!==e.data.channel&&e.data.channel!==m&&"*"!==e.data.channel)){var n=[e.data.data||{}];e.data.reply&&n.push(a(e)),c("*",e.data.event,n,e),c(t,e.data.event,n,e)}}function f(){window.removeEventListener("message",l,!1)}function d(e,t,n){var r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:v,o=u(e,t,n);try{h.postMessage(o,r)}catch(e){console.warn("Could not post payload\n\n"+o+"\n\nto origin: "+r),console.warn(e)}}function p(){return E={},!0}function b(){f(),p()}var y=arguments.length>2&&void 0!==arguments[2]?arguments[2]:"*",E={},h=e,m=t,v=y;return window.addEventListener("message",l,!1),{publish:d,subscribe:n,unsubscribe:r,unsubscribeAll:p,teardown:b}}Object.defineProperty(t,"__esModule",{value:!0}),t.default=r;var o=n(0),s="application/x-telegram+json"}})});