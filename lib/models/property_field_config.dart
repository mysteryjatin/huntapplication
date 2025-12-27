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
  final bool showTenantsYouPrefer;
  final bool showLaundry;

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
    this.showTenantsYouPrefer = false,
    this.showLaundry = false,
  });

  static PropertyFieldConfig getConfigForSubtype(String? propertySubtype, {String? transactionType}) {
    if (propertySubtype == null || propertySubtype.isEmpty) {
      // Default config - show all fields
      return const PropertyFieldConfig();
    }

    // Normalize the property subtype (trim and handle variations)
    final normalized = propertySubtype.trim();
    final isRent = transactionType?.toLowerCase() == 'rent';

    switch (normalized) {
      case 'House or Kothi':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/2.jpg (Multi-Story Apartments)
          return const PropertyFieldConfig(
            showBedrooms: true, // Bedrooms shown in image
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: true, // Balconies shown in image
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: true, // Facing shown in image
            showStoreRoom: true, // Store Room shown in image
            showServantRoom: true, // Servant Room shown in image
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
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: true, // Tenants You Prefer shown in image (Professional/Student/Both)
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Builder Floor':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/2.jpg
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: true, // Open Sides shown in image
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
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Villa':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/3.jpg
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: true, // Open Sides shown in image
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
            showLift: true, // Lift shown in image
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: true, // Laundry shown in Price Details
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Service Apartment':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/10.jpg
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: true,
            showStoreRoom: true,
            showServantRoom: true, // Servant Room shown in image
            showAreaSuper: true,
            showAreaBuiltUp: true,
            showAreaCarpet: true,
            showTransactionType: true,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: true,
            showCarParking: true,
            showLift: true,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: true,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: true, // Laundry shown in Price Details
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Penthouse':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/4.jpg
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
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
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Studio Apartment':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/5.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: true,
            showStoreRoom: true, // Store Room shown in image
            showServantRoom: true, // Servant Room shown in image
            showAreaSuper: true,
            showAreaBuiltUp: true,
            showAreaCarpet: true,
            showTransactionType: true,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: true,
            showCarParking: true,
            showLift: true,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: true, // Unit Number shown in Transaction Type section
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: true, // Laundry shown in Price Details
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Flats':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/6.jpg (Flats/Multi-Story Apartments)
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
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
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false, // Not shown in image (Expected Price shown instead)
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: false,
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true,
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
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
            showBuildingName: true,
          );
        }

      case 'Duplex':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/9.jpg
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: true, // Open Sides shown in image
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
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: true, // Unit Number shown in Transaction Type section
            showBoundaryWallMade: false,
            showOccupancy: true, // Occupancy shown in image (Single/Sharing/Both)
            showMaintenanceCharges: true,
            showAttachedBathroom: true, // Attached Bathroom shown in image
            showElectricity: true, // Electricity shown in Price Details
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: true, // Laundry shown in Price Details
          );
        } else {
          // Configuration for Sell
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
            showBuildingName: true,
          );
        }

      case 'Plot/Land':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/7.jpg
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
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true, // Super Area shown in image
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: true, // Age of Construction shown in image
            showCarParking: true, // Car Parking shown in image
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: true, // Unit Number shown in Transaction Type section
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: false,
            showTotalFloors: false,
            showFloorsAllowed: true,
            showOpenSides: true,
            showFacing: true,
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: true,
            showLift: false,
            showOwnershipType: true,
          );
        }

      // ===================== COMMERCIAL PROPERTY TYPES =====================
      case 'Commercial Land':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/1.jpg
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
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: false,
            showAgeOfConstruction: false,
            showCarParking: true, // Car Parking shown in image
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: false,
            showMaintenanceCharges: false,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: true,
            showBoundaryWallMade: true,
            showOccupancy: true,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: true,
            showAnyConstructionDone: true,
            showMonthlyRent: false,
          );
        }

      case 'Office Space':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/2.jpg
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
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: true, // Shared Office Space shown in image
            showPersonalWashroom: true, // Personal Washroom shown in image
            showPantry: true, // Pantry shown in image
            showHowOldIsPG: false,
            showAttachedBalcony: true, // Attached Balcony shown in image
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
            showStoreRoom: true,
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
            showBuildingName: true,
            showUnitNumber: true,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false,
            showSharedOfficeSpace: true,
            showPersonalWashroom: true,
            showPantry: true,
          );
        }

      case 'Shop':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/3.jpg
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
            showTransactionType: false, // Not shown in image
            showPossessionStatus: false, // Not shown in image
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
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: true, // Shared Office Space shown in image
            showPersonalWashroom: true, // Personal Washroom shown in image
            showPantry: true, // Pantry shown in image
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: true,
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: true,
            showStoreRoom: true,
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
            showBuildingName: true,
            showUnitNumber: true,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false,
            showSharedOfficeSpace: false,
            showPersonalWashroom: true,
            showPantry: true,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: false,
            showCommonArea: false,
          );
        }

      case 'Showroom':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/4.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
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
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: true, // Shared Office Space shown in image
            showPersonalWashroom: true, // Personal Washroom shown in image
            showPantry: true, // Pantry shown in image
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Warehouse / Godown':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/5.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: false,
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: true, // Open Sides shown in image
            showFacing: true, // Facing shown in image
            showStoreRoom: true, // Store Room shown in image
            showServantRoom: false,
            showAreaSuper: true, // Super Area shown in image
            showAreaBuiltUp: true, // Built Up Area shown in image
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: true, // Age Of Construction shown in image
            showCarParking: true, // Car Parking shown in image
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: false,
            showMaintenanceCharges: false,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: true, // Pantry shown in image
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: true,
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: true,
            showOpenSides: true,
            showFacing: true,
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: true,
            showAreaCarpet: true,
            showTransactionType: true,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: true,
            showLift: false,
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
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
        }

      case 'Industrial Land':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/6.jpg
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
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: true, // Age Of Construction shown in image
            showCarParking: true, // Car Parking shown in image
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: false,
            showMaintenanceCharges: false,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: true, // Any Construction Done shown in image
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: true,
            showBoundaryWallMade: true,
            showOccupancy: true,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: true,
            showAnyConstructionDone: true,
            showMonthlyRent: false,
          );
        }

      case 'Industrial Building':
        if (isRent) {
          // Configuration for Rent - similar to Industrial Shed
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
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: false,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true,
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true,
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
        }

      case 'Industrial Shed':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/8.jpg
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
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: false,
            showCarParking: true, // Car Parking shown in image
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: true, // Occupancy shown in image
            showMaintenanceCharges: false,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: false,
            showTotalFloors: false,
            showFloorsAllowed: true,
            showOpenSides: true,
            showFacing: true,
            showStoreRoom: true,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: true,
            showAreaCarpet: true,
            showTransactionType: true,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: true,
            showLift: true,
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: true,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false,
          );
        }

      case 'IT Space':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/9.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
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
            showAgeOfConstruction: true, // Age of Construction shown in image
            showCarParking: true, // Car Parking shown in image
            showLift: true, // Lift shown in image
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: true, // Unit Number shown in Transaction Type section
            showBoundaryWallMade: false,
            showOccupancy: true, // Occupancy shown in image
            showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
            showAttachedBathroom: true, // Attached Bathroom shown in image
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: true, // Pantry shown in image
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: true, // Common Area shown in image
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
            showStoreRoom: true,
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
            showBuildingName: true,
            showUnitNumber: true,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false,
            showSharedOfficeSpace: true,
            showPersonalWashroom: true,
            showPantry: true,
          );
        }

      case 'Hostel / PG':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/10.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: true, // Furnishing Details shown in image
            showFloorNumber: false,
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
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
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: true, // Pantry shown in image
            showHowOldIsPG: true, // How Old is PG shown in image
            showAttachedBalcony: true, // Attached Balcony shown in image
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: true,
            showFloorNumber: false,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
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
            showBuildingName: true,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: true,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true,
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: true,
            showAttachedBalcony: true,
            showSecurityAmount: true,
          );
        }

      case 'Food Court':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/11.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: true, // Balconies shown in image
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: true, // Open Sides shown in image
            showFacing: false,
            showStoreRoom: true, // Store Room shown in image
            showServantRoom: false,
            showAreaSuper: true, // Super Area shown in image
            showAreaBuiltUp: true, // Built Up Area shown in image
            showAreaCarpet: true, // Carpet Area shown in image
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: true, // Age of Construction shown in image
            showCarParking: false,
            showLift: true, // Lift shown in image
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
            showAttachedBathroom: false,
            showElectricity: true, // Electricity shown in Price Details
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true,
            showBalconies: true,
            showFurnishing: true,
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: true,
            showFacing: false,
            showStoreRoom: true,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: true,
            showAreaCarpet: true,
            showTransactionType: false,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: true,
            showCarParking: false,
            showLift: true,
            showOwnershipType: true,
            showBuildingName: true,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false,
          );
        }

      case 'Restaurants':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/12.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
            showStoreRoom: true, // Store Room shown in image
            showServantRoom: false,
            showAreaSuper: true, // Super Area shown in image
            showAreaBuiltUp: true, // Built Up Area shown in image
            showAreaCarpet: true, // Carpet Area shown in image
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: false,
            showAgeOfConstruction: true, // Age of Construction shown in image
            showCarParking: false,
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: true, // Building Name shown in image
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
            showAttachedBathroom: true, // Attached Bathroom shown in image
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: true, // Attached Balcony shown in image
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: true, // Common Area shown in image
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true,
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: true,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
            showStoreRoom: true,
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
            showBuildingName: true,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: true,
            showAttachedBathroom: true,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: false,
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: true,
            showSecurityAmount: false,
            showCommonArea: true,
          );
        }

      case 'Banquet Hall':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/13.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: true, // Finishing Status shown in image
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: true, // Open Sides shown in image
            showFacing: true, // Facing shown in image
            showStoreRoom: true, // Store Room shown in image
            showServantRoom: false,
            showAreaSuper: true, // Super Area shown in image
            showAreaBuiltUp: false,
            showAreaCarpet: false,
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
            showElectricity: true, // Electricity shown in Price Details
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
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
            showAreaBuiltUp: false,
            showAreaCarpet: false,
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
            showMaintenanceCharges: false,
            showAttachedBathroom: true,
            showElectricity: true,
          );
        }

      case 'Cineplex / Cinema Hall':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/commer/13.jpg (Cineplex description)
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: true, // Floor Number shown in image
            showTotalFloors: true, // Total Floors shown in image
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
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
            showAttachedBathroom: false,
            showElectricity: true, // Electricity shown in Price Details
            showAnyConstructionDone: true, // Any Construction Done shown in image
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: false,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: false,
            showAreaCarpet: true,
            showTransactionType: false,
            showPossessionStatus: false,
            showAvailableFrom: false,
            showAgeOfConstruction: true,
            showCarParking: true,
            showLift: false,
            showOwnershipType: false,
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: false,
            showAttachedBathroom: false,
            showElectricity: true,
            showAnyConstructionDone: true,
            showMonthlyRent: true,
          );
        }

      // ===================== AGRICULTURE PROPERTY TYPES =====================
      case 'Farm House':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/ac/1.jpg
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: true, // Bathrooms shown in image
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: false,
            showTotalFloors: false,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: true, // Facing shown in image
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true, // Super Area shown in image
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: false,
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: false,
            showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: true,
            showBathrooms: true,
            showBalconies: false,
            showFurnishing: true,
            showFloorNumber: false,
            showTotalFloors: true,
            showFloorsAllowed: false,
            showOpenSides: true,
            showFacing: true,
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: true,
            showAreaCarpet: true,
            showTransactionType: true,
            showPossessionStatus: true,
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: true,
          );
        }

      case 'Agriculture Land':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/ac/2.jpg
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
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: true, // Occupancy shown in image
            showMaintenanceCharges: true, // Maintenance Charges shown in Price Details
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: false,
            showTotalFloors: false,
            showFloorsAllowed: false,
            showOpenSides: false,
            showFacing: false,
            showStoreRoom: false,
            showServantRoom: false,
            showAreaSuper: true,
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: false,
            showPossessionStatus: false,
            showAvailableFrom: true,
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true,
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: false,
            showOccupancy: false,
            showMaintenanceCharges: false,
          );
        }

      case 'Farm Land':
        if (isRent) {
          // Configuration for Rent - based on rentpropert/rentpropert/ac/3.jpg
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
            showAreaBuiltUp: false,
            showAreaCarpet: false,
            showTransactionType: true, // Transaction Type shown in image
            showPossessionStatus: true, // Possession Status shown in image
            showAvailableFrom: true, // Available From shown in image
            showAgeOfConstruction: false,
            showCarParking: false,
            showLift: false,
            showOwnershipType: true, // Type Of Ownership shown in image
            showBuildingName: false,
            showUnitNumber: false,
            showBoundaryWallMade: true, // Boundary Wall Made shown in image
            showOccupancy: true, // Occupancy shown in image
            showMaintenanceCharges: false, // Not shown in Price Details
            showAttachedBathroom: false,
            showElectricity: false,
            showAnyConstructionDone: false,
            showMonthlyRent: true, // Monthly Rent shown in Price Details
            showSharedOfficeSpace: false,
            showPersonalWashroom: false,
            showPantry: false,
            showHowOldIsPG: false,
            showAttachedBalcony: false,
            showSecurityAmount: true, // Security Amount shown in Price Details
            showCommonArea: false,
            showTenantsYouPrefer: false,
            showLaundry: false,
          );
        } else {
          // Configuration for Sell
          return const PropertyFieldConfig(
            showBedrooms: false,
            showBathrooms: false,
            showBalconies: false,
            showFurnishing: false,
            showFloorNumber: false,
            showTotalFloors: false,
            showFloorsAllowed: false,
            showOpenSides: false,
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
            showBoundaryWallMade: true,
            showOccupancy: true,
          );
        }

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


