import 'package:flutter/material.dart';

/// Crisp Vector Icons for Video365 matching the reference UI perfectly.
/// Fully self-contained, high-performance, and responsive across any DPI.
class Video365Icon extends StatelessWidget {
  final Video365IconType type;
  final double size;
  final Color color;

  const Video365Icon(
    this.type, {
    super.key,
    this.size = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _Video365IconPainter(type, color),
    );
  }
}

enum Video365IconType {
  play,
  pause,
  prevFrame,
  nextFrame,
  export,
  undo,
  redo,
  trim,
  split,
  text,
  audio,
  mic,
  filter,
  effects,
  speed,
  crop,
  stickers,
  layers,
  fullscreen,
  aspectRatio,
  close,
  check,
  add,
  radialMenu,
  volume,
  volumeMute,
  music,
}

class _Video365IconPainter extends CustomPainter {
  final Video365IconType type;
  final Color color;

  _Video365IconPainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = (size.width * 0.09).clamp(1.5, 2.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case Video365IconType.play:
        final path = Path()
          ..moveTo(w * 0.28, h * 0.18)
          ..lineTo(w * 0.82, h * 0.5)
          ..lineTo(w * 0.28, h * 0.82)
          ..close();
        canvas.drawPath(path, fillPaint);
        break;

      case Video365IconType.pause:
        final barW = w * 0.22;
        final barH = h * 0.65;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.22, (h - barH) / 2, barW, barH),
            Radius.circular(w * 0.08),
          ),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.56, (h - barH) / 2, barW, barH),
            Radius.circular(w * 0.08),
          ),
          fillPaint,
        );
        break;

      case Video365IconType.export:
        // Tray
        final tray = Path()
          ..moveTo(w * 0.15, h * 0.65)
          ..lineTo(w * 0.15, h * 0.85)
          ..lineTo(w * 0.85, h * 0.85)
          ..lineTo(w * 0.85, h * 0.65);
        canvas.drawPath(tray, strokePaint);
        // Arrow pointing up
        canvas.drawLine(Offset(w * 0.5, h * 0.68), Offset(w * 0.5, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.28, h * 0.35), Offset(w * 0.5, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.72, h * 0.35), Offset(w * 0.5, h * 0.15), strokePaint);
        break;

      case Video365IconType.undo:
        final arc = Path()
          ..moveTo(w * 0.8, h * 0.75)
          ..cubicTo(w * 0.8, h * 0.35, w * 0.35, h * 0.35, w * 0.25, h * 0.5);
        canvas.drawPath(arc, strokePaint);
        canvas.drawLine(Offset(w * 0.45, h * 0.32), Offset(w * 0.22, h * 0.5), strokePaint);
        canvas.drawLine(Offset(w * 0.45, h * 0.68), Offset(w * 0.22, h * 0.5), strokePaint);
        break;

      case Video365IconType.redo:
        final arc = Path()
          ..moveTo(w * 0.2, h * 0.75)
          ..cubicTo(w * 0.2, h * 0.35, w * 0.65, h * 0.35, w * 0.75, h * 0.5);
        canvas.drawPath(arc, strokePaint);
        canvas.drawLine(Offset(w * 0.55, h * 0.32), Offset(w * 0.78, h * 0.5), strokePaint);
        canvas.drawLine(Offset(w * 0.55, h * 0.68), Offset(w * 0.78, h * 0.5), strokePaint);
        break;

      case Video365IconType.trim:
        // Left bracket < and right bracket >
        canvas.drawLine(Offset(w * 0.38, h * 0.25), Offset(w * 0.18, h * 0.5), strokePaint);
        canvas.drawLine(Offset(w * 0.18, h * 0.5), Offset(w * 0.38, h * 0.75), strokePaint);
        canvas.drawLine(Offset(w * 0.62, h * 0.25), Offset(w * 0.82, h * 0.5), strokePaint);
        canvas.drawLine(Offset(w * 0.82, h * 0.5), Offset(w * 0.62, h * 0.75), strokePaint);
        break;

      case Video365IconType.split:
        // Pair of scissors / slice mark
        canvas.drawCircle(Offset(w * 0.3, h * 0.72), w * 0.15, strokePaint);
        canvas.drawCircle(Offset(w * 0.7, h * 0.72), w * 0.15, strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.6), Offset(w * 0.75, h * 0.2), strokePaint);
        canvas.drawLine(Offset(w * 0.65, h * 0.6), Offset(w * 0.25, h * 0.2), strokePaint);
        break;

      case Video365IconType.text:
        // Elegant TT font icon
        canvas.drawLine(Offset(w * 0.15, h * 0.22), Offset(w * 0.65, h * 0.22), strokePaint);
        canvas.drawLine(Offset(w * 0.4, h * 0.22), Offset(w * 0.4, h * 0.82), strokePaint);
        canvas.drawLine(Offset(w * 0.6, h * 0.45), Offset(w * 0.9, h * 0.45), strokePaint);
        canvas.drawLine(Offset(w * 0.75, h * 0.45), Offset(w * 0.75, h * 0.82), strokePaint);
        break;

      case Video365IconType.audio:
      case Video365IconType.music:
        // Musical note
        final note = Path()
          ..moveTo(w * 0.35, h * 0.7)
          ..addOval(Rect.fromLTWH(w * 0.15, h * 0.6, w * 0.28, h * 0.25))
          ..moveTo(w * 0.43, h * 0.68)
          ..lineTo(w * 0.43, h * 0.25)
          ..lineTo(w * 0.82, h * 0.15)
          ..lineTo(w * 0.82, h * 0.55)
          ..addOval(Rect.fromLTWH(w * 0.55, h * 0.5, w * 0.28, h * 0.25));
        canvas.drawPath(note, strokePaint);
        canvas.drawLine(Offset(w * 0.43, h * 0.25), Offset(w * 0.82, h * 0.15), strokePaint);
        break;

      case Video365IconType.mic:
        // Microphone
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.35, h * 0.15, w * 0.3, h * 0.45),
            Radius.circular(w * 0.15),
          ),
          strokePaint,
        );
        final cup = Path()
          ..moveTo(w * 0.22, h * 0.42)
          ..lineTo(w * 0.22, h * 0.52)
          ..cubicTo(w * 0.22, h * 0.75, w * 0.78, h * 0.75, w * 0.78, h * 0.52)
          ..lineTo(w * 0.78, h * 0.42);
        canvas.drawPath(cup, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.75), Offset(w * 0.5, h * 0.9), strokePaint);
        canvas.drawLine(Offset(w * 0.32, h * 0.9), Offset(w * 0.68, h * 0.9), strokePaint);
        break;

      case Video365IconType.filter:
        // Three sliders / adjustment knobs
        canvas.drawLine(Offset(w * 0.2, h * 0.15), Offset(w * 0.2, h * 0.85), strokePaint);
        canvas.drawCircle(Offset(w * 0.2, h * 0.4), w * 0.12, fillPaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.85), strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.65), w * 0.12, fillPaint);
        canvas.drawLine(Offset(w * 0.8, h * 0.15), Offset(w * 0.8, h * 0.85), strokePaint);
        canvas.drawCircle(Offset(w * 0.8, h * 0.35), w * 0.12, fillPaint);
        break;

      case Video365IconType.effects:
        // Lightning bolt / Magic FX
        final bolt = Path()
          ..moveTo(w * 0.55, h * 0.1)
          ..lineTo(w * 0.25, h * 0.55)
          ..lineTo(w * 0.5, h * 0.55)
          ..lineTo(w * 0.45, h * 0.9)
          ..lineTo(w * 0.75, h * 0.45)
          ..lineTo(w * 0.5, h * 0.45)
          ..close();
        canvas.drawPath(bolt, fillPaint);
        break;

      case Video365IconType.speed:
        // Stopwatch / Speedometer
        canvas.drawCircle(Offset(w * 0.5, h * 0.55), w * 0.38, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.7, h * 0.4), strokePaint);
        canvas.drawLine(Offset(w * 0.4, h * 0.1), Offset(w * 0.6, h * 0.1), strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.18), strokePaint);
        break;

      case Video365IconType.crop:
        canvas.drawLine(Offset(w * 0.25, h * 0.1), Offset(w * 0.25, h * 0.75), strokePaint);
        canvas.drawLine(Offset(w * 0.25, h * 0.75), Offset(w * 0.9, h * 0.75), strokePaint);
        canvas.drawLine(Offset(w * 0.1, h * 0.25), Offset(w * 0.75, h * 0.25), strokePaint);
        canvas.drawLine(Offset(w * 0.75, h * 0.25), Offset(w * 0.75, h * 0.9), strokePaint);
        break;

      case Video365IconType.stickers:
        // Sticker smiling face badge
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, strokePaint);
        canvas.drawCircle(Offset(w * 0.38, h * 0.42), w * 0.05, fillPaint);
        canvas.drawCircle(Offset(w * 0.62, h * 0.42), w * 0.05, fillPaint);
        final smile = Path()
          ..moveTo(w * 0.35, h * 0.6)
          ..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.65, h * 0.6);
        canvas.drawPath(smile, strokePaint);
        break;

      case Video365IconType.layers:
        // Three overlapping layer diamond cards
        final card1 = Path()
          ..moveTo(w * 0.5, h * 0.15)
          ..lineTo(w * 0.85, h * 0.32)
          ..lineTo(w * 0.5, h * 0.49)
          ..lineTo(w * 0.15, h * 0.32)
          ..close();
        canvas.drawPath(card1, strokePaint);
        final card2 = Path()
          ..moveTo(w * 0.18, h * 0.52)
          ..lineTo(w * 0.5, h * 0.68)
          ..lineTo(w * 0.82, h * 0.52);
        canvas.drawPath(card2, strokePaint);
        final card3 = Path()
          ..moveTo(w * 0.18, h * 0.72)
          ..lineTo(w * 0.5, h * 0.88)
          ..lineTo(w * 0.82, h * 0.72);
        canvas.drawPath(card3, strokePaint);
        break;

      case Video365IconType.fullscreen:
        // 4 Expand corner arrows
        canvas.drawLine(Offset(w * 0.15, h * 0.35), Offset(w * 0.15, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.15, h * 0.15), Offset(w * 0.35, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.35), Offset(w * 0.85, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.15), Offset(w * 0.65, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.15, h * 0.65), Offset(w * 0.15, h * 0.85), strokePaint);
        canvas.drawLine(Offset(w * 0.15, h * 0.85), Offset(w * 0.35, h * 0.85), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.65), Offset(w * 0.85, h * 0.85), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.85), Offset(w * 0.65, h * 0.85), strokePaint);
        break;

      case Video365IconType.aspectRatio:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.2, h * 0.12, w * 0.6, h * 0.76),
            Radius.circular(w * 0.1),
          ),
          strokePaint,
        );
        break;

      case Video365IconType.close:
        canvas.drawLine(Offset(w * 0.22, h * 0.22), Offset(w * 0.78, h * 0.78), strokePaint);
        canvas.drawLine(Offset(w * 0.78, h * 0.22), Offset(w * 0.22, h * 0.78), strokePaint);
        break;

      case Video365IconType.check:
        canvas.drawLine(Offset(w * 0.2, h * 0.52), Offset(w * 0.42, h * 0.75), strokePaint);
        canvas.drawLine(Offset(w * 0.42, h * 0.75), Offset(w * 0.82, h * 0.25), strokePaint);
        break;

      case Video365IconType.add:
        canvas.drawLine(Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.8), strokePaint);
        canvas.drawLine(Offset(w * 0.2, h * 0.5), Offset(w * 0.8, h * 0.5), strokePaint);
        break;

      case Video365IconType.prevFrame:
        canvas.drawLine(Offset(w * 0.2, h * 0.2), Offset(w * 0.2, h * 0.8), strokePaint);
        final tri = Path()
          ..moveTo(w * 0.75, h * 0.2)
          ..lineTo(w * 0.35, h * 0.5)
          ..lineTo(w * 0.75, h * 0.8)
          ..close();
        canvas.drawPath(tri, fillPaint);
        break;

      case Video365IconType.nextFrame:
        canvas.drawLine(Offset(w * 0.8, h * 0.2), Offset(w * 0.8, h * 0.8), strokePaint);
        final tri2 = Path()
          ..moveTo(w * 0.25, h * 0.2)
          ..lineTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.25, h * 0.8)
          ..close();
        canvas.drawPath(tri2, fillPaint);
        break;

      case Video365IconType.volume:
        final horn = Path()
          ..moveTo(w * 0.15, h * 0.38)
          ..lineTo(w * 0.32, h * 0.38)
          ..lineTo(w * 0.55, h * 0.18)
          ..lineTo(w * 0.55, h * 0.82)
          ..lineTo(w * 0.32, h * 0.62)
          ..lineTo(w * 0.15, h * 0.62)
          ..close();
        canvas.drawPath(horn, fillPaint);
        final wave = Path()
          ..moveTo(w * 0.68, h * 0.32)
          ..quadraticBezierTo(w * 0.82, h * 0.5, w * 0.68, h * 0.68);
        canvas.drawPath(wave, strokePaint);
        break;

      case Video365IconType.volumeMute:
        final hornMute = Path()
          ..moveTo(w * 0.15, h * 0.38)
          ..lineTo(w * 0.32, h * 0.38)
          ..lineTo(w * 0.55, h * 0.18)
          ..lineTo(w * 0.55, h * 0.82)
          ..lineTo(w * 0.32, h * 0.62)
          ..lineTo(w * 0.15, h * 0.62)
          ..close();
        canvas.drawPath(hornMute, fillPaint);
        canvas.drawLine(Offset(w * 0.68, h * 0.38), Offset(w * 0.88, h * 0.62), strokePaint);
        canvas.drawLine(Offset(w * 0.88, h * 0.38), Offset(w * 0.68, h * 0.62), strokePaint);
        break;

      case Video365IconType.radialMenu:
        // Stylized circular concentric ring
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.4, strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.18, fillPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _Video365IconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
