global class GplDataModel {
    
    public with sharing class GeoPoint{
        public Double longitude {get;set;}
        public Double latitude {get;set;} 
    }
    global class BoundingBox{
        WebService Double north {get;set;}
        WebService Double south {get;set;}
        WebService Double east {get;set;}
        WebService Double west {get;set;} 
    }
    global class PhysicianProfile {
        WebService String id {get;set;}
        WebService String masterId {get;set;}
        WebService String salutation {get;set;}
        WebService String firstName {get;set;}
        WebService String lastName {get;set;}
        WebService string preferredFirstName {get;set;}
        WebService String medicalSchool {get;set;}
        WebService String residency {get;set;}
        WebService String fellowship {get;set;}  
        WebService String procedures {get;set;} 
        WebService String specialties {get;set;}
        WebService String devices {get;set;} 
        WebService String honors {get;set;}
        WebService String groups {get;set;} 
        WebService String publications {get;set;}
        WebService String languages {get;set;}
        WebService String pictureId {get;set;}        
        WebService String facebook {get;set;}
        WebService String twitter {get;set;}
        WebService String linkedIn {get;set;}
        WebService String youtube {get;set;}
        WebService String jobTitle {get;set;}
        WebService list<ProfileLocation> locations {get;set;}
        WebService list<Hospital> hospitals {get;set;}
    }
    global class ClinicProfile {
        WebService String id {get;set;}
        WebService String name {get;set;} 
        WebService String specialties {get;set;} 
        WebService String procedures {get;set;}
        WebService String devices {get;set;} 
        WebService String pictureId {get;set;}        
        WebService String facebook {get;set;}
        WebService String twitter {get;set;}
        WebService String linkedIn {get;set;}
        WebService String youtube {get;set;}
        WebService String languages {get;set;}
        WebService list<ProfileLocation> locations {get;set;}       
    }
    //Code added by Goldy on 30-May-2013 for Find A Dentist Functionality
    global class DentistProfile {
        WebService String id {get;set;}
        WebService String masterId {get;set;}
        WebService String salutation {get;set;}
        WebService String firstName {get;set;}
        WebService String lastName {get;set;}
        WebService String contactTitle {get;set;}
        WebService string preferredFirstName {get;set;}
        WebService String medicalSchool {get;set;}
        WebService String residency {get;set;}
        WebService String fellowship {get;set;}  
        //WebService String procedures {get;set;} 
        //WebService String specialties {get;set;}
        //WebService String devices {get;set;}
        WebService String specialtyType {get;set;} 
        WebService String honors {get;set;}
        WebService String groups {get;set;} 
        WebService String publications {get;set;}
        WebService String languages {get;set;}
        WebService String pictureId {get;set;}        
        WebService String facebook {get;set;}
        WebService String twitter {get;set;}
        WebService String linkedIn {get;set;}
        WebService String youtube {get;set;}
        WebService String jobTitle {get;set;}
        WebService list<ProfileLocation> locations {get;set;}
        WebService list<Hospital> hospitals {get;set;}
    }
    //Code addition ends here for Find A Dentist Functionality
    
    global class SearchCriteria {
        WebService BoundingBox box {get;set;}
        WebService String postalCode {get;set;}
        WebService String city {get;set;}
        WebService String state {get;set;}
        WebService String country {get;set;}
        WebService Integer radius {get;set;}
        WebService String radiusUom {get;set;}
        WebService String firstName {get;set;}
        WebService String lastName {get;set;}
        WebService String specialty {get;set;}
        WebService String procedure {get;set;}
        WebService String medicalDevice {get;set;}
        WebService String clinicName {get;set;}
        WebService String physicianId {get;set;} 
        WebService String clinicId {get;set;}
        WebService String username {get;set;}
    }
    
    global class ProfileLocation {
        WebService String id {get;set;}
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
        WebService Double longitude {get;set;}
    }
    global class Hospital {
        WebService String id {get;set;}
        WebService String name {get;set;}
        WebService String street {get;set;}
        WebService String city {get;set;}
        WebService String state {get;set;}
        WebService string country {get;set;}
        WebService String postalCode {get;set;}
    }
    global class Photo {
        WebService Blob body {get;set;}
        WebService Integer bodyLength {get;set;}
        WebService String contentType {get;set;}
    }
}