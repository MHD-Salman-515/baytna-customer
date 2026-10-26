import 'package:baytna_customer/core/dev/dev_worker_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses "worker/service=workerService" pairs and ignores junk', () {
    expect(DevWorkerServices.parse('w1/s1=ws1; w2/s2 = ws2;;garbage;=x'), {
      'w1/s1': 'ws1',
      'w2/s2': 'ws2',
    });
    expect(DevWorkerServices.parse(''), isEmpty);
  });

  test('disabled unless the define is supplied', () {
    expect(DevWorkerServices.enabled, isFalse);
    expect(DevWorkerServices.lookup(workerId: 'w1', serviceId: 's1'), isNull);
  });
}
