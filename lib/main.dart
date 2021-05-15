import 'dart:ui';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:async/async.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' as io;
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool photoBSAnimationEnd = false;
  bool BSPhotoState = false;
  String imageForAdvEmoo;

  AsyncMemoizer _memoizerPhotoBar = AsyncMemoizer();
  AsyncMemoizer _memoizerCamera = AsyncMemoizer();

  Future<CameraController> getCameraController() async{
    List<CameraDescription> cameras;
    cameras = await availableCameras();
    CameraController controller;
    controller = CameraController(cameras[0], ResolutionPreset.low);
    await controller.initialize();
    return controller;
  }

  Future<List> loadImageList() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }


    List<AssetPathEntity> list = await PhotoManager.getAssetPathList(type: RequestType.image);
    final assetList = await list[0].getAssetListRange(start: 0, end: 1000); // use start and end to get asset.

    return assetList;
  }

  Future<io.File> loadImageFile(AssetEntity entity) async{
    return await entity.file;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Stack(children: [
        Align(child: Padding(
          padding: EdgeInsets.fromLTRB(0,50,0,0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 35,
            width: 100,
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.indigo[100].withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  color: Colors.indigo[100].withOpacity(0.6),
                  blurRadius: 2,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("EN", style: TextStyle(color: Colors.indigo[600], fontWeight: FontWeight.bold),),
                Container(decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5),
                  color: Colors.indigo[600],
                ),
                height: 30,
                width: 5,),
                Text("RU", style: TextStyle(color: Colors.indigo[600], fontWeight: FontWeight.bold),),
              ],
            ),
          ),
        ),
          alignment: Alignment(0, -1),),
        Align(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
            child: ListView(children: [
              WordWidget(),
              WordWidget(),
              WordWidget(),
              WordWidget(),
            ],),),
          alignment: Alignment(0, -1),
        ),
        GestureDetector(
          onTap: () {setState(() {
            BSPhotoState = false;
          });},
          child: AnimatedOpacity(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black,
            ),
            opacity: BSPhotoState ? 0.33 : 0,
            duration: Duration(milliseconds: 500),
          ),
        ),
        Align(alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  GestureDetector(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.indigo[200].withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            color: Colors.indigo[200].withOpacity(0.5),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(Icons.history_rounded, color: Colors.indigo[50], size: 25),

                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.indigo[200].withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            color: Colors.indigo[200].withOpacity(0.5),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(Icons.add_rounded, color: Colors.indigo[50], size: 50),

                    ),
                    onTap: () {setState(() {
                      BSPhotoState=true;
                    });},
                  ),
                  GestureDetector(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.indigo[200].withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            color: Colors.indigo[200].withOpacity(0.5),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(Icons.share_rounded, color: Colors.indigo[50], size: 25),

                    ),
                  )
                ],),
            )
        ),
        AnimatedPositioned(
          onEnd: () {
            setState(() {
              photoBSAnimationEnd = true;
            });
          },
          curve: Curves.easeInOutQuart,
          duration: Duration(milliseconds: 1000),
          bottom: BSPhotoState ? 0 : -500,

          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 500,
              decoration: new BoxDecoration(
                color: Colors.indigo[100],
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                ),
              ),

              child:Column(
                children: [
                  SizedBox(height: 30,),
                  Expanded(child: FutureBuilder(
                    future:_memoizerPhotoBar.runOnce(loadImageList),
                    builder: (context, allImagesSnapshot)
                    {
                      if(allImagesSnapshot.data==null)
                        return Center(
                            child: CircularProgressIndicator(backgroundColor: Colors.red)
                        );
                      else
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5,),
                          child:

                          MediaQuery.removePadding(
                            context: context,
                            child: GridView.count(


                              crossAxisCount: 3,

                              children: List.generate(allImagesSnapshot.data.length, (index) {

                                if(index==0){
                                  if(photoBSAnimationEnd)
                                    return Padding(
                                        padding: EdgeInsets.all(5),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            //child: Container(color: Colors.white,),

                                            child: Stack(
                                              children: [
                                                FutureBuilder(
                                                  future: _memoizerCamera.runOnce(getCameraController),
                                                  builder: (context, snapshotCamController) {
                                                    return snapshotCamController.data==null ? Stack(
                                                      children: [
                                                        Container(color: Colors.grey,),
                                                        Center(
                                                          child: Image.asset("assets/camera_icon.png", width: 45,),
                                                        )],
                                                    ) :
                                                    InkWell(
                                                      onTap: () async {
                                                        // Take the Picture in a try / catch block. If anything goes wrong,
                                                        // catch the error.
                                                        try {
                                                          // final path = (await getApplicationDocumentsDirectory()).path + '${DateTime.now()}.png';
                                                          //
                                                          // await snapshotCamController.data.takePicture(path);
                                                          final picker = ImagePicker();

                                                          imageForAdvEmoo = (await picker.getImage(source: ImageSource.camera)).path;
                                                          _memoizerCamera = AsyncMemoizer();
                                                          BSPhotoState = false;
                                                          photoBSAnimationEnd=false;
                                                        } catch (e) {
                                                          // If an error occurs, log the error to the console.
                                                          print(e);
                                                        }},
                                                      child: Stack(
                                                        children: [
                                                          AspectRatio(
                                                            aspectRatio: 1,
                                                            child: CameraPreview(snapshotCamController.data),),
                                                          Center(
                                                            child: Image.asset("assets/camera_icon.png", width: 45,),
                                                          )],
                                                      ),
                                                    );
                                                  },
                                                ),

                                              ],
                                            )

                                        ));
                                  else
                                    return Padding(
                                        padding: EdgeInsets.all(5),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),

                                          child:Stack(
                                            children: [
                                              Container(color: Colors.grey,),
                                              Center(
                                                child: Image.asset("assets/camera_icon.png", width: 45,),
                                              )
                                            ],
                                          ),

                                        ));

                                }
                                else{
                                  return Padding(
                                      padding: EdgeInsets.all(5),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: FutureBuilder(
                                              future: loadImageFile(allImagesSnapshot.data[index-1]),
                                              builder: (context, entitySnapshot) {
                                                return InkWell(
                                                    onTap: () {
                                                      imageForAdvEmoo = entitySnapshot.data.path;
                                                      BSPhotoState = false;
                                                      photoBSAnimationEnd=false;
                                                    },

                                                    child:  entitySnapshot.data==null ? Container() : Image.file(
                                                      entitySnapshot.data,
                                                      fit: BoxFit.cover,
                                                      filterQuality: FilterQuality.low,
                                                      cacheWidth: 250,
                                                    )
                                                );
                                              }
                                          )
                                      ));

                                }

                              }),
                            ),
                            removeTop: true,)
                          ,
                        );
                    },
                  ),)
                ],
              )

          ) ,
        ),
      ],
      ),
    );
  }
}

class WordWidget extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          height: 30,
          width: double.infinity,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.indigo[100].withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                color: Colors.indigo[100].withOpacity(0.5),
                blurRadius: 2,
              )
            ],
          ),
        ));
  }

}
