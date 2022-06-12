// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:connectivity/connectivity.dart';

class NetworkAwareWidget extends StatefulWidget {
  NetworkAwareWidget({
    Key? key,
    required this.child,
    required this.noInternetWidget,
    this.loadingWidget,
    this.removeAwarenessAfterConnection = false,
    this.showDialogWhenOffline = false,
  }) : super(key: key);

  /// Widget to be shown when there is a active internet connection. i.e if the [ConnectivityResult] is not [ConnectivityResult.none]
  final Widget child;

  /// Widget to be shown when the host is offline. i.e if the [ConnectivityResult] is  [ConnectivityResult.none]
  final Widget noInternetWidget;

  /// Widget to be shown when the future and stream waits for conencting to the host network status
  /// Default is [SizedBox]
  final Widget? loadingWidget;

  /// Whether to show [noInternetWidget] when the device is successfully connected to the internet once but becomes offline in the future
  final bool removeAwarenessAfterConnection;

  /// Show a disruptive dialog when the device goes offline
  final bool showDialogWhenOffline;

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  bool _isDialogOpen = false;
  bool _isConnected = false;
  late Future<ConnectivityResult> _connectivityFuture;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    _connectivityFuture = Connectivity().checkConnectivity();
    _connectivityStream = Connectivity().onConnectivityChanged;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: _connectivityFuture,
      builder: (context, future) {
        if (future.connectionState == ConnectionState.done) {
          return StreamBuilder<ConnectivityResult>(
              stream: _connectivityStream,
              initialData: future.data,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (_isConnected && widget.removeAwarenessAfterConnection) {
                  if (widget.showDialogWhenOffline) {
                    manageDialog(context, snapshot.data);
                  }

                  return widget.child;
                }

                _isConnected = snapshot.data != ConnectivityResult.none;

                if (snapshot.data == ConnectivityResult.none)
                  return widget.noInternetWidget;

                return widget.child;
              });
        }

        return widget.loadingWidget ?? const SizedBox();
      },
    );
  }

  Future manageDialog(BuildContext context, ConnectivityResult result) async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (result == ConnectivityResult.none) {
        if (!_isDialogOpen) {
          _isDialogOpen = true;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text("No Internet"),
              content: Text(
                  "There is no internet connection. You will still be able to access cached information but its advised to turn on internet for better experience!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    _isDialogOpen = false;
                  },
                  child: const Text("Understood"),
                ),
              ],
            ),
          ).then((value) => _isDialogOpen = false);
        }
      } else {
        if (_isDialogOpen) Navigator.of(context).pop();
      }
    });
  }
}
