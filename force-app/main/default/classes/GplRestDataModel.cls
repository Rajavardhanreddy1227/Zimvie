global class GplRestDataModel {
	
    global class Coordinate{
    	WebService Double latitude {get; set;}
    	WebService Double longitude {get; set;}
    }
    
    global class Profile{
    	WebService String id {get; set;}
        WebService String masterId {get; set;}
    	WebService String salutation {get; set;}
    	WebService String name {get; set;}
    	WebService String firstName {get; set;}
    	WebService String lastName {get; set;}
    	Webservice String preferredName {get; set;}
    	Webservice String medicalSchool {get; set;}
    	WebService String residency {get; set;}
    	WebService String fellowship {get; set;}
    	WebService String procedures {get; set;}
    	WebService String specialties {get; set;}
    	WebService String devices {get; set;}
    	WebService String honors {get; set;}
    	WebService String groups {get; set;}
    	WebService String publications {get; set;}
    	WebService String languages {get; set;}
    	WebService String pictureId {get; set;}
    	WebService String facebook {get; set;}
    	WebService String twitter {get; set;}
    	WebService String linkedIn {get; set;}
    	WebService String youtube {get; set;}
    	WebService String jobTitle {get; set;}
    	WebService list<Location> locations {get; set;} 
    }
    
    global class Location{
    	WebService String id {get; set;}
    	WebService String locationType {get; set;}
    	WebService String name {get;set;}
		WebService String street {get;set;}
		WebService String city {get;set;}
		WebService String state {get;set;}
		WebService string country {get;set;}
		WebService String postalCode {get;set;}
		WebService String phone {get;set;}
		WebService String fax {get;set;}
		WebService String website {get;set;}
		WebService String services {get;set;}
		WebService Double latitude {get;set;}
		WebService Double longitude {get; set;}
		
    }
    
    global class Criteria{
    	WebService Coordinate coordinate {get; set;}
    	WebService String postalCode {get; set;}
    	WebService String city {get; set;}
    	WebService String state {get; set;}
    	WebService String country {get; set;}
    	WebService Integer radius {get; set;}
    	WebService String radiusUom {get; set;}
    	WebService String name {get; set;}
    	WebService String firstName {get; set;}
    	WebService String lastName {get; set;} 
    	WebService String specialty {get; set;}
    	WebService String procedure {get; set;}
    	WebService String medicalDevice {get; set;}
    	WebService String id {get; set;}
    }    
    
	global class Photo {
		WebService Blob body {get;set;}
		WebService Integer bodyLength {get;set;}
		WebService String contentType {get;set;}
	}

}