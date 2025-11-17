class Utils {
  static List<String> getCompatibleFuelTypes(String vehicleFuelType) {
    switch (vehicleFuelType) {
      case 'Flex':
        return [
          'Gasolina Comum',
          'Gasolina Aditivada',
          'Gasolina Premium',
          'Gasolina Podium',
          'Etanol Comum',
          'Etanol Aditivado',
        ];
      case 'Gasolina':
        return [
          'Gasolina Comum',
          'Gasolina Aditivada',
          'Gasolina Premium',
          'Gasolina Podium',
        ];
      case 'Etanol':
        return ['Etanol Comum', 'Etanol Aditivado'];
      case 'Diesel':
        return [
          'Diesel Comum',
          'Diesel S10',
          'Diesel Renovável',
          'Diesel Premium',
          'Biodiesel',
        ];
      default:
        return [];
    }
  }
}
