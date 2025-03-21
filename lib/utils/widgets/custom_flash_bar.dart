import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_text_style.dart';
import 'cherry_toast.dart';
import 'enum.dart';

class CustomFlashBar {
  static void show({
    required BuildContext context,
    required String message,
    bool isAdmin = false,
    bool isShaking = true,
    Color primaryColor = Colors.blue,
    Color secondaryColor = Colors.white,
  }) {
    final flashBar = CherryToast.warning(
      autoDismiss: true,
      toastPosition: Position.top,
      displayCloseButton: false,
      animationType: AnimationType.fromTop,
      borderRadius: 0,
      backgroundColor: isAdmin ? primaryColor : Colors.white,
      displayTitle: false,
      displayIcon: false,
      width: MediaQuery.of(context).size.width,
      height: 70.0,
      shadowColor: Colors.transparent,
      title: const Text(''),
      toastDuration: const Duration(seconds: 3), // Set to 2 seconds
      action: Align(
        alignment: Alignment.bottomCenter,
        child: isShaking
            ? ShakeAnimation(
          child: Text(
            message,
            style: AppTextStyle.regularBlack16.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
            : Text(
          message,
          style: AppTextStyle.regularBlack16.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actionHandler: () {},
    );

    flashBar.show(context);

    if (isShaking) {
      Future.delayed(const Duration(seconds: 2), () {
        ShakeAnimation.stopShaking();
      });
    }
  }
}

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final int durationMs;
  static final _controllerNotifier = ValueNotifier<AnimationController?>(null);

  const ShakeAnimation({required this.child, this.durationMs = 500, super.key});

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();

  static void stopShaking() {
    _controllerNotifier.value?.stop();
  }
}

class _ShakeAnimationState extends State<ShakeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });

    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    ShakeAnimation._controllerNotifier.value = _controller;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
    );
  }
}