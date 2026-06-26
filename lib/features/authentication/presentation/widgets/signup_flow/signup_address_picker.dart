import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/config/mapbox_config.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/address_mapping.dart';
import 'package:incacook/core/services/map/mapbox_search_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/services/map/models/place_suggestion.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

/// Address autocomplete backed by the Mapbox Search Box API (debounced
/// `suggest` → `retrieve` for real coordinates) plus a one-tap
/// "use my current location" that reverse-geocodes the device GPS fix.
class SignupAddressPicker extends StatefulWidget {
  const SignupAddressPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint = AppTexts.signupAddressSearchHint,
  });

  final Address? value;
  final ValueChanged<Address?> onChanged;
  final String hint;

  @override
  State<SignupAddressPicker> createState() => _SignupAddressPickerState();
}

class _SignupAddressPickerState extends State<SignupAddressPicker> {
  static const Duration _debounce = Duration(milliseconds: 350);

  final MapboxSearchClient _client = Get.find<MapboxSearchClient>();
  final LocationService _location = Get.find<LocationService>();
  late final TextEditingController _controller;
  // One session token per picker instance — Mapbox bills per search session
  // (suggest calls + the retrieve that closes it).
  late final String _sessionToken = _client.newSessionToken();

  Timer? _debounceTimer;
  int _queryGen = 0;
  List<PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.fullAddress ?? '');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChangedQuery(String q) {
    _debounceTimer?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _suggestions = const [];
        _searching = false;
        _error = null;
      });
      widget.onChanged(null);
      return;
    }
    _debounceTimer = Timer(_debounce, () => _runSuggest(q));
  }

  Future<void> _runSuggest(String query) async {
    final gen = ++_queryGen;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await _client.suggest(
        query: query,
        sessionToken: _sessionToken,
        language: 'fr',
      );
      if (gen != _queryGen || !mounted) return;
      // Float precise street addresses (which carry a postcode) above coarser
      // place/locality results, keeping Mapbox's relevance order within each
      // group. Places are still selectable — the backend allows no postcode.
      final ordered = [
        ...results.where((s) => s.featureType == 'address'),
        ...results.where((s) => s.featureType != 'address'),
      ];
      setState(() {
        _suggestions = ordered;
        _searching = false;
      });
    } catch (_) {
      if (gen != _queryGen || !mounted) return;
      setState(() {
        _searching = false;
        _error = AppTexts.signupAddressSearchError;
      });
    }
  }

  Future<void> _select(PlaceSuggestion suggestion) async {
    setState(() {
      _searching = true;
      _suggestions = const [];
      _error = null;
    });
    try {
      final place = await _client.retrieve(
        mapboxId: suggestion.mapboxId,
        sessionToken: _sessionToken,
      );
      if (!mounted) return;
      _commit(_addressFromPlace(place));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = AppTexts.signupAddressSearchError;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final pos = await _location.getCurrent();
      if (pos == null) {
        if (!mounted) return;
        setState(() {
          _locating = false;
          _error = AppTexts.signupAddressLocationDenied;
        });
        return;
      }
      final place = await _client.reverse(
        lat: pos.latitude,
        lng: pos.longitude,
        language: 'fr',
      );
      if (!mounted) return;
      _commit(_addressFromPlace(place));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _error = AppTexts.signupAddressLocationError;
      });
    }
  }

  /// Applies a chosen [address] to the field + parent, clearing transient UI.
  void _commit(Address address) {
    _controller.text = address.fullAddress;
    setState(() {
      _suggestions = const [];
      _searching = false;
      _locating = false;
    });
    widget.onChanged(address);
    FocusScope.of(context).unfocus();
  }

  /// Builds our [Address] from a Mapbox place. Delegates to the shared
  /// [addressFromRetrievedPlace] so the `fullAddress` always carries the WHOLE
  /// address (street + postal + city + country), never just the street.
  Address _addressFromPlace(RetrievedPlace place) =>
      addressFromRetrievedPlace(place);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignupTextField(
          controller: _controller,
          hint: widget.hint,
          leadingIcon: Iconsax.location,
          onChanged: _onChangedQuery,
          errorText: _error,
          trailing: _searching
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.sm + 4),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        const Gap(AppSizes.sm),
        // One-tap current-location fill (GPS → reverse geocode).
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _locating ? null : _useCurrentLocation,
            icon: _locating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Iconsax.gps, size: 18, color: scheme.primary),
            label: Text(
              _locating
                  ? AppTexts.signupAddressLocating
                  : AppTexts.signupAddressUseCurrentLocation,
            ),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const Gap(AppSizes.sm),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: _suggestions
                  .map(
                    (s) => InkWell(
                      onTap: () => _select(s),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLg,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.sm + 4),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.location,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                            const Gap(AppSizes.sm + 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: TextStyle(color: scheme.onSurface),
                                  ),
                                  if (s.placeFormatted.isNotEmpty)
                                    Text(
                                      s.placeFormatted,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (widget.value != null) ...[
          const Gap(AppSizes.sm + 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Static Mapbox preview centered on the picked coordinate.
                  // Falls back to the icon placeholder while loading / on error
                  // (or when a coordinate is somehow missing).
                  if (widget.value!.coordinate != null)
                    Image.network(
                      _staticMapUrl(
                        widget.value!.coordinate!,
                        dark: context.isDark,
                      ),
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) => progress == null
                          ? child
                          : _confirmedPlaceholder(scheme),
                      errorBuilder: (_, _, _) => _confirmedPlaceholder(scheme),
                    )
                  else
                    _confirmedPlaceholder(scheme),
                  // Confirmation chip pinned bottom-left over the map.
                  Positioned(
                    left: AppSizes.sm,
                    bottom: AppSizes.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm + 2,
                        vertical: AppSizes.xs + 1,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.location_tick,
                            color: scheme.primary,
                            size: 16,
                          ),
                          const Gap(AppSizes.xs + 2),
                          Text(
                            AppTexts.signupAddressConfirmed,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a Mapbox Static Images API URL: a [width]×140 map centered on
  /// [c] with a brand-green pin. Style follows light/dark mode.
  String _staticMapUrl(MapPoint c, {required bool dark, int width = 640}) {
    final style = dark ? 'dark-v11' : 'streets-v12';
    const pin = '00c263'; // BrandColors.primary
    const zoom = 15;
    return 'https://api.mapbox.com/styles/v1/mapbox/$style/static/'
        'pin-l+$pin(${c.lng},${c.lat})/'
        '${c.lng},${c.lat},$zoom/${width}x280@2x'
        '?access_token=${MapboxConfig.publicToken}';
  }

  /// Fallback tile shown while the static map loads or if it fails — the
  /// original icon + "Adresse confirmée" placeholder.
  Widget _confirmedPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.location_tick, color: scheme.primary, size: 32),
          const Gap(AppSizes.xs + 2),
          Text(
            AppTexts.signupAddressConfirmed,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
