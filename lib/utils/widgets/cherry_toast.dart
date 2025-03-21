import 'dart:async';
import 'package:flutter/material.dart';

import 'enum.dart';

const Color defaultBackgroundColor = Colors.white;
const Color defaultShadowColor = Colors.grey;
const Color successColor = Colors.green;
const Color errorColor = Colors.red;
const Color warningColor = Colors.orange;
const Color infoColor = Colors.blue;

class CherryToast extends StatefulWidget {
  OverlayEntry? overlayEntry;

  CherryToast({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
    this.iconColor = Colors.black,
    this.action,
    this.backgroundColor = defaultBackgroundColor,
    this.shadowColor = defaultShadowColor,
    this.actionHandler,
    this.description,
    this.iconWidget,
    this.displayTitle = true,
    this.toastPosition = Position.top,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.toastDuration = const Duration(milliseconds: 3000),
    this.layout = ToastLayout.ltr,
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.iconSize = 20,
    this.height,
    this.width,
    this.constraints,
    this.disableToastAnimation = false,
    this.onToastClosed,
  });

  CherryToast.success({
    super.key,
    required this.title,
    this.action,
    this.actionHandler,
    this.description,
    this.backgroundColor = defaultBackgroundColor,
    this.shadowColor = defaultShadowColor,
    this.displayTitle = true,
    this.toastPosition = Position.top,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.toastDuration = const Duration(milliseconds: 3000),
    this.layout = ToastLayout.ltr,
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.iconWidget,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.height,
    this.width,
    this.constraints,
    this.disableToastAnimation = false,
    this.onToastClosed,
  }) {
    icon = Icons.check_circle;
    _initializeAttributes(successColor);
  }

  CherryToast.error({
    super.key,
    required this.title,
    this.action,
    this.actionHandler,
    this.backgroundColor = defaultBackgroundColor,
    this.shadowColor = defaultShadowColor,
    this.description,
    this.displayTitle = true,
    this.toastPosition = Position.top,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.iconWidget,
    this.toastDuration = const Duration(milliseconds: 3000),
    this.layout = ToastLayout.ltr,
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.height,
    this.width,
    this.constraints,
    this.disableToastAnimation = false,
    this.onToastClosed,
  }) {
    icon = Icons.error_rounded;
    _initializeAttributes(errorColor);
  }

  CherryToast.warning({
    super.key,
    required this.title,
    this.action,
    this.actionHandler,
    this.description,
    this.backgroundColor = defaultBackgroundColor,
    this.shadowColor = defaultShadowColor,
    this.displayTitle = true,
    this.toastPosition = Position.top,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.toastDuration = const Duration(milliseconds: 3000),
    this.layout = ToastLayout.ltr,
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.iconWidget,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.height,
    this.width,
    this.constraints,
    this.disableToastAnimation = false,
    this.onToastClosed,
  }) {
    icon = Icons.warning_rounded;
    _initializeAttributes(warningColor);
  }

  CherryToast.info({
    super.key,
    required this.title,
    this.action,
    this.actionHandler,
    this.description,
    this.backgroundColor = defaultBackgroundColor,
    this.shadowColor = defaultShadowColor,
    this.displayTitle = true,
    this.toastPosition = Position.top,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.toastDuration = const Duration(milliseconds: 3000),
    this.layout = ToastLayout.ltr,
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.iconWidget,
    this.height,
    this.width,
    this.constraints,
    this.disableToastAnimation = false,
    this.onToastClosed,
  }) {
    icon = Icons.info_rounded;
    _initializeAttributes(infoColor);
  }

  void _initializeAttributes(Color color) {
    themeColor = color;
    iconColor = color;
    iconSize = 20;
  }

  final Text title;
  final Text? description;
  final Widget? action;
  final bool displayTitle;
  late IconData icon;
  late Color iconColor;
  final Color backgroundColor;
  final Color shadowColor;
  final Widget? iconWidget;
  late double iconSize;
  final Position toastPosition;
  late Color themeColor;
  final Function? actionHandler;
  final Duration animationDuration;
  final Cubic animationCurve;
  final AnimationType animationType;
  final bool autoDismiss;
  final Duration toastDuration;
  final ToastLayout layout;
  final bool displayCloseButton;
  final double borderRadius;
  final bool displayIcon;
  final bool enableIconAnimation;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final bool disableToastAnimation;
  final Function()? onToastClosed;

  void show(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: toastPosition == Position.top ? 0 : null,
        bottom: toastPosition == Position.bottom ? 0 : null,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: this,
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  void closeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  _CherryToastState createState() => _CherryToastState();
}

class _CherryToastState extends State<CherryToast> with TickerProviderStateMixin {
  late Animation<Offset> offsetAnimation;
  late AnimationController slideController;
  late BoxDecoration toastDecoration;
  Timer? autoDismissTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.disableToastAnimation) {
      initAnimation();
    }
    toastDecoration = BoxDecoration(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: [
        BoxShadow(
          color: widget.shadowColor,
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
    if (widget.autoDismiss) {
      autoDismissTimer = Timer(widget.toastDuration, () {
        if (!widget.disableToastAnimation && mounted) {
          slideController.reverse().then((_) {
            widget.closeOverlay();
            widget.onToastClosed?.call();
          });
        } else {
          widget.closeOverlay();
          widget.onToastClosed?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    autoDismissTimer?.cancel();
    if (!widget.disableToastAnimation) {
      slideController.dispose();
    }
    super.dispose();
  }

  void initAnimation() {
    slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    switch (widget.animationType) {
      case AnimationType.fromLeft:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(-2, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: slideController, curve: widget.animationCurve),
        );
        break;
      case AnimationType.fromRight:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(2, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: slideController, curve: widget.animationCurve),
        );
        break;
      case AnimationType.fromTop:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -2),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: slideController, curve: widget.animationCurve),
        );
        break;
      case AnimationType.fromBottom:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 2),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: slideController, curve: widget.animationCurve),
        );
        break;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.disableToastAnimation) {
        slideController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.disableToastAnimation
        ? _buildToastContent(context)
        : SlideTransition(
      position: offsetAnimation,
      child: _buildToastContent(context),
    );
  }

  Widget _buildToastContent(BuildContext context) {
    return Container(
      decoration: toastDecoration,
      width: MediaQuery.of(context).size.width,
      height: widget.height ?? 60.0,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: widget.layout == ToastLayout.ltr
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: widget.description == null && widget.action == null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (widget.iconWidget != null)
                  widget.iconWidget!
                else if (widget.displayIcon)
                  CherryToastIcon(
                    color: widget.themeColor,
                    icon: widget.icon,
                    iconSize: widget.iconSize,
                    iconColor: widget.iconColor,
                    enableAnimation: widget.enableIconAnimation,
                  )
                else
                  Container(),
                _buildContent(),
              ],
            ),
          ),
          if (widget.displayCloseButton) _buildCloseButton(),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.displayCloseButton) _buildCloseButton(),
          Expanded(
            child: Row(
              crossAxisAlignment: widget.description == null && widget.action == null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                _buildContent(),
                if (widget.displayIcon)
                  CherryToastIcon(
                    color: widget.themeColor,
                    icon: widget.icon,
                    iconSize: widget.iconSize,
                    iconColor: widget.iconColor,
                    enableAnimation: widget.enableIconAnimation,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: widget.layout == ToastLayout.ltr
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (widget.displayTitle) widget.title,
            if (widget.description != null) ...[
              const SizedBox(height: 5),
              widget.description!,
            ],
            if (widget.action != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => widget.actionHandler?.call(),
                child: widget.action!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: () {
        if (!widget.disableToastAnimation) slideController.reverse();
        autoDismissTimer?.cancel();
        Timer(widget.animationDuration, () => widget.closeOverlay());
      },
      child: const Icon(Icons.close, color: Colors.grey, size: 15),
    );
  }
}

class CherryToastIcon extends StatefulWidget {
  final Color color;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final bool enableAnimation;

  const CherryToastIcon({
    super.key,
    required this.color,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.enableAnimation,
  });

  @override
  _CherryToastIconState createState() => _CherryToastIconState();
}

class _CherryToastIconState extends State<CherryToastIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      )..repeat(reverse: true);
      _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimation) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon,
        color: widget.iconColor,
        size: widget.iconSize,
      ),
    );

    return widget.enableAnimation
        ? ScaleTransition(
      scale: _animation,
      child: icon,
    )
        : icon;
  }
}