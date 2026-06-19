import 'package:flutter/material.dart';

import '../../runtime/alert_relay.dart';
import '../../runtime/backend_bus.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../access/crew_access_screen.dart';
import 'converter_view.dart';
import 'e6b_air_view.dart';
import 'nav_log_view.dart';
import 'weight_balance_view.dart';
import 'wind_solver_view.dart';

class ComputeConsoleShell extends StatefulWidget {
  const ComputeConsoleShell({super.key});

  @override
  State<ComputeConsoleShell> createState() => _ComputeConsoleShellState();
}

class _ComputeConsoleShellState extends State<ComputeConsoleShell> {
  int _tab = 0;

  static const _titles = [
    'E6B / AIR DATA',
    'WIND',
    'NAV / FUEL',
    'WEIGHT & BALANCE',
    'CONVERT / METAR',
  ];

  void _openAccount() {
    final signedIn = BackendBus.signedIn;
    showModalBottomSheet(
      context: context,
      backgroundColor: BezelPalette.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CREW', style: BezelType.label()),
                const SizedBox(height: 8),
                Text(
                  signedIn
                      ? (BackendBus.currentUser?.email ?? 'Signed in')
                      : 'Computing as a guest.',
                  style: BezelType.bodyStrong(),
                ),
                const SizedBox(height: 16),
                if (signedIn)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded,
                        color: BezelPalette.alert),
                    title: Text('Sign out',
                        style: BezelType.bodyStrong(color: BezelPalette.alert)),
                    onTap: () async {
                      await AlertRelay.unbindCrew();
                      await BackendBus.signOut();
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      if (mounted) setState(() {});
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.login_rounded,
                        color: BezelPalette.amber),
                    title: Text('Sign in or create account',
                        style: BezelType.bodyStrong(color: BezelPalette.amber)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CrewAccessScreen(
                            onDone: () {
                              Navigator.of(context).maybePop();
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_tab) {
      case 0:
        body = const E6bAirView();
        break;
      case 1:
        body = const WindSolverView();
        break;
      case 2:
        body = const NavLogView();
        break;
      case 3:
        body = const WeightBalanceView();
        break;
      case 4:
        body = const ConverterView();
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: BezelPalette.base,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(_titles[_tab],
            style: BezelType.engraved(14, color: BezelPalette.engrave)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            color: BezelPalette.engraveSoft,
            onPressed: _openAccount,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: body,
      bottomNavigationBar: _ConsoleBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _ConsoleBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _ConsoleBar({required this.index, required this.onChanged});

  static const _items = [
    (Icons.speed_rounded, 'AIR'),
    (Icons.air_rounded, 'WIND'),
    (Icons.route_rounded, 'NAV'),
    (Icons.balance_rounded, 'W&B'),
    (Icons.swap_horiz_rounded, 'CONV'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BezelPalette.baseDeep,
        border: Border(top: BorderSide(color: BezelPalette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == index;
              final item = _items[i];
              return Expanded(
                child: InkResponse(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: 22,
                        color: selected
                            ? BezelPalette.amber
                            : BezelPalette.engraveFaint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: BezelType.caption(
                          color: selected
                              ? BezelPalette.amber
                              : BezelPalette.engraveFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
