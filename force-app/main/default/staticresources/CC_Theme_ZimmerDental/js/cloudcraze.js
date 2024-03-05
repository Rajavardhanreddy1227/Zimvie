(function($) {
    /**
     * INITIALIZE CloudCraze namespace
     * creat new namespace CloudCraze and set to local variable CC
     */
    if(!$.CloudCraze) {
        $.CloudCraze = {};
    }

    var CC = $.CloudCraze;
    
    /**
     * CloudCraze functions
     */
    CC.version = function() { return "CloudCraze Version 2.1"; };
    
    CC.getQueryParam = function(name) {
        //name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.href);
        if(results !== null) {
            return results[1];
        }
        return "";
    };
    
    /*
    CC.initCategoryTree = function() {
        // third example
        $(document).ready(function(){

            $("#tree").show();
            // Code to enable opening the tree of categories or the category associated with the product being viewed (under the current context.)
            var queryparam = CC.getQueryParam('categoryID');
            var id = null;

            if(queryparam !== null && queryparam !== ''){
                id = document.getElementById(queryparam);
            }

           if(id === null) {
               var queryparamParent = CC.getQueryParam('parentCategory');
               if(queryparamParent !== null && queryparamParent !== '') {
                 id = document.getElementById(queryparamParent);
               }
            }

            if(id === null){
                var category = document.getElementById('hdnCategory');
                if(category !== null && category !== ''){
                    var catValue = category.value;
                    if(catValue !== null && catValue !== ''){
                        id = document.getElementById(catValue);
                    }
                }
            }

            if(id !== null && id.title !== null) {
                var breadCrumbArr = id.title.split(">");

                if(breadCrumbArr.length > 1) {
                    for(var i = 1; i < breadCrumbArr.length; i++) {
                        $(document.getElementById(breadCrumbArr[i])).removeClass('expandable').addClass('open');
                    }
                }
            }

            $('li[title]').each(function() {
                $(this).attr('title','');
            });

            $("#red").treeview({
                animated: "fast",
                collapsed: true,
                unique: true
            });

            // uncomment to have tree expanded
            $("#red > li").removeClass('expandable').addClass('collapsable');
            $("#red > li:last").removeClass('expandable lastExpandable').addClass('collapsable lastCollapsable');
            $("#red > li > div").removeClass('hitarea expandable-hitarea').addClass('hitarea collapsable-hitarea');
            $("#red > li:last > div").removeClass('hitarea expandable-hitarea lastExpandable-hitarea').addClass('hitarea collapsable-hitarea lastCollapsable-hitarea');
            $("#red > li > ul").css('display','block');
        });
    };
    */
    
    CC.setCookie = function(c_name, value, expiredays) {
        //alert('Cookie Name :' + c_name + ' Value :' + value);
        var exdate = new Date();
        exdate.setDate(exdate.getDate() + expiredays);
        document.cookie = c_name + "=" + window.escape(value) + ((expiredays === null) ? "" : ";expires=" + exdate.toGMTString());
    };

    CC.getCookie = function(c_name) {
        if (document.cookie.length > 0) {
            var c_start = document.cookie.indexOf(c_name + "=");
            if (c_start !== -1) {
                c_start = c_start + c_name.length + 1;
                var c_end = document.cookie.indexOf(";", c_start);
                if (c_end === -1) {
                    c_end = document.cookie.length;
                }
                return window.unescape(document.cookie.substring(c_start, c_end));
            }
        }
        return "";
    };

    CC.checkCookie = function() {
        var username = $.CloudCraze.getCookie('username');
        if (username !== null && username !== "") {
            window.alert('Welcome again ' + username + '!');
        } else {
            username = window.prompt('Please enter your name:', "");
            if (username !== null && username !== "") {
                $.CloudCraze.setCookie('username', username, 365);
            }
        }
    };

    CC.numbersonly = function(e) {
        var isValid = true;
        var unicode = e.charCode ? e.charCode : e.keyCode;
        if(unicode !== 8) { // if the key isn't the backspace key (which we should allow)
            if(unicode < 48 || unicode > 57) { // if not a number
                isValid = false; //disable key press
            }
        }
        return isValid;
    };

    CC.setReturnUrlInCookie = function() {
        $(document).ready(function() {
            jQuery.cookie("ccReturnUrl", window.location);
        });
    };
})(jQuery);