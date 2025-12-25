class PropertyFieldConfig {
  final bool showBedrooms;
  final bool showBathrooms;
  final bool showBalconies;
  final bool showFurnishing;
  final bool showFloorNumber;
  final bool showTotalFloors;
  final bool showFloorsAllowed;
  final bool showOpenSides;
  final bool showFacing;
  final bool showStoreRoom;
  final bool showServantRoom;
  final bool showAreaSuper;
  final bool showAreaBuiltUp;
  final bool showAreaCarpet;
  final bool showTransactionType;
  final bool showPossessionStatus;
  final bool showAvailableFrom;
  final bool showAgeOfConstruction;
  final bool showCarParking;
  final bool showLift;
  final bool showOwnershipType;

  const PropertyFieldConfig({
    this.showBedrooms = true,
    this.showBathrooms = true,
    this.showBalconies = true,
    this.showFurnishing = true,
    this.showFloorNumber = true,
    this.showTotalFloors = true,
    this.showFloorsAllowed = false,
    this.showOpenSides = false,
    this.showFacing = true,
    this.showStoreRoom = true,
    this.showServantRoom = true,
    this.showAreaSuper = true,
    this.showAreaBuiltUp = true,
    this.showAreaCarpet = true,
    this.showTransactionType = true,
    this.showPossessionStatus = true,
    this.showAvailableFrom = true,
    this.showAgeOfConstruction = true,
    this.showCarParking = true,
    this.showLift = true,
    this.showOwnershipType = true,
  });

  static PropertyFieldConfig getConfigForSubtype(String? propertySubtype) {
    if (propertySubtype == null || propertySubtype.isEmpty) {
      // Default config - show all fields
      return const PropertyFieldConfig();
    }

    switch (propertySubtype) {
      case 'House or Kothi':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: true,
          showOpenSides: true,
          showFacing: true,
          showStoreRoom: true,
          showServantRoom: true,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: true,
        );

      case 'Builder Floor':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: true,
          showServantRoom: true,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: true,
        );

      case 'Villa':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: true,
          showOpenSides: true,
          showFacing: true,
          showStoreRoom: true,
          showServantRoom: true,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: false,
          showOwnershipType: true,
        );

      case 'Service Apartment':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: false,
        );

      case 'Penthouse':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: true,
          showServantRoom: true,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: true,
        );

      case 'Studio Apartment':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: false,
        );

      case 'Flats':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: true,
          showServantRoom: true,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: true,
        );

      case 'Duplex':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: true,
          showFurnishing: true,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: true,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: true,
          showServantRoom: true,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: true,
        );

      case 'Plot/Land':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: false,
          showOpenSides: true,
          showFacing: true,
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true,
          showAreaBuiltUp: false,
          showAreaCarpet: false,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: false,
          showAgeOfConstruction: false,
          showCarParking: false,
          showLift: false,
          showOwnershipType: true,
        );

      default:
        // Default config - show all fields for unknown types
        return const PropertyFieldConfig();
    }
  }
}

