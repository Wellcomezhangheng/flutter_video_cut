import 'dart:typed_data';

class FFVideoCutModel {
  ///视频缩略图图片data
  Uint8List? thumbImageData;

  ///视频缩略图图片路径
  String? thumbImagePath;

  ///视频路径路径
  String? path;

  ///url
  String? videoUrl;

  String? meidaId;

  ///时长：毫秒
  double millSecond;

  int size;

  int width;
  int height;

  FFVideoCutModel({this.thumbImageData, this.path, this.thumbImagePath, this.width = 0, this.height = 0, this.videoUrl, this.meidaId, this.millSecond = 0, this.size = 0});


  fromJson(Map<String, dynamic> json) {
    thumbImageData = json['thumbImageData'] ?? null;
    width = json['width'] ?? 0;
    height = json['height'] ?? 0;
    thumbImagePath = json['thumbImagePath'] ?? '';
    path = json['path'] ?? '';
    millSecond = json['millSecond'] ?? 0;
    size = json['size'] ?? 0;
  }

  Map<String, dynamic> toPickerJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thumbImageData'] = this.thumbImageData;
    data['width'] = this.width;
    data['height'] = this.height;
    data['thumbImagePath'] = this.thumbImagePath;
    data['path'] = this.path;
    data['millSecond'] = this.millSecond;
    data['size'] = this.size;
    return data;
  }
}
