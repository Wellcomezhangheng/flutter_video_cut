import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_video_cut/flutter_video_cut.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  runApp(MaterialApp(home: VideoPage(),));
}


class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  String? _oldVideoPath;

  VideoPlayerController? _playerController;

  StateSetter? _setter;

  String? _imgPath;

  late FFVideoCutModel cutModel = FFVideoCutModel();

  late ValueNotifier<int> _progress;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupState();
  }

  // 初始化
  void _setupState() {
    _setter = setState;
    _progress = ValueNotifier(0);
    _test();
  }

  _setupPlayer(String path) {

    _playerController = VideoPlayerController.file(File(path))..initialize().then((value) {
      _setter!.call(() {});
      _playerController!.play();
    });
  }

  _test() async {
    var url = 'http://video.training.luojigou.vip/lh_bppTr94lBozn2tpboSZ_mSL-m_low.mp4';
    /*保存到缓存文件*/
    var fileInfo = await DefaultCacheManager().downloadFile(url);
    print('fileInfo===${fileInfo.file.path}');

    _oldVideoPath = fileInfo.file.path;

    _setupPlayer(_oldVideoPath!);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('视频操作'),),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildVideoWidget(),
              SizedBox(height: 30,),
              _imgPath == null ? SizedBox() : Container(
                height: 200,
                width: double.infinity,
                child: Image.file(File(_imgPath!), fit: BoxFit.cover,),
              ),
              TextButton(onPressed: _onTapOldPath, child: Text('切换原视频')),
              TextButton(onPressed: _onTapCutPath, child: Text('剪切原视频')),
              TextButton(onPressed: _onTapCoverImg, child: Text('获取封面图')),
              // TextButton(onPressed: _onTapCompressSVGPath, child: Text('压缩分辨率原视频')),
              // TextButton(onPressed: _onTapCompressBitPath, child: Text('压缩码率原视频')),

            ],

          ),
        ),
      ),
    );
  }

  _buildVideoWidget() {
    if (_playerController == null) {
      return SizedBox(height: 300,);
    }
    return Container(
      // color: Colors.green,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: 300,
        ),
        child: Stack(
          children: [
            _playerController!.value.isInitialized ? AspectRatio(aspectRatio: _playerController!.value.aspectRatio, child: VideoPlayer(_playerController!),) : Container(
              height: 300,
              width: double.infinity,
              child: Center(
                child: SizedBox(),
              ),
            ),
            ValueListenableBuilder<int>(valueListenable: _progress, builder: (ctx, value, child) {
              if (value == 0 || value >= 99) {
                return SizedBox();
              }
              return Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(height: 5,),
                    Text('进度${_progress.value}%', style: TextStyle(color: Colors.white),)
                  ],
                ),
              );
            }),
          ],
        )
    );
  }



  // 切换原视频
  _onTapOldPath() {
    _setupPlayer(_oldVideoPath!);
  }

  // 剪切原视频
  _onTapCutPath() async {

    var startValue = 0.0;
    var endValue   = 100.0;
    _playerController!.pause();
    /*进度*/
    FFVideoUtil.getVideoCompressProgress((progress) {
      print('progress:$progress');
      _progress.value = int.parse(progress);
    }, endValue - startValue);

   cutModel = await FFVideoUtil.compressVideo(_oldVideoPath!, startValue: startValue, endValue: endValue);
    _setupPlayer(cutModel.path!);
  }

  // 获取封面图
  _onTapCoverImg() async {
    _imgPath = await FFVideoUtil.getVideoCoverImage(cutModel.path!);
    print('_imgPath===$_imgPath');
    setState(() {

    });
  }

}
