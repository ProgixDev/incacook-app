import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/services/map/mapbox_search_client.dart';
import 'package:incacook/core/services/map/models/place_suggestion.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class AddressSearchSheet extends StatefulWidget {
  const AddressSearchSheet({super.key});

  @override
  State<AddressSearchSheet> createState() => _AddressSearchSheetState();
}

class _AddressSearchSheetState extends State<AddressSearchSheet> {
  static const Duration _debounce = Duration(milliseconds: 350);

  final TextEditingController _controller = TextEditingController();
  final MapboxSearchClient _client = Get.find<MapboxSearchClient>();
  late final String _sessionToken = _client.newSessionToken();

  Timer? _debounceTimer;
  int _queryGen = 0;
  List<PlaceSuggestion> _suggestions = const [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    _debounceTimer = Timer(_debounce, () => _runSuggest(value));
  }

  Future<void> _runSuggest(String query) async {
    final gen = ++_queryGen;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _client.suggest(
        query: query,
        sessionToken: _sessionToken,
        language: 'fr',
        country: 'FR',
      );
      if (gen != _queryGen || !mounted) return;
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    } catch (_) {
      if (gen != _queryGen || !mounted) return;
      setState(() {
        _loading = false;
        _error = 'Recherche indisponible';
      });
    }
  }

  Future<void> _onPick(PlaceSuggestion suggestion) async {
    setState(() => _loading = true);
    try {
      final place = await _client.retrieve(
        mapboxId: suggestion.mapboxId,
        sessionToken: _sessionToken,
      );
      if (!mounted) return;

      // Parse a structured Address out of the Mapbox formatted string.
      // The street part is `place.name`; the postal/city are extracted
      // from the formatted full address (5-digit FR postal regex).
      final formatted = place.fullAddress ?? place.placeFormatted;
      final postalMatch = RegExp(r'\b(\d{5})\b').firstMatch(formatted);
      final postal = postalMatch?.group(1) ?? '';
      // City sits between the postal and the country segment, e.g.
      // "12 rue X, 75011 Paris, France" → "Paris".
      final segments = formatted.split(',').map((s) => s.trim()).toList();
      final cityFromFormatted = segments
          .firstWhere(
            (s) => s.startsWith(postal) && postal.isNotEmpty,
            orElse: () => '',
          )
          .replaceFirst(postal, '')
          .trim();

      Navigator.of(context).pop(
        Address(
          id: 'mb-${place.mapboxId}',
          type: SavedAddressType.other,
          fullAddress: place.name,
          city: cityFromFormatted,
          postalCode: postal,
          coordinate: place.coordinate,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Adresse introuvable';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.md,
          right: AppSizes.md,
          top: AppSizes.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FrostedSurface(
              borderRadius: BorderRadius.circular(48),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: 'Chercher une adresse',
                  prefixIcon: Icon(Iconsax.search_normal, color: scheme.primary),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const Gap(AppSizes.md),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                child: Center(
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = _suggestions[i];
                    return ListTile(
                      leading: Icon(Iconsax.location, color: scheme.primary),
                      title: Text(s.name),
                      subtitle: Text(
                        s.placeFormatted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _onPick(s),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
