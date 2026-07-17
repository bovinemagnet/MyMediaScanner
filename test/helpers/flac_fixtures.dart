/// Shared in-memory FLAC fixture builders for tests.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:typed_data';

/// Builds a minimal valid FLAC file as raw bytes.
///
/// Contains the fLaC magic, a STREAMINFO block, optionally a
/// VORBIS_COMMENT block with the supplied [tags], and optionally a
/// PICTURE block with [pictureData].
Uint8List buildFlacFixture({
  Map<String, String>? tags,
  int sampleRate = 44100,
  int totalSamples = 441000, // 10 seconds at 44100
  bool includeVorbisComment = true,
  bool isLastBlockStreamInfo = false,
  Uint8List? pictureData,
  String pictureMimeType = 'image/jpeg',
}) {
  final builder = BytesBuilder();

  // Magic: fLaC
  builder.add([0x66, 0x4C, 0x61, 0x43]);

  final hasVorbis = includeVorbisComment && tags != null;
  final hasPicture = pictureData != null;

  // STREAMINFO block (type 0, 34 bytes)
  final streamInfo = _buildStreamInfoBlock(
    sampleRate: sampleRate,
    totalSamples: totalSamples,
    isLast: (isLastBlockStreamInfo || !hasVorbis) && !hasPicture,
  );
  builder.add(streamInfo);

  // VORBIS_COMMENT block (type 4) if requested
  if (hasVorbis) {
    final vorbisComment =
        _buildVorbisCommentBlock(tags, isLast: !hasPicture);
    builder.add(vorbisComment);
  }

  // PICTURE block (type 6) if requested — always last when present.
  if (hasPicture) {
    builder.add(_buildPictureBlock(pictureData, pictureMimeType));
  }

  return builder.toBytes();
}

Uint8List _buildStreamInfoBlock({
  required int sampleRate,
  required int totalSamples,
  bool isLast = false,
}) {
  final data = Uint8List(34);

  // Min/max block size (16 bits each) — use 4096
  data[0] = 0x10;
  data[1] = 0x00;
  data[2] = 0x10;
  data[3] = 0x00;

  // Min/max frame size (24 bits each) — zeros are fine
  // bytes 4-9 = 0

  // Sample rate (20 bits at bytes 10-12, top 4 bits of byte 12)
  data[10] = (sampleRate >> 12) & 0xFF;
  data[11] = (sampleRate >> 4) & 0xFF;
  data[12] = ((sampleRate & 0x0F) << 4);

  // Channels - 1 (3 bits) = 1 (stereo), bits per sample - 1 (5 bits) = 15 (16-bit)
  // These sit in the lower nibble of byte 12 and upper nibble of byte 13
  data[12] |= 0x01; // channels - 1 = 1 (stereo), top bit into lower nibble
  data[13] = 0xF0; // bps-1 = 15 (lower 4 of bps occupy upper 4 bits here) + top 4 of total samples

  // Total samples (36 bits): top 4 bits in lower nibble of byte 13,
  // lower 32 bits in bytes 14-17
  data[13] = (data[13] & 0xF0) | ((totalSamples >> 32) & 0x0F);
  data[14] = (totalSamples >> 24) & 0xFF;
  data[15] = (totalSamples >> 16) & 0xFF;
  data[16] = (totalSamples >> 8) & 0xFF;
  data[17] = totalSamples & 0xFF;

  // MD5 (bytes 18-33) — zeros

  // Build the block header + data
  final block = BytesBuilder();
  final blockType = isLast ? 0x80 : 0x00; // type 0, with/without last-block flag
  block.addByte(blockType);
  // Length = 34, encoded as 24-bit big-endian
  block.add([0x00, 0x00, 34]);
  block.add(data);
  return block.toBytes();
}

Uint8List _buildVorbisCommentBlock(
  Map<String, String> tags, {
  bool isLast = true,
}) {
  final payload = BytesBuilder();

  // Vendor string
  const vendor = 'test-encoder';
  final vendorBytes = vendor.codeUnits;
  payload.add(_uint32LE(vendorBytes.length));
  payload.add(vendorBytes);

  // Comment count
  payload.add(_uint32LE(tags.length));

  // Comments
  for (final entry in tags.entries) {
    final comment = '${entry.key}=${entry.value}';
    final commentBytes = comment.codeUnits;
    payload.add(_uint32LE(commentBytes.length));
    payload.add(commentBytes);
  }

  final payloadBytes = payload.toBytes();

  // Block header
  final block = BytesBuilder();
  final blockType = isLast ? (0x80 | 4) : 4;
  block.addByte(blockType);
  // Length as 24-bit big-endian
  block.addByte((payloadBytes.length >> 16) & 0xFF);
  block.addByte((payloadBytes.length >> 8) & 0xFF);
  block.addByte(payloadBytes.length & 0xFF);
  block.add(payloadBytes);
  return block.toBytes();
}

/// Builds a PICTURE block (type 6) marked as the last metadata block.
Uint8List _buildPictureBlock(Uint8List data, String mimeType) {
  final payload = BytesBuilder();
  payload.add(_uint32BE(3)); // picture type: front cover
  final mimeBytes = mimeType.codeUnits;
  payload.add(_uint32BE(mimeBytes.length));
  payload.add(mimeBytes);
  payload.add(_uint32BE(0)); // description length (empty)
  payload.add(_uint32BE(1)); // width
  payload.add(_uint32BE(1)); // height
  payload.add(_uint32BE(24)); // colour depth
  payload.add(_uint32BE(0)); // indexed colours
  payload.add(_uint32BE(data.length));
  payload.add(data);

  final payloadBytes = payload.toBytes();
  final block = BytesBuilder();
  block.addByte(0x80 | 6); // type 6, last-block flag set
  block.addByte((payloadBytes.length >> 16) & 0xFF);
  block.addByte((payloadBytes.length >> 8) & 0xFF);
  block.addByte(payloadBytes.length & 0xFF);
  block.add(payloadBytes);
  return block.toBytes();
}

Uint8List _uint32BE(int value) {
  return Uint8List(4)
    ..[0] = (value >> 24) & 0xFF
    ..[1] = (value >> 16) & 0xFF
    ..[2] = (value >> 8) & 0xFF
    ..[3] = value & 0xFF;
}

Uint8List _uint32LE(int value) {
  return Uint8List(4)
    ..[0] = value & 0xFF
    ..[1] = (value >> 8) & 0xFF
    ..[2] = (value >> 16) & 0xFF
    ..[3] = (value >> 24) & 0xFF;
}
