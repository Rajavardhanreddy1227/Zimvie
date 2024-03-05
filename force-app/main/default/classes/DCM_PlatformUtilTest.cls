@isTest
public class DCM_PlatformUtilTest {
    @isTest
    static void testGetLimitsString() {
        String result = DCM_PlatformUtil.getLimitsString();
        String expectedOutput = '1. SOQL Queries used / SOQL Queries allowed: 10/100\n' +
            '2. Number of records queried so far /  Number allowed: 200/10000\n' +
            '3. Number of DML statements used so far / Number allowed: 5/150\n' +
            '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: 1000/20000';
        System.assertNotEquals(expectedOutput, result);
    }
}