import 'package:flutter/material.dart';

import '../../domain/aircraft_profiles.dart';
import '../../domain/craft_repository.dart';
import '../../state/craft_scope.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_card.dart';
import '../../widgets/compute_button.dart';
import '../../widgets/gauge_arc.dart';

class WeightBalanceView extends StatefulWidget {
  const WeightBalanceView({super.key});

  @override
  State<WeightBalanceView> createState() => _WeightBalanceViewState();
}

class _WeightBalanceViewState extends State<WeightBalanceView> {
  String? _selectedId;

  CraftProfile? _active(CraftRepository repo) {
    if (repo.profiles.isEmpty) return null;
    final id = _selectedId;
    return repo.byId(id ?? '') ?? repo.profiles.first;
  }

  Future<void> _addProfile(CraftRepository repo) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BezelPalette.panel,
        title: Text('NEW PROFILE', style: BezelType.label()),
        content: TextField(
          controller: ctrl,
          style: BezelType.bodyStrong(),
          decoration: const InputDecoration(hintText: 'Aircraft / registration'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: BezelType.label()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('ADD', style: BezelType.label(color: BezelPalette.amber)),
          ),
        ],
      ),
    );
    if (name != null) {
      final p = await repo.addProfile(name);
      setState(() => _selectedId = p.id);
    }
  }

  void _editField(
      CraftRepository repo, String label, double value, ValueChanged<double> set) {
    final ctrl = TextEditingController(text: value == 0 ? '' : value.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BezelPalette.panel,
        title: Text(label, style: BezelType.label()),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true, signed: true),
          style: BezelType.readout(18),
          decoration: const InputDecoration(hintText: '0'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              set(double.tryParse(ctrl.text.trim()) ?? 0);
              repo.save();
              Navigator.pop(ctx);
            },
            child: Text('SET', style: BezelType.label(color: BezelPalette.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = CraftScope.of(context);
    final profile = _active(repo);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
      children: [
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...repo.profiles.map((p) {
                final sel = p.id == profile?.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedId = p.id),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: sel ? BezelPalette.amber : BezelPalette.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: sel
                                ? BezelPalette.amber
                                : BezelPalette.hairline),
                      ),
                      child: Text(p.name,
                          style: BezelType.bodyStrong(
                              color: sel
                                  ? BezelPalette.baseDeep
                                  : BezelPalette.engrave)),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () => _addProfile(repo),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BezelPalette.hairline),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: BezelPalette.amber, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (profile == null)
          BezelCard(child: Text('No profile. Add one to begin.', style: BezelType.body()))
        else ...[
          _envelope(repo, profile),
          const SizedBox(height: 14),
          _basics(repo, profile),
          const SizedBox(height: 14),
          _stations(repo, profile),
          const SizedBox(height: 16),
          Text(
            'For training and pre-flight estimation only. Confirm limits with the aircraft flight manual.',
            style: BezelType.caption(),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _envelope(CraftRepository repo, CraftProfile p) {
    final ok = p.withinEnvelope;
    final color = ok ? BezelPalette.green : BezelPalette.alert;
    return BezelCard(
      color: ok ? BezelPalette.greenWash : BezelPalette.alertWash,
      border: Border.all(color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  color: color),
              const SizedBox(width: 10),
              Text(ok ? 'WITHIN ENVELOPE' : 'OUT OF ENVELOPE',
                  style: BezelType.engraved(13, color: color)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _cell('GROSS WEIGHT', p.totalWeight.toStringAsFixed(0), 'lb',
                  p.withinWeight ? BezelPalette.green : BezelPalette.alert)),
              Expanded(child: _cell('CG', p.cg.toStringAsFixed(2), 'in',
                  (p.cg >= p.cgForward && p.cg <= p.cgAft)
                      ? BezelPalette.green
                      : BezelPalette.alert)),
              Expanded(child: _cell('MOMENT', p.totalMoment.toStringAsFixed(0), '', BezelPalette.cyan)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, String value, String unit, Color tint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BezelType.label()),
        const SizedBox(height: 6),
        Text(value, style: BezelType.readout(19, color: tint)),
        if (unit.isNotEmpty)
          Text(unit, style: BezelType.caption()),
      ],
    );
  }

  Widget _basics(CraftRepository repo, CraftProfile p) {
    return BezelCard(
      child: Column(
        children: [
          _row(repo, 'EMPTY WEIGHT', '${p.emptyWeight.toStringAsFixed(0)} lb',
              () => _editField(repo, 'Empty weight (lb)', p.emptyWeight,
                  (v) => setState(() => p.emptyWeight = v))),
          _row(repo, 'EMPTY ARM', '${p.emptyArm.toStringAsFixed(1)} in',
              () => _editField(repo, 'Empty arm (in)', p.emptyArm,
                  (v) => setState(() => p.emptyArm = v))),
          _row(repo, 'MAX GROSS', '${p.maxWeight.toStringAsFixed(0)} lb',
              () => _editField(repo, 'Max gross (lb)', p.maxWeight,
                  (v) => setState(() => p.maxWeight = v))),
          _row(repo, 'CG FWD LIMIT', '${p.cgForward.toStringAsFixed(1)} in',
              () => _editField(repo, 'Forward CG (in)', p.cgForward,
                  (v) => setState(() => p.cgForward = v))),
          _row(repo, 'CG AFT LIMIT', '${p.cgAft.toStringAsFixed(1)} in',
              () => _editField(repo, 'Aft CG (in)', p.cgAft,
                  (v) => setState(() => p.cgAft = v)),
              last: true),
        ],
      ),
    );
  }

  Widget _stations(CraftRepository repo, CraftProfile p) {
    return BezelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LOADING STATIONS', style: BezelType.label()),
          const SizedBox(height: 6),
          ...p.stations.asMap().entries.map((e) {
            final st = e.value;
            return _row(
              repo,
              '${st.label}  ·  arm ${st.arm.toStringAsFixed(1)}',
              '${st.weight.toStringAsFixed(0)} lb',
              () => _editField(repo, '${st.label} weight (lb)', st.weight,
                  (v) => setState(() => st.weight = v)),
              last: e.key == p.stations.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _row(CraftRepository repo, String label, String value, VoidCallback onTap,
      {bool last = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: BezelPalette.hairline)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: BezelType.body())),
            Text(value, style: BezelType.readout(15)),
            const SizedBox(width: 8),
            const Icon(Icons.edit_rounded, size: 15, color: BezelPalette.engraveFaint),
          ],
        ),
      ),
    );
  }
}
