var hideShowMailingState = function(sel,sel2) {
	if (sel) {
		jQuery(".mailingState").show();
		jQuery(".mailingStateList").show();
		jQuery(".mailingStateListCA").hide();
		jQuery(".mailingStateText").hide();
		jQuery(".mailingstaterequired").show();
	} else if(sel2) {
		jQuery(".mailingStateStyleClass").show();
		jQuery(".mailingStateList").hide();
		jQuery(".mailingStateListCA").show();
		jQuery(".mailingStateText").hide();
		jQuery(".mailingStateRequired").show();
	} else {
		jQuery(".mailingState").show();
		jQuery(".mailingStateList").hide();
		jQuery(".mailingStateListCA").hide();
		jQuery(".mailingStateText").show();
		jQuery(".mailingStateRequired").hide();
	}
};

var hideShowOtherState = function(sel,sel2) {
	if (sel) {
		jQuery(".otherState").show();
		jQuery(".otherStateList").show();
		jQuery(".otherStateListCA").hide();
		jQuery(".otherStateText").hide();
		jQuery(".otherStateRequired").show();
	} else if(sel2) {
		jQuery(".otherState").show();
		jQuery(".otherStateList").hide();
		jQuery(".otherStateListCA").show();
		jQuery(".otherStateText").hide();
		jQuery(".otherStateRequired").show();
	} else {
		jQuery(".otherState").show();
		jQuery(".otherStateList").hide();
		jQuery(".otherStateListCA").hide();
		jQuery(".otherStateText").show();
		jQuery(".otherStateRequired").hide();
	}
};

var toggleMailingAddress = function() {
	flag = jQuery('.mailingCountry').val() === 'US';
	flag2 = jQuery('.mailingCountry').val() === 'CA';
	hideShowMailingState(flag,flag2);
};

var toggleOtherAddress = function() {
	flag = jQuery('.otherCountry').val() === 'US';
	flag2 = jQuery('.otherCountry').val() === 'CA';
	hideShowOtherState(flag,flag2);
};

var handleProfileEdit = function() {
	toggleMailingAddress();
	toggleOtherAddress();
};

jQuery(function() {
	if(jQuery('.cc_MyAccountProfileEdit').size() > 0) {
		handleProfileEdit();
	}
});
