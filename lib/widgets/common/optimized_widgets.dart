import 'package:flutter/material.dart';

/// Optimized container with const constructor and RepaintBoundary
class OptimizedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final bool useRepaintBoundary;

  const OptimizedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.useRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );

    if (useRepaintBoundary) {
      container = RepaintBoundary(child: container);
    }

    return container;
  }
}

/// Optimized card with const constructor and RepaintBoundary
class OptimizedCard extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final bool useRepaintBoundary;

  const OptimizedCard({
    super.key,
    this.child,
    this.color,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.margin,
    this.clipBehavior,
    this.useRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      color: color,
      shadowColor: shadowColor,
      elevation: elevation,
      shape: shape,
      margin: margin,
      clipBehavior: clipBehavior,
      child: child,
    );

    if (useRepaintBoundary) {
      card = RepaintBoundary(child: card);
    }

    return card;
  }
}

/// Optimized list tile with const constructor
class OptimizedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final Color? selectedTileColor;
  final Color? tileColor;
  final bool useRepaintBoundary;

  const OptimizedListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.selectedTileColor,
    this.tileColor,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      selected: selected,
      selectedTileColor: selectedTileColor,
      tileColor: tileColor,
    );

    if (useRepaintBoundary) {
      tile = RepaintBoundary(child: tile);
    }

    return tile;
  }
}

/// Optimized text widget with const constructor
class OptimizedText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final bool useRepaintBoundary;

  const OptimizedText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      data,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );

    if (useRepaintBoundary) {
      text = RepaintBoundary(child: text);
    }

    return text;
  }
}

/// Optimized icon widget with const constructor
class OptimizedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final bool useRepaintBoundary;

  const OptimizedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      key: key,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );

    if (useRepaintBoundary) {
      iconWidget = RepaintBoundary(child: iconWidget);
    }

    return iconWidget;
  }
}

/// Optimized button with const constructor
class OptimizedElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget? child;
  final bool useRepaintBoundary;

  const OptimizedElevatedButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.child,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child,
    );

    if (useRepaintBoundary) {
      button = RepaintBoundary(child: button);
    }

    return button;
  }
}

/// Optimized divider with const constructor
class OptimizedDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;
  final bool useRepaintBoundary;

  const OptimizedDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget divider = Divider(
      key: key,
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );

    if (useRepaintBoundary) {
      divider = RepaintBoundary(child: divider);
    }

    return divider;
  }
}

/// Optimized sized box with const constructor
class OptimizedSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final bool useRepaintBoundary;

  const OptimizedSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget sizedBox = SizedBox(
      key: key,
      width: width,
      height: height,
      child: child,
    );

    if (useRepaintBoundary) {
      sizedBox = RepaintBoundary(child: sizedBox);
    }

    return sizedBox;
  }
}

/// Optimized padding with const constructor
class OptimizedPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget? child;
  final bool useRepaintBoundary;

  const OptimizedPadding({
    super.key,
    required this.padding,
    this.child,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget paddingWidget = Padding(
      key: key,
      padding: padding,
      child: child,
    );

    if (useRepaintBoundary) {
      paddingWidget = RepaintBoundary(child: paddingWidget);
    }

    return paddingWidget;
  }
}
