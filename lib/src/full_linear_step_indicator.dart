import 'package:flutter/material.dart';
import 'package:linear_step_indicator/src/constants.dart';
import 'package:linear_step_indicator/src/extensions.dart';
import 'package:linear_step_indicator/src/node.dart';

class FullLinearStepIndicator extends StatefulWidget {
  ///Controller for tracking page changes.
  ///
  ///Typically, controller should animate or jump to next page
  ///when a step is completed
  final PageController controller;

  ///Number of nodes to paint on screen
  final int steps;

  ///[completedIcon] size
  final double iconSize;

  ///Size of each node
  final double nodeSize;

  ///Height of separating line
  final double lineHeight;

  ///Icon showed when a step is completed
  final IconData completedIcon;

  ///Color of each completed node border
  final Color activeBorderColor;

  ///Color of each uncompleted node border
  final Color inActiveBorderColor;

  ///Color of each separating line after a completed node
  final Color activeLineColor;

  ///Color of each separating line after an uncompleted node
  final Color inActiveLineColor;

  ///Background color of a completed node
  final Color activeNodeColor;

  ///Background color of an uncompleted node
  final Color inActiveNodeColor;

  ///Thickness of node's borders
  final double nodeThickness;

  ///Node's shape
  final BoxShape shape;

  ///[completedIcon] color
  final Color iconColor;

  final Color? nodeBackgroundColor;

  ///Step indicator's background color
  final Color backgroundColor;

  ///Boolean function that returns [true] when last node should be completed
  final Complete? complete;

  ///Step indicator's vertical padding
  final double verticalPadding;

  ///Labels for individual nodes
  final List<String> labels;

  ///Textstyle for an active label
  final TextStyle? activeLabelStyle;

  ///Textstyle for an inactive label
  final TextStyle? inActiveLabelStyle;

  final double? leftTitlePadding;
  final double? rightTitlePadding;
  final Widget? checkedWidget;
  const FullLinearStepIndicator({
    Key? key,
    required this.steps,
    required this.controller,
    this.activeBorderColor = kActiveColor,
    this.inActiveBorderColor = kInActiveColor,
    this.activeLineColor = kActiveLineColor,
    this.rightTitlePadding = 45,
    this.leftTitlePadding = 65,
    this.checkedWidget,
    this.inActiveLineColor = kInActiveLineColor,
    this.activeNodeColor = kActiveColor,
    this.inActiveNodeColor = kInActiveNodeColor,
    this.iconSize = kIconSize,
    this.completedIcon = kCompletedIcon,
    this.nodeThickness = kDefaultThickness,
    this.nodeSize = kDefaultSize,
    this.verticalPadding = kDefaultSize,
    this.lineHeight = kDefaultLineHeight,
    this.shape = BoxShape.circle,
    this.iconColor = kIconColor,
    this.nodeBackgroundColor,
    this.backgroundColor = kIconColor,
    this.complete,
    this.labels = const <String>[],
    this.activeLabelStyle,
    this.inActiveLabelStyle,
  })  : assert(steps > 0, "steps value must be a non-zero positive integer"),
        assert(labels.length == steps || labels.length == 0,
            "Provide exactly $steps strings for labels"),
        super(key: key);

  @override
  _FullLinearStepIndicatorState createState() =>
      _FullLinearStepIndicatorState();
}

class _FullLinearStepIndicatorState extends State<FullLinearStepIndicator> {
  late List<Node> nodes;
  late int lastStep;

  @override
  void initState() {
    super.initState();
    nodes = List<Node>.generate(widget.steps, (index) => Node(step: index));
    lastStep = 0;

    widget.controller.addListener(() async {
      if (widget.controller.page! > lastStep) {
        setState(() {
          nodes[lastStep].completed = true;
          lastStep = widget.controller.page!.ceil();
        });
      }

      if (widget.controller.page! == widget.steps - 1 &&
          widget.complete != null) {
        if (await widget.complete!()) {
          // nodes[widget.steps - 1].completed = true;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
        color: widget.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.labels.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(
                    right: widget.leftTitlePadding!,
                    left: widget.rightTitlePadding!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (int i = 0; i < widget.labels.length; i++) ...[
                      Flexible(
                        flex: 1,
                        child: Text(
                          widget.labels[i],
                          textAlign: TextAlign.center,
                          style: widget.controller.hasClients
                              ? (widget.controller.page?.round() ?? 0) >=
                                      nodes.indexOf(nodes[i])
                                  ? widget.activeLabelStyle
                                  : nodes[i].completed
                                      ? widget.activeLabelStyle
                                      : widget.inActiveLabelStyle
                              : widget.inActiveLabelStyle,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var node in nodes) ...[
                  if (nodes.indexOf(node) == 0) ...{
                    Container(
                      color: widget.controller.hasClients
                          ? (widget.controller.page?.round() ?? 0) >=
                                  nodes.indexOf(node)
                              ? widget.activeLineColor
                              : node.completed
                                  ? widget.activeLineColor
                                  : widget.inActiveLineColor
                          : widget.inActiveLineColor,
                      height: widget.lineHeight,
                      width: context.screenWidth(1 / widget.steps) * .25,
                    ),
                  },
                  AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      alignment: Alignment.center,
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.controller.hasClients
                            ? (widget.controller.page?.round() ?? 0) >=
                                    nodes.indexOf(node)
                                ? widget.nodeBackgroundColor
                                : node.completed
                                    ? widget.nodeBackgroundColor
                                    : widget.inActiveNodeColor
                            : widget.inActiveNodeColor,
                        border: Border.all(
                          width: 2,
                          color: widget.controller.hasClients
                              ? (widget.controller.page?.round() ?? 0) >=
                                      nodes.indexOf(node)
                                  ? widget.activeNodeColor
                                  : node.completed
                                      ? widget.activeNodeColor
                                      : widget.inActiveNodeColor
                              : widget.inActiveNodeColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: .5,
                            blurRadius: .5,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(.4),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                          animation: widget.controller,
                          builder: (context, child) {
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: node.completed
                                  ? 1.0
                                  : widget.controller.hasClients
                                      ? (widget.controller.page?.round() ??
                                                  0) ==
                                              nodes.indexOf(node)
                                          ? 1.0
                                          : 0.0
                                      : 0,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: node.completed
                                    ? widget.checkedWidget
                                    : widget.controller.hasClients
                                        ? (widget.controller.page?.round() ??
                                                    0) ==
                                                nodes.indexOf(node)
                                            ? Text(
                                                "${nodes.indexOf(node) + 1}",
                                                key: ValueKey<int>(
                                                    nodes.indexOf(node)),
                                                style: TextStyle(
                                                  color: widget.activeNodeColor,
                                                ),
                                              )
                                            : null
                                        : Text(
                                            "${nodes.indexOf(node) + 1}",
                                            key: ValueKey<int>(
                                                nodes.indexOf(node)),
                                            style: TextStyle(
                                              color: widget.activeNodeColor,
                                            ),
                                          ),
                              ),
                            );
                          })),
                  if (node.step != widget.steps - 1)
                    Container(
                      color: node.completed
                          ? widget.activeLineColor
                          : widget.inActiveLineColor,
                      height: widget.lineHeight,
                      width: widget.steps > 3
                          ? context.screenWidth(1 / widget.steps) - 40
                          : context.screenWidth(1 / widget.steps) - 28,
                    ),
                  if (nodes.indexOf(node) == widget.steps - 1) ...{
                    Container(
                      color: node.completed
                          ? widget.activeLineColor
                          : widget.inActiveLineColor,
                      height: widget.lineHeight,
                      width: context.screenWidth(1 / widget.steps) * .25,
                    ),
                  },
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
