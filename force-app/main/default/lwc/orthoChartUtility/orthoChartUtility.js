import Ortho_Chart_Default_Color_Scheme from '@salesforce/label/c.Ortho_Chart_Default_Color_Scheme';

const sfdcColors = [
 '#00A1E0', '#16325C', '#76DED9', '#08A69E', '#E2CE7D', '#E69F00',
 '#C23934', '#FFB75D', '#60B17D', '#00716B', '#94E3B1', '#009E73',
 '#93C9F8', '#3A93BA', '#0070D2', '#ABDCF4', '#8073F7', '#7B399C',
 '#CC79A7', '#E2B1FA', '#AF5CD8', '#C9CED8', '#98A1AE', '#656F7E', 
 '#000000'
]

const chartDefaults =  {
  global: {
    plugins: {
      colorschemes: {
        scheme: Ortho_Chart_Default_Color_Scheme
      },
      datalabels: {

        font: {
          size: 12
        }
      }

    }
  }
}

const inspect = data => console.log(JSON.parse(JSON.stringify(data)));


const addClass = (ctx, selector, className) => {
  const element = ctx.template.querySelector(selector);
  if ( (` ${element.className} `).indexOf(` ${className} `) < 0 ) {
    element.className += ` ${className}`
  }
}

function _get(func, fallbackValue) {
  try {
      var value = func();
      return (value === null || value === undefined) ? fallbackValue : value;
  } catch (e) {
      return fallbackValue;
  }
}
const isNumber = value => {
  // First: Check typeof and make sure it returns number
  // This code coerces neither booleans nor strings to numbers,
  // although it would be possible to do so if desired.
  if (typeof value !== 'number') {
    return false
  }
  // Reference for typeof:
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof
  // Second: Check for NaN, as NaN is a number to typeof.
  // NaN is the only JavaScript value that never equals itself.
  if (value !== Number(value)) {
    return false
  }
  // Reference for NaN: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/isNaN
  // Note isNaN() is a broken function, but checking for self-equality works as NaN !== NaN
  // Alternatively check for NaN using Number.isNaN(), an ES2015 feature that works how one would expect

  // Third: Check for Infinity and -Infinity.
  // Realistically we want finite numbers, or there was probably a division by 0 somewhere.
  if (value === Infinity || value === !Infinity) {
    return false
  }
  return true
}

export { sfdcColors , chartDefaults , isNumber, inspect, addClass, _get};