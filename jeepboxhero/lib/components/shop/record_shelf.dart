import 'package:flame/components.dart';
import '../records/vinyl_record.dart';
import '../records/album_data.dart';

class RecordShelf extends PositionComponent {
  final List<VinylRecord> records = [];
  final Function(AlbumData)? onRecordTap;

  RecordShelf({
    required Vector2 position,
    this.onRecordTap,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create record components from database
    double xOffset = 0;
    double yOffset = 0;
    const recordsPerRow = 4;

    for (var i = 0; i < AlbumDatabase.albums.length; i++) {
      final album = AlbumDatabase.albums[i];
      final record = VinylRecord(
        albumData: album,
        position: Vector2(xOffset, yOffset),
        onTap: () {
          onRecordTap?.call(album);
        },
      );

      records.add(record);
      await add(record);

      xOffset += 150;

      if ((i + 1) % recordsPerRow == 0) {
        xOffset = 0;
        yOffset += 220;
      }
    }
  }
}
