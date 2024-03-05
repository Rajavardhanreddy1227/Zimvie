@isTest
public class B2B_AddressValidationWrapperTest {

    @isTest
    static void testAddressValidationWrapper() {
        // Create an instance of B2B_AddressValidationWrapper
        B2B_AddressValidationWrapper wrapper = new B2B_AddressValidationWrapper();
        wrapper.enableUspsCass = true;

        Test.startTest();
        B2B_AddressValidationWrapper.RequestAddress address = new B2B_AddressValidationWrapper.RequestAddress();
        address.regionCode = 'CA';
        address.locality = 'San Francisco';
        address.administrativeArea = 'CA';
        address.postalCode = '94105';
        address.addressLines = new List<String>{'123 Main St', 'Apt 4B'};
        wrapper.address = address;
        Test.stopTest();
    }
}