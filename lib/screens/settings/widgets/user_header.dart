import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({
    Key? key,
    required this.studentImg,
    required this.qrCode,
    required this.reg,
  }) : super(key: key);

  final Uint8List? studentImg;
  final Uint8List? qrCode;
  final String? reg;

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  bool showBarCode = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Hero(
            tag: "hero-userImage",
            child: CircleAvatar(
              radius: showBarCode ? 30 : 80,
              backgroundImage: MemoryImage(widget.studentImg ?? Uint8List(0)),
              backgroundColor: Colors.transparent,
              onBackgroundImageError: (_, __) =>
                  Image.asset("assets/placeholder_profile.png"),
            ),
          ),
        ),
        Expanded(
          flex: showBarCode ? 6 : 1,
          child: InkWell(
            child: showBarCode
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child:
                          SfBarcodeGenerator(value: widget.reg ?? "URKblabla"),
                    ),
                  )
                : widget.qrCode == null
                    ? Text("No QR code available for now!")
                    : Image.memory(widget.qrCode ?? Uint8List(0)),
            onTap: () => setState(() => showBarCode = !showBarCode),
            onLongPress: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(
                      child: InteractiveViewer(
                        clipBehavior: Clip.none,
                        minScale: 1,
                        maxScale: 4,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: showBarCode
                              ? SfBarcodeGenerator(value: widget.reg)
                              : Image.memory(widget.qrCode ?? Uint8List(0)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
