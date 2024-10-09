import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:alchemy_web3/src/api/api.dart';
import 'package:test/test.dart';

const String _key = 'your_key';

void main() {
  group('Custom API', () {
    var api = _init();

    test('batch request', () async {
      await api.httpClient.batchRequest(requests: [
        {
          'method': 'eth_getTransactionByHash',
          'params': ["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"],
        },
        {
          'method': 'eth_blockNumber',
          'params': [],
        },
      ]).then((result) {
        expect(result.isRight, true);
      });
    });
  });
}

CustomApi _init() {
  var url = 'https://eth-mainnet.g.alchemy.com/v2/$_key';
  RpcHttpClient httpClient = RpcHttpClient();
  httpClient.init(
    url: url,
    verbose: true,
  );

  RpcWsClient wsClient = RpcWsClient();
  wsClient.init(
    url: url,
    verbose: true,
  );

  CustomApi api = CustomApi();
  api.setHttpClient(httpClient);
  api.setWsClient(wsClient);
  return api;
}
