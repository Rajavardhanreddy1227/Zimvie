var hideShippingAddress3AndShowState = function(sel,sel2) {
    if (sel) {
        jQuery(".shippingAddress3").hide();
        jQuery(".shippingState").show();
        jQuery(".shippingStateList").show();
        jQuery(".shippingStateListCA").hide();
        jQuery(".shippingStateText").hide();
        jQuery(".shippingstaterequired").show();
    } else if(sel2) {
        jQuery(".shippingAddress3StyleClass").show();
        jQuery(".shippingStateStyleClass").show();
        jQuery(".shippingStateList").hide();
        jQuery(".shippingStateListCA").show();
        jQuery(".shippingStateText").hide();
        jQuery(".shippingStateRequired").show();
    } else {
        jQuery(".shippingAddress3").show();
        jQuery(".shippingState").show();
        jQuery(".shippingStateList").hide();
        jQuery(".shippingStateListCA").hide();
        jQuery(".shippingStateText").show();
        jQuery(".shippingStateRequired").hide();
    }
};

var hideBillingAddress3AndShowState = function(sel,sel2) {
    if (sel) {
        jQuery(".billingAddress3").hide();
        jQuery(".billingState").show();
        jQuery(".billingStateList").show();
        jQuery(".billingStateListCA").hide();
        jQuery(".billingStateText").hide();
        jQuery(".billingStateRequired").show();
    } else if(sel2) {
        jQuery(".billingAddress3").show();
        jQuery(".billingState").show();
        jQuery(".billingStateList").hide();
        jQuery(".billingStateListCA").show();
        jQuery(".billingStateText").hide();
        jQuery(".billingStateRequired").show();
    } else {
        jQuery(".billingAddress3").show();
        jQuery(".billingState").show();
        jQuery(".billingStateList").hide();
        jQuery(".billingStateListCA").hide();
        jQuery(".billingStateText").show();
        jQuery(".billingStateRequired").hide();
    }
};

/* shows address line 3 and hides state */
var toggleShippingAddress = function() {
    flag = jQuery('.shippingCountry').val() === 'US';
    flag2 = jQuery('.shippingCountry').val() === 'CA';
    hideShippingAddress3AndShowState(flag,flag2);
};

/* shows address line 3 and hides state */
var toggleBillingAddress = function() {
    flag = jQuery('.billingCountry').val() === 'US';
    flag2 = jQuery('.billingCountry').val() === 'CA';
    hideBillingAddress3AndShowState(flag,flag2);
};

var shipCountry      = "";
var shipAddress1     = "";
var shipAddress2     = "";
var shipAddress3     = "";
var shipCity         = "";
var shipState        = "";
var shipPostalCode   = "";

var saveCurrentShippingAddress = function() {
    shipCountry         = jQuery('.shippingCountry').val();
    shipAddress1        = jQuery('.shippingAddress1').val();
    shipAddress2        = jQuery('.shippingAddress2').val();
    shipAddress3        = jQuery('.shippingAddress3').val();
    shipCity            = jQuery('.shippingCity').val();
    shipState           = jQuery('.shippingState').val();
    shipPostalCode      = jQuery('.shippingPostalCode').val();
};

var useBillingAddress = function(el) {
    if(jQuery(el).is(":checked")) {
        saveCurrentShippingAddress();

        jQuery('.shippingCountry').val(jQuery('.billingCountry').val());

        flag = jQuery('.shippingCountry').val() === 'US';
        hideShippingAddress3AndShowState(flag);

        jQuery('.shippingAddress1').val(jQuery('.billingAddress1').val());
        jQuery('.shippingAddress2').val(jQuery('.billingAddress2').val());
        jQuery('.shippingAddress3').val(jQuery('.billingAddress3').val());
        jQuery('.shippingCity').val(jQuery('.billingCity').val());
        jQuery('.shippingState').val(jQuery('.billingState').val());
        jQuery('.shippingPostalCode').val(jQuery('.billingPostalCode').val());
    } else {
        jQuery('.shippingCountry').val(shipCountry);

        flag = jQuery('.shippingCountry').val() === 'US';
        hideShippingAddress3AndShowState(flag);

        jQuery('.shippingAddress1').val(shipAddress1);
        jQuery('.shippingAddress2').val(shipAddress2);
        jQuery('.shippingAddress3').val(shipAddress3);
        jQuery('.shippingCity').val(shipCity);
        jQuery('.shippingState').val(shipPostalCode);
        jQuery('.shippingPostalCode').val(shipCountry);
    }
};

var closePickers = function() {
    jQuery(".addressPicker").dialog("close");
    toggleShippingAddress();
    toggleBillingAddress();
    preventNewAddrCheckout();
};

var openBillingAddressPickerDialog = function() {
    jQuery("#billingAddressPickerDialog").dialog({title: "Select a Billing address"}).dialog("open");
};

var openShippingAddressPickerDialog = function() {
    jQuery("#shippingAddressPickerDialog").dialog({title: "Select a Billing address"}).dialog("open");
};

var handleUserInfo = function() {
    toggleShippingAddress();
    toggleBillingAddress();

    jQuery(".addressPicker").dialog({
        autoOpen: false,
        height: 500,
        width: 350,
        modal: true,
        buttons: {
            Cancel: function() {
                jQuery(this).dialog("close");
            }
        },
            close: function() {
        }
    });

    preventNewAddrCheckout();
};

var handlePaymentShipping = function() {
    jQuery('.payment_type_select').change(function() {
        jQuery('.payment_form').removeClass("show").addClass("hide");
        var selectedPaymentType = jQuery('.payment_type_select option:selected');
        //console.debug('selectedPaymentType=' + selectedPaymentType);
        var form_section = '.payment_' + selectedPaymentType.val() + '_form';
        //console.debug('form_section=' + form_section);
        jQuery(form_section).removeClass("hide").addClass("show");
    });

    enableTermsAndConditions();
};

var handleOrderReview = function() {
    // insert js for order review here
    enableTermsAndConditions();
};

var enableTermsAndConditions = function() {
    // confirm terms and conditions checkboxes are checked before allowing user to continue
    var tcCheckboxes = jQuery('[type=checkbox].terms');
    console.debug('tcCheckboxes size=' + tcCheckboxes.size());
    if(tcCheckboxes.size() > 0) {
        var proceedButton = jQuery('[type=submit].proceed');
        console.debug('proceedButton size=' + proceedButton.size());
        if(proceedButton.size() > 0) {
            disable(proceedButton);
            tcCheckboxes.change(function() {
                console.debug('checkbox changed');
                if(allTermsAccepted(tcCheckboxes)) {
                    enable(proceedButton);
                } else {
                    disable(proceedButton);
                }
            });
        }
    }
};

var enable = function(el) {
    el.removeAttr('disabled').removeClass('disabled');
};

var disable = function(el) {
    el.attr('disabled','disabled').addClass('disabled');
};

var allTermsAccepted = function(checkboxes) {
    var accepted = true;
    checkboxes.each(function() {
        if(jQuery(this).attr('checked') === undefined) {
            accepted = false;
            return;
        }
    });
    console.debug('allTermsAccepted=' + accepted);
    return accepted;
};

jQuery(function() {
    if(jQuery('.cc_userInfo_new').size() > 0) {
        handleUserInfo();
    } else if(jQuery('.cc_paymentShipping').size() > 0) {
        handlePaymentShipping();
    } else if(jQuery('.cc_OrderReview_new').size() > 0) {
        handleOrderReview();
    }
});