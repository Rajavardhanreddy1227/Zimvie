@isTest
public class XMLParser_Test {
   @IsTest
    public static void testXmlToMap() {
        String xmlString = '<root><person name="Alice" age="30">Hello, World!</person></root>';
        Map<String, Object> resultMap = XMLParser.xmlToMap(xmlString);

        System.assertNotEquals(null, resultMap);

        System.assert(resultMap.containsKey('root'));

       
       
    }
}