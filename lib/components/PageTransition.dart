import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool oldMainLocation = true; 
final List<String> listMainLocation = ["/", "/expert", "/settings", "/action"];

dynamic buildPageWithDefaultTransition<T>({
  required BuildContext context, 
  required GoRouterState state, 
  required Widget child,
}) {

  bool? isAnimation = true;
  bool mainLocation = listMainLocation.indexWhere((element) => element == state.location) >= 0;
  print(isAnimation);
  if (mainLocation == true && oldMainLocation == true) {
    isAnimation = false;
  }
  print(isAnimation);
  oldMainLocation = mainLocation;

  if (isAnimation) { 
    return MaterialPage<void>(
      key: state.pageKey,
      restorationId: state.pageKey.value,
      child: child,
    );
  }
  else {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 100),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    );
  }
}