import 'dart:io';

import 'dart:async';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_ffmpeg/stream_information.dart';

import 'video_model.dart';

typedef FFVideoCompressProgressCallback = void Function(String progress); // 压缩进度0.01

enum FFVideoCompressType {
  type_svg, // 压缩分辨率
  type_bit, // 压缩码率
  type_cut, // 剪切
}

class FFVideoUtil {
  // static String svg_cross = 'a';
  // static String svg_vertical = '';
  // static String bit = '';
  // static String cut = '-ss 0 -t 60';

  static FlutterFFmpeg ffmpeg = new FlutterFFmpeg();
  static FlutterFFprobe ffprobe = new FlutterFFprobe();
  static FlutterFFmpegConfig ffconfig = new FlutterFFmpegConfig();

  /*获取视频根目录*/
  static Future<String> getVideoRootDirectory({String foldName = 'video'}) async {
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getLibraryDirectory();
    } else if (Platform.isAndroid) {
      directory = (await getExternalStorageDirectory())!;
    }

    if (directory == null) {
      return '';
    }

    Directory _directoryFolder = Directory('${directory.path}/$foldName/');

    if (await _directoryFolder.exists()) {
      return _directoryFolder.path;
    } else {
      final Directory _directoryNewFolder = await _directoryFolder.create(recursive: true);
      return _directoryNewFolder.path;
    }
  }

  /*获取视频压缩进度*/
  static Future getVideoCompressProgress(FFVideoCompressProgressCallback progressCallback, double durationTime) async {
    /*获得进度*/
    ffconfig.enableStatisticsCallback((statistics) {
      var time = (double.parse(statistics.time.toString()) / (durationTime * 10)).clamp(0, 100).toStringAsFixed(0);

      progressCallback?.call(time);
    });
  }

  /*压缩视频*/
  static Future<FFVideoCutModel> compressVideo(String videoPath,
      {double? startValue, double? endValue}) async {
    FFVideoCutModel cutModel = new FFVideoCutModel(
      path: videoPath,
    );

    File oldFile = File(videoPath);
    if (await oldFile.exists() == false) return cutModel;

    MediaInformation info = await ffprobe.getMediaInformation(videoPath);
    double fileDuration = double.parse(info.getMediaProperties()!['duration']);
    int size = int.parse(info.getMediaProperties()!['size']);

    cutModel.millSecond = fileDuration;
    cutModel.size = size;

    StreamInformation streamInfo = info.getStreams()![0];
    var width = streamInfo.getAllProperties()['width'] ?? 0;
    var height = streamInfo.getAllProperties()['height'] ?? 0;
    cutModel.width = width;
    cutModel.height = height;

    if (size <= 1024 * 1024 * 10) {
      // 小于10M，不进行压缩
      return cutModel;
    }

    startValue = startValue ?? 0;
    endValue = endValue ?? fileDuration;

    var cut = ' -ss $startValue -t ${endValue - startValue}';

    var svg = '';
    if (width > height) {
      if (width > 1080) svg = " -vf scale=1080:-1";
      // svg = " -s 720*480";
    } else {
      if (height > 1080) svg = " -vf scale=-1:1080";
      // svg = " -s 480*720";
    }

    var bit = ' -b:v 1.5M';

    // -strict -2 -qscale 0 -intra //重新编码，会导致文件增大
    cutModel.path = await getVideoRootDirectory() + '${const Uuid().v4()}.mp4';
    var cmd = '-i $videoPath$cut$svg$bit ${cutModel.path}';
    print('cmd === $cmd');

    try {
      await ffmpeg.execute(cmd);
      print('压缩成功');
      MediaInformation info_new = await ffprobe.getMediaInformation(cutModel.path!);

      var oldSize = info.getMediaProperties()!['size'];
      var newSize = info_new.getMediaProperties()!['size'];
      var compressRadio = double.parse(newSize) / double.parse(oldSize);
      cutModel.size = int.parse(newSize.toString());
      cutModel.millSecond = endValue! - startValue!;
      cutModel.width = info_new.getStreams()![0].getAllProperties()['width'];
      cutModel.height = info_new.getStreams()![0].getAllProperties()['height'];

      print('压缩前大小：$oldSize\n压缩后大小：$newSize\n压缩比：$compressRadio');
    } catch (e) {
      // cutModel.path = videoPath;
      print('压缩失败');
    }

    return cutModel;
  }

  /*获取封面图*/
  static Future<String> getVideoCoverImage(String videoPath) async {
    String imgPath = await getVideoRootDirectory(foldName: 'coverImg') + '${const Uuid().v4()}.png';
    var cmd = '-ss 00:00:00.01 -i $videoPath -y -f image2 $imgPath';

    try {
      print('获取封面图成功');
      await ffmpeg.execute(cmd);
    } catch (e) {
      print('获取封面图失败');
      imgPath = '';
    }

    return imgPath;
  }

  /*清空缓存*/
  static cleanCacheVideo() async{
    Directory directory = Directory(await getVideoRootDirectory());
    directory.delete();
  }
}
