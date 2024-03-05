trigger validateCountry on User (before insert, before update) {

    RegionAdder.regionUpdate(trigger.new);

}