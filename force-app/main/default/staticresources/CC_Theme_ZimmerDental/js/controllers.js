// Side Navigation Accordian Options

jQuery(document).ready(function($){
    jQuery('#side_nav').dcAccordion({
        eventType: 'hover',
        autoClose: false,
        saveState: false,
        disableLink: false,
        showCount: false,
        speed: 'slow'
    });
});


// Input onFocus and my Blur JS


function myFocus(element) {
    if (element.value === element.defaultValue) {
       element.value = '';
    }
}

function myBlur(element) {
    if (element.value === '') {
       element.value = element.defaultValue;
    }
}