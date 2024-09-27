import 'package:flutter/material.dart';
import 'package:ray_something/steps_explanation/step_4/step_4.dart';

import 'step_1/step_one.dart';
import 'step_2/step_2.dart';
import 'step_3/step_3.dart';
import 'step_6/step_6.dart';

class StepsExplanationScreen extends StatefulWidget {
  const StepsExplanationScreen({super.key});

  @override
  State<StepsExplanationScreen> createState() => _StepsExplanationScreenState();
}

class _StepsExplanationScreenState extends State<StepsExplanationScreen> {
  int currentPage = 0;
  final stepsScreens = const [Step1(), Step2(), Step3(), Step4(), Step6()];

  PageController pageController = PageController();

  @override
  void initState() {
    pageController = PageController(initialPage: currentPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(controller: pageController, children: stepsScreens),
          Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < stepsScreens.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: stepSelectonButton(i),
                    )
                ],
              )),
        ],
      ),
    );
  }

  Widget stepSelectonButton(int index) {
    final isCurrentPage = currentPage == index;
    final step = index + 1;
    return InkWell(
      splashColor: Colors.blue,
      radius: 20,
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          currentPage = index;

          pageController.animateToPage(currentPage,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: isCurrentPage ? Colors.grey : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isCurrentPage
                ? [
                    const BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(2, 3),
                    ),
                  ],
            gradient: isCurrentPage
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue,
                      Colors.green,
                    ],
                  ),
          ),
          width: 70,
          height: 70,
          child: Center(
              child: Text('Step $step',
                  style: const TextStyle(color: Colors.white, fontSize: 16)))),
    );
  }
}
