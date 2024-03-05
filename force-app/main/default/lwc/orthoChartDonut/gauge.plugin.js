function isFunction(functionToCheck) {
  return functionToCheck && {}.toString.call(functionToCheck) === '[object Function]';
 }
 function isString(stringToCheck){
   return typeof stringToCheck === 'string';
 }
const getText = function(data, options){
  if(isString(options.text)) return options.text;
  if(isFunction(options.text)){
    if(data && data.datasets && data.datasets[0]){
      if(data.datasets[0].pLabel){
        return data.datasets[0].pLabel;
      }
      return options.text(data.datasets[0].data);
    }
  }
  return '';
}
const GaugePlugin = {

	id: 'gaugeplugin',
  beforeDraw: function(chart, frame,  options) {
    if (options.display) {
      //Get ctx from string
      const ctx = chart.chart.ctx;

      //Get options from the center object in options
      const centerConfig = options;
      const fontStyle = centerConfig.fontStyle || "Arial";

      const txt = getText(chart.data, options);
      const color = centerConfig.color || "#000";
      const sidePadding = centerConfig.sidePadding || 20;
      const sidePaddingCalculated =
        (sidePadding / 100) * (chart.innerRadius * 2);
      //Start with a base font of 30px
      ctx.font = "20px " + fontStyle;

      //Get the width of the string and also the width of the element minus 10 to give it 5px side padding
      const stringWidth = ctx.measureText(txt).width;
      const elementWidth = chart.innerRadius * 2 - sidePaddingCalculated;

      // Find out how much the font can grow in width.
      const widthRatio = elementWidth / stringWidth;
      const newFontSize = Math.floor(10 * widthRatio);
      const elementHeight = chart.innerRadius * 2;

      // Pick a new font size so it will not be larger than the height of label.
      const fontSizeToUse = Math.min(newFontSize, elementHeight);

      //Set font settings to draw it correctly.
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      const centerX = (chart.chartArea.left + chart.chartArea.right) / 2;
      const centerY =
        (chart.chartArea.top + chart.chartArea.bottom) / (Math.PI / 2);
      ctx.font = fontSizeToUse + "px " + fontStyle;
      ctx.fillStyle = color;

      //Draw text in center
      ctx.fillText(txt, centerX, centerY);
    }
  },
};

export default GaugePlugin;