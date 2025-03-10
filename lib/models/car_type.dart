enum CarType {
  car1,
  car2;

  @override
  String toString() {
    switch (this) {
      case CarType.car1:
        return 'Car 1';
      case CarType.car2:
        return 'Car 2';
    }
  }
}