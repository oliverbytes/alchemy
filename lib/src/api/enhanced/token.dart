import 'package:either_dart/either.dart';

import '../../../alchemy_web3.dart';

class EnhancedTokenAPI with AlchemyConsoleMixin {
  late RpcWsClient wsClient;

  void setClient(RpcWsClient client) {
    wsClient = client;
  }

  // FUNCTIONS

  Future<Either<RPCErrorData, String>> getTokenAllowance({
    required String contract,
    required String owner,
    required String spender,
  }) async {
    final result = await wsClient.request(
      method: 'alchemy_getTokenAllowance',
      params: [
        {
          "contract": contract,
          "owner": owner,
          "spender": spender,
        }
      ],
    );

    return result.fold(
      (error) => Left(error),
      (response) => Right(response),
    );
  }

  Future<Either<RPCErrorData, EnhancedTokenBalances>> getTokenBalances({
    required String address,

    ///One of the following token specifications, defaults to erc20
    ///The String erc20 - denotes the set of erc20 tokens that the address has ever held.
    ///The String DEFAULT_TOKENS(DEPRECATED) - denotes a query for the top 100 tokens by 24 hour volume - only available on Mainnet for Ethereum, Polygon, and Arbitrum. [deprecated, please use erc20 instead]
    ///           DEFAULT_TOKENS was used to fetch the top 100 tokens by volume and show their balances for a given address.
    ///Array - A list of contract addresses
    ///
    dynamic tokensSpecification = 'DEFAULT_TOKENS',
    List<String> contractAddresses = const [],

    ///pageKey: Applies only to the erc20 request type. A string address used for pagination. If more results are available, a pageKey will be returned in the response.
    // maxCount: Applies only to the erc20 request type. Specifies the maximum count of token balances to return per call. This value defaults to 100 and is currently capped at 100.
    String? pageKey,
    int? maxCount,
  }) async {
    var params = [
      address,
      contractAddresses.isNotEmpty ? contractAddresses : tokensSpecification,
    ];

    if (pageKey != null) {
      params.add({"pageKey": pageKey});
    }
    if (maxCount != null) {
      params.add({"maxCount": maxCount});
    }

    final result = await wsClient.request(
      method: 'alchemy_getTokenBalances',
      params: params,
    );

    return result.fold(
      (error) => Left(error),
      (response) => Right(EnhancedTokenBalances.fromJson(response)),
    );
  }

  Future<Either<RPCErrorData, EnhancedTokenMetadata>> getTokenMetadata({
    required String address,
  }) async {
    final result = await wsClient.request(
      method: 'alchemy_getTokenMetadata',
      params: [address],
    );

    return result.fold(
      (error) => Left(error),
      (response) => Right(EnhancedTokenMetadata.fromJson(response)),
    );
  }
}
