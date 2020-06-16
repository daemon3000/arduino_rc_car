
class Direction {
  const Direction(this.x, this.y);

  Direction.zero():
      this.x = 0,
      this.y = 0;

  final int x;
  final int y;

  Direction withX(int x) => Direction(x, this.y);
  Direction withY(int y) => Direction(this.x, y);

  @override
  String toString() => '($x,$y)';
}