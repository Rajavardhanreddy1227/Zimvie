public class XMLParser {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.XML_PARSER);

    public static Map<String, Object> xmlToMap(String xmlString) {
        Map<String, Object> resultMap = new Map<String, Object>();
        try{
            Dom.Document doc = new Dom.Document();
            doc.load(xmlString);
            Dom.XmlNode root = doc.getRootElement();
            parseXmlNode(resultMap, root);
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        return resultMap;
    }

    private static void parseXmlNode(Map<String, Object> resultMap, Dom.XmlNode node) {
        try{
            if (node.getNodeType() == Dom.XmlNodeType.ELEMENT) {
                String nodeName = node.getName();
                if (node.getChildElements().size() > 0) {
                    Map<String, Object> nodeMap = new Map<String, Object>();
                    for (Dom.XmlNode child : node.getChildElements()) {
                        parseXmlNode(nodeMap, child);
                    }
                    resultMap.put(nodeName, nodeMap);
                } else {
                    resultMap.put(nodeName, node.getText());
                }
    
                // Handle attributes
                if (node.getAttributeCount() > 0) {
                    Map<String, String> attributeMap = new Map<String, String>();
                    for(Integer i = 0; i < node.getAttributeCount(); i++){
                        String key = node.getAttributeKeyAt(i);
                        String attr = node.getAttribute(key, Null);
                        attributeMap.put(key, attr);
                    }
                    // for (Dom.XmlNode attribute : node.getAttributes()) {
                    //     attributeMap.put(attribute.getName(), attribute.getValue());
                    // }
                    resultMap.put(nodeName + 'Attributes', attributeMap);
                }
            }
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }
}