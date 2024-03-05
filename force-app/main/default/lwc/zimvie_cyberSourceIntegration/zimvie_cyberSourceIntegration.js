import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import cybersource from '@salesforce/resourceUrl/cybersource';

export default class Zimvie_cyberSourceIntegration extends LightningElement {
    renderedCallback() {
        Promise.all([
            loadScript(this, cybersource)
            //loadStyle(this, cybersourceFlexMicroform + '/flex-microform.min.css')
        ])
            .then(() => {
                console.log('flex is:');
                console.log(FLEX);
                this.initializeFlexMicroform();
            })
            .catch(error => {
                console.error('Error loading Cybersource Flex Microform:', error);
            });
    }

    initializeFlexMicroform() {
      var jwk = { /* jwk fetched on the server side */ };
      var form = this.template.querySelector('#my-sample-form');
      var payButton = this.template.querySelector('#pay-button');
      // SETUP MICROFORM
      FLEX.microform(
        {
          keyId: jwk.kid,
          keystore: jwk,
          container: '#cardNumber-container',
          label: '#cardNumber-label',
          placeholder: 'Your custom placeholder text',
          styles: {
            'input': {
              'font-size': '14px',
              'font-family': 'helvetica, tahoma, calibri, sans-serif',
              'color': '#555',
            },
            ':focus': { 'color': 'blue' },
            ':disabled': { 'cursor': 'not-allowed' },
            'valid': { 'color': '#3c763d' },
            'invalid': { 'color': '#a94442' },
          }
        },
        function (setupError, microformInstance) {
          if (setupError) {
            // handle error
            return;
          }

          // intercept the form submission and make a tokenize request instead
          payButton.addEventListener('click', function () {

            // Send in optional parameters from other parts of your payment form
            var options = {
              // cardExpirationMonth: /* ... */,
              // cardExpirationYear:  /* ... */,
              // cardType: /* ... */
            };

            microformInstance.createToken(options, function (err, response) {
              if (err) {
                // handle error
                return;
              }

              console.log('Token generated: ');
              console.log(JSON.stringify(response));

              // At this point the token may be added to the form
              // as hidden fields and the submission continued
              form.submit();
            });
          });

        }
      );
    }
}