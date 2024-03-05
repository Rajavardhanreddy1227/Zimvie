// Main NEW Slider Control Options - Homepage
var sliderOptions = {
	sliderId: "slider",
	effect: "13",
	effectRandom: false,
	pauseTime: 6400,
	transitionTime: 700,
	slices: 1,
	boxes: 8,
	hoverPause: true,
	autoAdvance: true,
	captionEffect: "none",
	thumbnailsWrapperId: "thumbs",
	license: "free"
};

var imageSlider = new mcImgSlider(sliderOptions);

jQuery(document).ready(function($){

	// Side Navigation Accordian Options
	jQuery('#side_nav').dcAccordion({
		eventType: 'hover',
		autoClose: false,
		saveState: false,
		disableLink: false,
		showCount: false,
		speed: 'slow'
	});					

	// For rotating promos on tablet
	$('.carousel').carousel();
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