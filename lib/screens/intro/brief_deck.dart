import 'package:flutter/material.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_dial.dart';
import '../../widgets/compute_button.dart';

class _Panel {
  final IconData icon;
  final String title;
  final String body;
  const _Panel(this.icon, this.title, this.body);
}

class BriefDeck extends StatefulWidget {
  final VoidCallback onDone;
  const BriefDeck({super.key, required this.onDone});

  @override
  State<BriefDeck> createState() => _BriefDeckState();
}

class _BriefDeckState extends State<BriefDeck> {
  final _controller = PageController();
  int _index = 0;

  static const _panels = [
    _Panel(Icons.speed_rounded, 'The wheel, computed',
        'Spin the bezel like a paper E6B, but let the computer solve true airspeed, density altitude and Mach in an instant — no slipping scales.'),
    _Panel(Icons.air_rounded, 'Wind, solved',
        'Enter course, true airspeed and the wind, and read off wind correction angle, ground speed and the head and crosswind components.'),
    _Panel(Icons.balance_rounded, 'Weight and balance',
        'Build a profile for your aircraft with real station arms, load it up, and check the centre of gravity stays inside the envelope.'),
    _Panel(Icons.cloud_outlined, 'Plain-language weather',
        'Paste a raw METAR or TAF and read wind, visibility, cloud, temperature and pressure decoded into clear words.'),
  ];

  bool get _last => _index == _panels.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BezelPalette.consoleGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: AnimatedOpacity(
                    opacity: _last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: EngraveLink(
                      label: 'SKIP',
                      onPressed: _last ? null : widget.onDone,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _panels.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _panels[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BezelDial(
                            size: 168,
                            child: Icon(p.icon,
                                size: 54, color: BezelPalette.amber),
                          ),
                          const SizedBox(height: 40),
                          Text(p.title,
                              style: BezelType.title(),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          Text(p.body,
                              style: BezelType.body(),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_panels.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? BezelPalette.amber : BezelPalette.hairline,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 24, 30, 28),
                child: ComputeButton(
                  label: _last ? 'OPEN THE PANEL' : 'NEXT',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
