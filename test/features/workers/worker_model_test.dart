import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/data/models/worker_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/staging_fixtures.dart';

void main() {
  test('decodes the real public projection', () {
    final w = WorkerModel.fromJson(StagingFixtures.worker);
    expect(w.id, StagingFixtures.workerId);
    expect(w.bio.ar, startsWith('خبرة'));
    expect(w.serviceAreas, contains(StagingFixtures.damascusId));
    final o = w.offeringFor(StagingFixtures.cleaningId)!;
    expect(o.pricingType, PricingType.hourly);
    expect(o.displayPrice, 6000);
    expect(o.currency, 'SYP');
  });

  test('the backend placeholder name "Worker" counts as no name', () {
    expect(WorkerModel.fromJson(StagingFixtures.worker).displayName, isNull);
    expect(WorkerModel.fromJson({...StagingFixtures.worker, 'displayName': '  '}).displayName, isNull);
    expect(WorkerModel.fromJson({...StagingFixtures.worker, 'displayName': 'سعاد'}).displayName, 'سعاد');
  });

  test('rating 0 means no reviews yet', () {
    expect(WorkerModel.fromJson(StagingFixtures.worker).hasRating, isFalse);
    expect(WorkerModel.fromJson({...StagingFixtures.worker, 'rating': 4.5}).hasRating, isTrue);
  });

  test('a non-HTTPS photo URL is dropped', () {
    expect(
      WorkerModel.fromJson({...StagingFixtures.worker, 'profilePhotoUrl': 'http://x/p.jpg'}).photoUrl,
      isNull,
    );
    expect(
      WorkerModel.fromJson({...StagingFixtures.worker, 'profilePhotoUrl': 'https://x/p.jpg'}).photoUrl,
      'https://x/p.jpg',
    );
  });

  test('workerServiceId: read from the payload once the backend sends it', () {
    final today = WorkerModel.fromJson(StagingFixtures.worker).offerings.single;
    // Tests run without DEV_WORKER_SERVICES, exactly like a release build.
    expect(today.workerServiceId, isNull);
    expect(today.isBookable, isFalse);

    final fixed = WorkerModel.fromJson({
      ...StagingFixtures.worker,
      'services': [
        {...(StagingFixtures.worker['services']! as List).first as Map<String, dynamic>, 'workerServiceId': 'ws1'},
      ],
    }).offerings.single;
    expect(fixed.workerServiceId, 'ws1');
    expect(fixed.isBookable, isTrue);
  });
}
