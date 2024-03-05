/**
 * @description       : 
 * @author            : hhernandez@pkglobal.com
 * @group             : 
 * @last modified on  : 12-07-2021
 * @last modified by  : hugodhm@icloud.com
**/
global class SearchResult {

	public class Items_Z {
			public List<String> certifications;
			public String distance;
			public String fullName;
			public String id;
			public Double latitude;
			public List<Locations> locations;
			public Double longitude;
			public String photo;
	}

	public class Filters {
		public String displayName;
		public List<Items> items;
		public String name;
	}


		public class Locations {
			public String city;
			public Double latitude;
			public Double longitude;
			public String name;
			public String phone;
			public String postalCode;
			public String state;
			public String street;
			public String website;
		}

	public class Items {
		public Integer count;
		public String text;
		public String value;
	}

	public Integer currentPage;
	public List<Filters> filters;
		public List<Items_Z> items;
	public Integer pageCount;
		public Integer pageSize;
		public String resultCountText;
		public Integer totalItemCount;

	public class Locations_Z {
		public String city;
		public Double latitude;
		public Double longitude;
		public String name;
		public String phone;
		public String postalCode;
		public String state;
		public String street;
		public String website;
	}

	
	public static SearchResult parse(String json) {
		return (SearchResult) System.JSON.deserialize(json, SearchResult.class);
	}
}