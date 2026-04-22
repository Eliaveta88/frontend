import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../network/api_services/catalog_api_service.dart';
import '../network/dio_error_mapper.dart';
import '../routing/route_names.dart';
import '../../features/catalog/data/catalog_models.dart';

/// Поиск в шапке: автодополнение каталога (debounce) и переход к карточке товара.
class CatalogGlobalSearchBar extends ConsumerStatefulWidget {
  const CatalogGlobalSearchBar({super.key, this.width});

  final double? width;

  @override
  ConsumerState<CatalogGlobalSearchBar> createState() => _CatalogGlobalSearchBarState();
}

class _CatalogGlobalSearchBarState extends ConsumerState<CatalogGlobalSearchBar> {
  final SearchController _controller = SearchController();
  Timer? _debounce;
  List<CatalogAutocompleteItem> _options = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    final q = _controller.text.trim();
    if (q.length < 2) {
      setState(() {
        _options = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final items = await ref.read(catalogApiServiceProvider).autocomplete(q, limit: 12);
        if (!mounted) return;
        setState(() {
          _options = items;
          _loading = false;
          _error = null;
        });
        if (items.isNotEmpty) {
          _controller.openView();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _options = [];
          _loading = false;
          _error = dioErrorMessage(e);
        });
        _controller.openView();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.width,
      child: SearchAnchor(
        searchController: _controller,
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            hintText: 'Поиск по каталогу…',
            leading: Icon(Icons.search, color: colors.onSurfaceVariant),
            trailing: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    setState(() => _options = []);
                  },
                ),
            ],
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
            onTap: () => controller.openView(),
            onChanged: (_) => controller.openView(),
            onSubmitted: (value) {
              final t = value.trim();
              if (t.length >= 2 && _options.isNotEmpty) {
                final first = _options.first;
                controller.closeView('');
                context.go('${Routes.catalog}/${first.id}');
              } else {
                controller.closeView('');
                context.go(Routes.catalog);
              }
            },
          );
        },
        suggestionsBuilder: (context, controller) {
          if (_loading) {
            return [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
            ];
          }
          if (controller.text.trim().length < 2) {
            return [
              const ListTile(
                title: Text('Введите не менее 2 символов'),
                dense: true,
              ),
            ];
          }
          if (_error != null) {
            return [
              ListTile(
                leading: Icon(Icons.error_outline, color: colors.error),
                title: const Text('Ошибка автодополнения'),
                subtitle: Text(_error!),
                dense: true,
                onTap: _onQueryChanged,
              ),
            ];
          }
          if (_options.isEmpty) {
            return [
              const ListTile(
                title: Text('Ничего не найдено'),
                dense: true,
              ),
            ];
          }
          return _options
              .map(
                (e) => ListTile(
                  title: Text(e.name),
                  dense: true,
                  onTap: () {
                    controller.closeView('');
                    context.go('${Routes.catalog}/${e.id}');
                  },
                ),
              )
              .toList();
        },
      ),
    );
  }
}
