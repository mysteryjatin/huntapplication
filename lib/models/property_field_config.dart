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
  final bool showBuildingName;
  final bool showUnitNumber;
  final bool showBoundaryWallMade;
  final bool showOccupancy;
  final bool showMaintenanceCharges;
  final bool showAttachedBathroom;
  final bool showElectricity;
  final bool showAnyConstructionDone;
  final bool showMonthlyRent;
  final bool showSharedOfficeSpace;
  final bool showPersonalWashroom;
  final bool showPantry;
  final bool showHowOldIsPG;
  final bool showAttachedBalcony;
  final bool showSecurityAmount;
  final bool showCommonArea;

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
    this.showBuildingName = false,
    this.showUnitNumber = false,
    this.showBoundaryWallMade = false,
    this.showOccupancy = false,
    this.showMaintenanceCharges = true,
    this.showAttachedBathroom = false,
    this.showElectricity = false,
    this.showAnyConstructionDone = false,
    this.showMonthlyRent = false,
    this.showSharedOfficeSpace = false,
    this.showPersonalWashroom = false,
    this.showPantry = false,
    this.showHowOldIsPG = false,
    this.showAttachedBalcony = false,
    this.showSecurityAmount = false,
    this.showCommonArea = false,
  });

  static PropertyFieldConfig getConfigForSubtype(String? propertySubtype) {
    if (propertySubtype == null || propertySubtype.isEmpty) {
      // Default config - show all fields
      return const PropertyFieldConfig();
    }

    // Normalize the property subtype (trim and handle variations)
    final normalized = propertySubtype.trim();

    switch (normalized) {
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
          showStoreRoom: true, // Updated: Store Room should be shown
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
          showBuildingName: true,
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
          showOpenSides: true, // Updated: Open Sides should be shown
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
          showBuildingName: true,
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
          showOpenSides: true, // Updated: Open Sides should be shown
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
          showBuildingName: true,
        );

      case 'Plot/Land':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: true, // Updated: Floors Allowed should be shown
          showOpenSides: true,
          showFacing: true,
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true,
          showAreaBuiltUp: false,
          showAreaCarpet: false,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true, // Updated: Available From should be shown
          showAgeOfConstruction: false,
          showCarParking: true, // Updated: Car Parking should be shown
          showLift: false,
          showOwnershipType: true,
        );

      // ===================== COMMERCIAL PROPERTY TYPES =====================
      case 'Commercial Land':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: false,
          showOpenSides: true, // Open Sides shown in image
          showFacing: true, // Facing shown in image
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: false, // Not shown in image
          showAreaCarpet: false, // Not shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: false, // Not shown in image
          showCarParking: false, // Not shown in image
          showLift: false, // Not shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: false,
          showUnitNumber: true, // Unit Number shown in Transaction Type section
          showBoundaryWallMade: true, // Boundary Wall Made shown in image
          showOccupancy: true, // Occupancy shown in image
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: true, // Electricity shown in Price Details
          showAnyConstructionDone: true, // Any Construction Done shown in image
          showMonthlyRent: false,
        );

      case 'Office Space':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true, // Bathrooms shown in image
          showBalconies: false,
          showFurnishing: true, // Finishing Status shown in image
          showFloorNumber: true, // Floor Number shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true, // Facing shown in image
          showStoreRoom: true, // Store Room shown in image
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: true, // Building Name shown in image
          showUnitNumber: true, // Unit Number shown in Transaction Type section
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: false,
          showSharedOfficeSpace: true, // Shared Office Space shown in image
          showPersonalWashroom: true, // Personal Washroom shown in image
          showPantry: true, // Pantry shown in image
        );

      case 'Shop':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false, // Not shown in image
          showBalconies: false,
          showFurnishing: true, // Finishing Status shown in image
          showFloorNumber: true, // Floor Number shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true, // Facing shown in image
          showStoreRoom: true, // Store Room shown in image
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: true, // Building Name shown in image
          showUnitNumber: true, // Unit Number shown in Transaction Type section
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: false,
          showSharedOfficeSpace: false,
          showPersonalWashroom: true, // Personal Washroom shown in image
          showPantry: true, // Pantry shown in image
          showHowOldIsPG: false,
          showAttachedBalcony: false,
          showSecurityAmount: false,
          showCommonArea: false,
        );

      case 'Showroom':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true,
          showBalconies: false,
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
          showOwnershipType: true,
        );

      case 'Warehouse / Godown':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: true, // Finishing Status shown in image
          showFloorNumber: true, // Floor Number shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: true, // Floor Allowed shown in image
          showOpenSides: true, // Open Sides shown in image
          showFacing: true, // Facing shown in image
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: false, // Not shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: false, // Not shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: false,
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: false,
          showAnyConstructionDone: false,
          showMonthlyRent: false,
          showSharedOfficeSpace: false,
          showPersonalWashroom: false,
          showPantry: false,
          showHowOldIsPG: false,
          showAttachedBalcony: false,
          showSecurityAmount: false,
          showCommonArea: false,
        );

      case 'Industrial Land':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: false,
          showOpenSides: true, // Open Sides shown in image
          showFacing: true, // Facing shown in image
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: false, // Not shown in image
          showAreaCarpet: false, // Not shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: false, // Not shown in image
          showCarParking: false, // Not shown in image
          showLift: false, // Not shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: false,
          showUnitNumber: true, // Unit Number shown in Transaction Type section
          showBoundaryWallMade: true, // Boundary Wall Made shown in image
          showOccupancy: true, // Occupancy shown in image
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: true, // Electricity shown in Price Details
          showAnyConstructionDone: true, // Any Construction Done shown in image
          showMonthlyRent: false,
        );

      case 'Industrial Building':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: true,
          showFacing: true,
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: false,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: false,
          showOwnershipType: true,
        );

      case 'Industrial Shed':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: true, // Floors Allowed shown in image
          showOpenSides: true, // Open Sides shown in image
          showFacing: true, // Facing shown in image
          showStoreRoom: true, // Store Room shown in image
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: false, // Not shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: false,
          showUnitNumber: true, // Unit Number shown in Transaction Type section
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: false,
        );

      case 'IT Space':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true, // Bathrooms shown in image
          showBalconies: false,
          showFurnishing: true, // Finishing Status shown in image
          showFloorNumber: true, // Floor Number shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true, // Facing shown in image
          showStoreRoom: true, // Store Room shown in image
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: true, // Building Name shown in image
          showUnitNumber: true, // Unit Number shown in Transaction Type section
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: false,
          showSharedOfficeSpace: true, // Shared Office Space shown in image
          showPersonalWashroom: true, // Personal Washroom shown in image
          showPantry: true, // Pantry shown in image
        );

      case 'Hostel / PG':
        return const PropertyFieldConfig(
          showBedrooms: false, // Not shown in image
          showBathrooms: false, // Not shown in image
          showBalconies: false,
          showFurnishing: true, // Furnishing Details shown in image
          showFloorNumber: false, // Not shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: false, // Not shown in image
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: true, // Building Name shown in image
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: true, // Attached Bathroom shown in image
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: true, // Monthly Rent shown in Price Details
          showSharedOfficeSpace: false,
          showPersonalWashroom: false,
          showPantry: false,
          showHowOldIsPG: true, // How Old is PG shown in image
          showAttachedBalcony: true, // Attached Balcony shown in image
          showSecurityAmount: true, // Security Amount shown in Price Details
        );

      case 'Food Court':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true, // Bathrooms shown in image
          showBalconies: true, // Balconies shown in image
          showFurnishing: true, // Furnishing Details shown in image
          showFloorNumber: true, // Floor Number shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: true, // Open Sides shown in image
          showFacing: false, // Not shown in image
          showStoreRoom: true, // Store Room shown in image
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: false, // Not shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: false, // Not shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: true, // Building Name shown in image
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: false,
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: false,
        );

      case 'Restaurants':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true, // Bathrooms shown in image
          showBalconies: false,
          showFurnishing: false, // Not shown in image
          showFloorNumber: true, // Floor Number shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: false, // Not shown in image
          showStoreRoom: true, // Store Room shown in image
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: true, // Built Up Area shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: true, // Transaction Type shown in image
          showPossessionStatus: true, // Possession Status shown in image
          showAvailableFrom: true, // Available From shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: true, // Lift shown in image
          showOwnershipType: true, // Type Of Ownership shown in image
          showBuildingName: true, // Building Name shown in image
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
          showAttachedBathroom: true, // Attached Bathroom shown in image
          showElectricity: false, // Not shown in image
          showAnyConstructionDone: false,
          showMonthlyRent: false,
          showSharedOfficeSpace: false,
          showPersonalWashroom: false,
          showPantry: false,
          showHowOldIsPG: false,
          showAttachedBalcony: true, // Attached Balcony shown in image
          showSecurityAmount: false,
          showCommonArea: true, // Common Area shown in image
        );

      case 'Banquet Hall':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: true,
          showBalconies: false,
          showFurnishing: true, // Finishing Status
          showFloorNumber: true,
          showTotalFloors: true,
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: true,
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true, // Only Super Area shown in image
          showAreaBuiltUp: false, // Not shown in image
          showAreaCarpet: false, // Not shown in image
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: true,
          showCarParking: true,
          showLift: true,
          showOwnershipType: true,
          showBuildingName: false,
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: false, // Not shown in image
          showAttachedBathroom: true, // Attached Bathroom shown in image
          showElectricity: true, // Electricity shown in Price Details
        );

      case 'Cineplex / Cinema Hall':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false, // Not shown in image
          showBalconies: false,
          showFurnishing: false, // Not shown in image
          showFloorNumber: false, // Not shown in image
          showTotalFloors: true, // Total Floors shown in image
          showFloorsAllowed: false,
          showOpenSides: false,
          showFacing: false, // Not shown in image
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true, // Super Area shown in image
          showAreaBuiltUp: false, // Not shown in image
          showAreaCarpet: true, // Carpet Area shown in image
          showTransactionType: false, // Not shown in image
          showPossessionStatus: false, // Not shown in image
          showAvailableFrom: false, // Not shown in image
          showAgeOfConstruction: true, // Age of Construction shown in image
          showCarParking: true, // Car Parking shown in image
          showLift: false, // Not shown in image
          showOwnershipType: false, // Not shown in image
          showBuildingName: false,
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: false, // Not shown in image
          showAttachedBathroom: false,
          showElectricity: true, // Electricity shown in Price Details
          showAnyConstructionDone: true, // Any Construction Done shown in image
          showMonthlyRent: true, // Monthly Rent shown in Price Details
        );

      // ===================== AGRICULTURE PROPERTY TYPES =====================
      case 'Farm House':
        return const PropertyFieldConfig(
          showBedrooms: true,
          showBathrooms: true,
          showBalconies: false, // Not shown in Farm House image
          showFurnishing: true, // Finishing Status
          showFloorNumber: false,
          showTotalFloors: true, // Total Floor shown in image
          showFloorsAllowed: false, // Not shown in image
          showOpenSides: true,
          showFacing: true,
          showStoreRoom: false, // Not shown in image
          showServantRoom: false, // Not shown in image
          showAreaSuper: true,
          showAreaBuiltUp: true,
          showAreaCarpet: true,
          showTransactionType: true,
          showPossessionStatus: true,
          showAvailableFrom: true,
          showAgeOfConstruction: false, // Not shown in image
          showCarParking: false, // Not shown in image
          showLift: false,
          showOwnershipType: true,
          showBuildingName: false,
          showUnitNumber: true, // Unit Number shown in Transaction Type section
        );

      case 'Agriculture Land':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: false,
          showOpenSides: false, // No Property Features shown in image
          showFacing: false, // No Property Features shown in image
          showStoreRoom: false,
          showServantRoom: false,
          showAreaSuper: true,
          showAreaBuiltUp: false,
          showAreaCarpet: false,
          showTransactionType: false, // Not shown in image
          showPossessionStatus: false, // Not shown in image
          showAvailableFrom: true, // Available Form shown in image
          showAgeOfConstruction: false,
          showCarParking: false,
          showLift: false,
          showOwnershipType: true,
          showBuildingName: false,
          showUnitNumber: false,
          showBoundaryWallMade: false,
          showOccupancy: false,
          showMaintenanceCharges: false, // Not shown in image
        );

      case 'Farm Land':
        return const PropertyFieldConfig(
          showBedrooms: false,
          showBathrooms: false,
          showBalconies: false,
          showFurnishing: false,
          showFloorNumber: false,
          showTotalFloors: false,
          showFloorsAllowed: false,
          showOpenSides: false, // Not shown in Farm Land image
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
          showBuildingName: false,
          showUnitNumber: false,
          showBoundaryWallMade: true, // Boundary Wall Made shown in image
          showOccupancy: true, // Occupancy shown in image
        );

      default:
        // Log unmatched property subtype for debugging
        // ignore: avoid_print
        print('⚠️ WARNING: Unmatched property subtype: "$normalized"');
        print('⚠️ This will show all fields. Please check the property subtype name matches exactly.');
        // Default config - show all fields for unknown types
        return const PropertyFieldConfig();
    }
  }
}


