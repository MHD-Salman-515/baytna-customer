import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/core/widgets/page_scaffold.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker_query.dart';
import 'package:baytna_customer/features/workers/presentation/bloc/browse/browse_workers_bloc.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BrowseWorkersScreen extends StatelessWidget {
  const BrowseWorkersScreen({required this.serviceId, this.cityId, super.key});

  final String serviceId;
  final String? cityId;

  @override
  Widget build(BuildContext context) {
    final user = switch (context.read<AuthBloc>().state) {
      AuthAuthenticated(:final user) => user,
      AuthUnknown() || AuthUnauthenticated() => null,
    };
    return BlocProvider(
      create: (_) => getIt<BrowseWorkersBloc>()
        ..add(BrowseStarted(
          countryId: user?.countryId ?? '',
          serviceId: serviceId,
          cityId: cityId,
          homeCityId: user?.cityId,
        )),
      child: PageScaffold(
        appBarTitle: context.l10n.browseTitle,
        title: context.l10n.browseTitle,
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseWorkersBloc, BrowseWorkersState>(
      builder: (context, state) {
        if (state.cities.isEmpty) {
          return switch (state.status) {
            BrowseStatus.loading => const Center(child: CircularProgressIndicator()),
            BrowseStatus.failure => FailureView(failure: state.failure!, onRetry: () => _restart(context)),
            BrowseStatus.loaded => Center(child: Text(context.l10n.browseNoCities)),
          };
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Filters(),
            const SizedBox(height: 16),
            Expanded(
              child: switch (state.status) {
                BrowseStatus.loading => const Center(child: CircularProgressIndicator()),
                BrowseStatus.failure => FailureView(
                  failure: state.failure!,
                  onRetry: () => context.read<BrowseWorkersBloc>().add(const BrowseQueryChanged()),
                ),
                BrowseStatus.loaded when state.workers.isEmpty => _Empty(cityName: _cityName(context, state)),
                BrowseStatus.loaded => _List(state: state),
              },
            ),
          ],
        );
      },
    );
  }

  void _restart(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<BrowseWorkersScreen>()!;
    final user = context.read<AuthBloc>().state;
    if (user is! AuthAuthenticated) return;
    context.read<BrowseWorkersBloc>().add(BrowseStarted(
      countryId: user.user.countryId,
      serviceId: screen.serviceId,
      cityId: screen.cityId,
      homeCityId: user.user.cityId,
    ));
  }
}

String _cityName(BuildContext context, BrowseWorkersState state) {
  final city = state.city;
  return city == null ? '' : context.localize(city.name);
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<BrowseWorkersBloc>().state;
    final bloc = context.read<BrowseWorkersBloc>();
    final sort = state.query?.sort ?? WorkerSort.ratingDesc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: const ValueKey('city-picker'),
          initialValue: state.query?.cityId,
          decoration: InputDecoration(
            labelText: l10n.browseCity,
            prefixIcon: const Icon(Icons.location_city_rounded),
          ),
          items: [
            for (final c in state.cities)
              DropdownMenuItem(value: c.id, child: Text(context.localize(c.name))),
          ],
          onChanged: (id) => bloc.add(BrowseQueryChanged(cityId: id)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final (option, label) in [
              (WorkerSort.ratingDesc, l10n.browseSortRating),
              (WorkerSort.priceAsc, l10n.browseSortPriceAsc),
              (WorkerSort.priceDesc, l10n.browseSortPriceDesc),
            ])
              ChoiceChip(
                key: ValueKey('sort-${option.name}'),
                label: Text(label),
                selected: sort == option,
                onSelected: (_) => bloc.add(BrowseQueryChanged(sort: option)),
              ),
          ],
        ),
      ],
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.state});

  final BrowseWorkersState state;

  @override
  Widget build(BuildContext context) {
    final query = state.query!;
    final cityName = _cityName(context, state);
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) {
          context.read<BrowseWorkersBloc>().add(const BrowseNextPageRequested());
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async => context.read<BrowseWorkersBloc>().add(const BrowseQueryChanged()),
        child: ListView.separated(
          itemCount: state.workers.length + (state.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == state.workers.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final worker = state.workers[i];
            return WorkerCard(
              worker: worker,
              serviceId: query.serviceId,
              cityName: cityName,
              onTap: () => context.push(
                AppRoutes.workerFor(worker.id, serviceId: query.serviceId, cityId: query.cityId),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Today there may be one bookable worker, or none in her city: say so
/// plainly and point at the city picker, rather than showing a blank list.
class _Empty extends StatelessWidget {
  const _Empty({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        key: const ValueKey('workers-empty'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, size: 56, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            context.l10n.browseEmpty(cityName),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.browseEmptyHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
