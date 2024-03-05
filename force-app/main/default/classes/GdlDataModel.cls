global class GdlDataModel {
    global class DistributorProfile {
        webservice String id {get; set;}
        webservice String name {get;set;}
        webservice String content {get;set;}
        webservice String image {get;set;}
        webservice String mainOfficeId {get;set;} 
        webservice String requestedOfficeId {get;set;}
        webservice String supportQueueId {get;set;}
        webservice list<DistributorLocation> locations{get;set;}
        webservice list<DistributorEvent> events {get;set;}
        webservice list<DistributorLink> links {get;set;}       
    }
    global class DistributorLocation {
        webservice String id {get;set;}
        webservice String name {get;set;}
        webservice String street {get;set;}
        webservice String city {get;set;}
        webservice String state {get;set;}
        webservice String postalCode {get;set;}
        webservice String country {get;set;}
        webservice String phone {get;set;}
        webservice String fax {get;set;}
        webservice String website {get;set;}
        webservice double latitude {get;set;}
        webservice double longitude {get;set;}
        webservice String specialties {get;set;}
        webservice String parentId {get;set;}
        webservice boolean hasProfile {get;set;}
    }
    global class DistributorEvent{
        webservice Date startDate {get;set;}
        webservice Date endDate {get;set;}
        webservice String name {get;set;}
        webservice String description {get;set;}
    }
    global class DistributorLink{
        webservice String name {get;set;}
        webservice String url {get;set;}
    }
    global class SearchCriteria {
        webservice String id {get;set;}
        webservice String name {get;set;}
        webservice String postalCode {get;set;}
        webservice String state {get;set;}
        webservice String country {get;set;}
        webservice String specialty {get;set;}
    }
  //Modified By Rohit Attri : Commented below code because TestMethods should be written in a separate test class 
  /*
    static testmethod void testGdlDataModel(){
        DistributorLocation l = new DistributorLocation();
        l.id = '2';
        l.name = 'Test Location';
        l.street = '123 Main Street';
        l.city = 'Anytown';
        l.state = 'IN';
        l.postalCode = '12345';
        l.country = 'US';
        l.phone = '123-456-7890';
        l.fax = '012-345-6789';
        l.website = 'http://distributor.zimmer.com';
        l.latitude = 100.00;
        l.longitude = 0.000;
        l.hasProfile = true;
        
        DistributorEvent e = new DistributorEvent();
        e.startDate = Date.today();
        e.endDate = Date.today();
        e.name = 'Test Event';
        e.description = 'Test Event Description';
        
        DistributorLink link = new DistributorLink();
        link.name = 'google';
        link.url = 'http://google.com';

        list<DistributorLocation> locations = new list<DistributorLocation>();
        locations.add(l);
        list<DistributorEvent> events = new list<DistributorEvent>();
        events.add(e);
        list<DistributorLink> links = new list<DistributorLink>();
        links.add(link);
        DistributorProfile p = new DistributorProfile();
        p.id = '1';
        p.name = 'Test';
        p.content = 'Hello';
        p.image = 'img1.jpg';
        p.mainOfficeId = '2';
        p.requestedOfficeId = '2';
        p.supportQueueId = '123456789012345678';
        p.locations = locations;
        p.links = links;
        p.events = events;
        
        SearchCriteria crit = new SearchCriteria();
        crit.id = '1';
        crit.name = 'Test';
        crit.postalCode = '12345';
        crit.state = 'IN';
        crit.country = 'US';
    } */
}