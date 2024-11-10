import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'blur_transition.dart';
import 'custom_toast_content_widget.dart';

void toastWithCustomPosition(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      toastHorizontalMargin: 10.0,
      context: context,
      position:
          const StyledToastPosition(align: Alignment.topLeft, offset: 20.0));
}

void toastWithFadeAnimation(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.fade,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
      context: context);
}

void toastWithAnimation(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: const Offset(0.0, -3.0),
      reverseEndOffset: const Offset(0.0, -3.0),
      duration: const Duration(seconds: 4),
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn,
      context: context);
}

void toastWithAnimationTopFade(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.slideFromTopFade,
      reverseAnimation: StyledToastAnimation.slideToTopFade,
      position:
          const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
      startOffset: const Offset(0.0, -3.0),
      reverseEndOffset: const Offset(0.0, -3.0),
      duration: const Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: const Duration(seconds: 1),
      curve: Curves.fastLinearToSlowEaseIn,
      reverseCurve: Curves.fastOutSlowIn,
      context: context);
}

void toastWithAnimationFromBottom(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.slideFromBottom,
      reverseAnimation: StyledToastAnimation.slideToBottom,
      startOffset: const Offset(0.0, 3.0),
      reverseEndOffset: const Offset(0.0, 3.0),
      position: StyledToastPosition.bottom,
      duration: const Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn,
      context: context);
}

void toastWithAnimationSlideFromLeftFade(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.slideFromLeftFade,
      reverseAnimation: StyledToastAnimation.slideToTopFade,
      toastHorizontalMargin: 0.0,
      position:
          const StyledToastPosition(align: Alignment.topLeft, offset: 20.0),
      startOffset: const Offset(-1.0, 0.0),
      reverseEndOffset: const Offset(-1.0, 0.0),
      //Toast duration   animDuration * 2 <= duration
      duration: const Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: const Duration(seconds: 1),
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.fastOutSlowIn,
      context: context);
}

void toastWithAnimationSlideFromRight(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.slideFromRight,
      reverseAnimation: StyledToastAnimation.slideToRight,
      position: StyledToastPosition.top,
      startOffset: const Offset(1.0, 0.0),
      reverseEndOffset: const Offset(1.0, 0.0),
      animDuration: const Duration(seconds: 1),
      duration: const Duration(seconds: 4),
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.fastOutSlowIn,
      context: context);
}

void toastSizeWithAnimation(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.size,
      reverseAnimation: StyledToastAnimation.size,
      axis: Axis.horizontal,
      position: StyledToastPosition.center,
      animDuration: const Duration(milliseconds: 400),
      duration: const Duration(seconds: 2),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
      context: context);
}

void toastSizeFade(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.sizeFade,
      reverseAnimation: StyledToastAnimation.sizeFade,
      axis: Axis.horizontal,
      position: StyledToastPosition.center,
      animDuration: const Duration(milliseconds: 400),
      duration: const Duration(seconds: 2),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
      context: context);
}

void toastScale(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: const Duration(seconds: 1),
      duration: const Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      context: context);
}

void toastFadeScale(BuildContext context, String msg) {
  showToast(msg,
      // context: context,
      animation: StyledToastAnimation.fadeScale,
      reverseAnimation: StyledToastAnimation.fadeScale,
      // reverseAnimation: StyledToastAnimation.scaleRotate,
      position: StyledToastPosition.center,
      animDuration: const Duration(seconds: 1),
      duration: const Duration(seconds: 4),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
      context: context);
}

void toastCustomMultipeAnimation(BuildContext context, String msg) {
  showToast(
    msg,
    context: context,
    animationBuilder: (context, controller, duration, child) {
      final scale = Tween<double>(begin: 1.3, end: 1.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.easeInSine,
            reverseCurve: Curves.easeOutSine),
      );
      final sigma = Tween<double>(begin: 0.0, end: 8.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.easeInSine,
            reverseCurve: Curves.easeOutSine),
      );
      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.easeInSine,
            reverseCurve: Curves.easeOutSine),
      );
      return ScaleTransition(
          scale: scale,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BlurTransition(
                sigma: sigma,
                child: FadeTransition(
                  opacity: opacity,
                  child: child,
                ),
              )));
    },
    reverseAnimBuilder: (context, controller, duration, child) {
      final sigma = Tween<double>(begin: 10.0, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutSine,
            reverseCurve: Curves.easeInSine),
      );
      final opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutSine,
            reverseCurve: Curves.easeInSine),
      );
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BlurTransition(
          sigma: sigma,
          child: FadeTransition(
            opacity: opacity,
            child: child,
          ),
        ),
      );
    },
    position: StyledToastPosition.bottom,
    animDuration: const Duration(milliseconds: 1000),
    duration: const Duration(seconds: 4),
    curve: Curves.elasticOut,
    reverseCurve: Curves.linear,
  );
}

void successBanner(BuildContext context, String msg) {
  showToastWidget(
    BannerToastWidget.success(msg: msg),
    // context: context,
    animation: StyledToastAnimation.slideFromLeft,
    reverseAnimation: StyledToastAnimation.slideToLeft,
    alignment: Alignment.centerLeft,
    axis: Axis.horizontal,
    position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
    startOffset: const Offset(-1.0, 0.0),
    reverseEndOffset: const Offset(-1.0, 0.0),
    animDuration: const Duration(milliseconds: 400),
    duration: const Duration(seconds: 2),
    curve: Curves.linearToEaseOut,
    reverseCurve: Curves.fastOutSlowIn,
    context: context,
  );
}

void failedBanner(BuildContext context, String msg) {
  showToastWidget(
    BannerToastWidget.fail(msg: msg),
    // context: context,
    animation: StyledToastAnimation.slideFromLeft,
    reverseAnimation: StyledToastAnimation.slideToLeft,
    alignment: Alignment.centerLeft,
    axis: Axis.horizontal,
    position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
    startOffset: const Offset(-1.0, 0.0),
    reverseEndOffset: const Offset(-1.0, 0.0),
    animDuration: const Duration(milliseconds: 400),
    duration: const Duration(seconds: 2),
    curve: Curves.linearToEaseOut,
    reverseCurve: Curves.fastOutSlowIn,
    context: context,
  );
}

void failed(BuildContext context, String msg) {
  showToastWidget(IconToastWidget.fail(msg: msg),
      // context: context,
      position: StyledToastPosition.center,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      duration: const Duration(seconds: 4),
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      context: context);
}

void success(BuildContext context, String msg) {
  showToastWidget(IconToastWidget.success(msg: msg),
      // context: context,
      position: StyledToastPosition.center,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      duration: const Duration(seconds: 4),
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      context: context);
}
