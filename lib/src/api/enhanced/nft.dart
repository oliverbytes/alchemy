import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:either_dart/either.dart';

class EnhancedNFTAPI with AlchemyConsoleMixin {
  late RpcHttpClient httpClient;

  void setClient(RpcHttpClient client) {
    httpClient = client;
  }

  // FUNCTIONS

  ///Marks all cached tokens for the particular contract as stale. So the next time the endpoint is queried it fetches live data instead of fetching from cache.
  Future<Either<RpcResponse, bool>> invalidateContract({
    required String contractAddress,
  }) async {
    var result = await httpClient.request(
      endpoint: 'invalidateContract',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(json['success']),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTResponse>> getNFTs({
    required String owner,
    String? pageKey,
    List<String> contractAddresses = const [],
    bool withMetadata = true,
    int? tokenUriTimeoutInMs,
    List<NFTSpamFilter> filters = const [],
    List<NFTSpamFilter> excludeFilters = const [],
    OrderBy orderBy = OrderBy.desc,
    SpamConfidenceLevel? spamConfidenceLevel,
  }) async {
    var parameters = {
      'owner': owner,
      'pageKey': pageKey,
      'contractAddresses': contractAddresses,
      'withMetadata': withMetadata,
      'tokenUriTimeoutInMs': tokenUriTimeoutInMs,
      'includeFilters[]': filters.map((e) => e.toParam()).toList(),
      'excludeFilters[]': excludeFilters.map((e) => e.toParam()).toList(),
      'orderBy': orderBy.toParam(),
    };

    if (spamConfidenceLevel != null) {
      parameters['spamConfidenceLevel'] = spamConfidenceLevel.toParam();
    }
    final result = await httpClient.request(
      endpoint: 'getNFTs',
      method: HTTPMethod.get,
      queryParameters: parameters,
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTResponse.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTOwners>> getOwnersForToken({
    required String contractAddress,
    required String tokenId,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getOwnersForToken',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
        'tokenId': tokenId,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTOwners.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTOwnerAddresses>> getOwnersForCollection({
    required String contractAddress,
    bool withTokenBalances = false,
    String? block,
    String? pageKey,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getOwnersForCollection',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
        'withTokenBalances': withTokenBalances,
        'block': block,
        'pageKey': pageKey,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTOwnerAddresses.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, bool>> isHolderOfCollection({
    required String wallet,
    required String contractAddress,
  }) async {
    final result = await httpClient.request(
      endpoint: 'isHolderOfCollection',
      method: HTTPMethod.get,
      queryParameters: {
        'wallet': wallet,
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(json['isHolderOfCollection']),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTContracts>> getContractsForOwner({
    required String owner,
    String? pageKey,
    List<NFTSpamFilter> filters = const [],
    List<NFTSpamFilter> excludeFilters = const [],
    OrderBy orderBy = OrderBy.desc,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getContractsForOwner',
      method: HTTPMethod.get,
      queryParameters: {
        'owner': owner,
        'pageKey': pageKey,
        'includeFilters[]': filters.map((e) => e.toParam()).toList(),
        'excludeFilters[]': excludeFilters.map((e) => e.toParam()).toList(),
        'orderBy': orderBy.toParam(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTContracts.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, EnhancedNFT>> getNFTMetadata({
    required String contractAddress,
    required String tokenId,
    NFTTokenType? tokenType,
    int? tokenUriTimeoutInMs,
    bool? refreshCache,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getNFTMetadata',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
        'tokenId': tokenId,
        'tokenType': tokenType?.toString().split('.').last,
        'tokenUriTimeoutInMs': tokenUriTimeoutInMs,
        'refreshCache': refreshCache,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFT.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTContractMetadata>> getContractMetadata({
    required String contractAddress,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getContractMetadata',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTContractMetadata.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTReingestContract>> reingestContract({
    required String contractAddress,
  }) async {
    final result = await httpClient.request(
      endpoint: 'reingestContract',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTReingestContract.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, List<EnhancedNFTContractMetadata>>> searchContractMetadata({
    required String query,
  }) async {
    final result = await httpClient.request(
      endpoint: 'searchContractMetadata',
      method: HTTPMethod.get,
      queryParameters: {
        'query': query,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(List<EnhancedNFTContractMetadata>.from(
          json.map((item) => EnhancedNFTContractMetadata.fromJson(item))?.toList())),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTCollection>> getNFTsForCollection({
    required String contractAddress,
    bool withMetadata = false,
    String? startToken,
    // TODO: limit
    // TODO: tokenUriTimeoutInMs
  }) async {
    final result = await httpClient.request(
      endpoint: 'getNFTsForCollection',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
        'withMetadata': withMetadata,
        'startToken': startToken,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTCollection.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, List<String>>> getSpamContracts() async {
    final result = await httpClient.request(
      endpoint: 'getSpamContracts',
      method: HTTPMethod.get,
      queryParameters: {},
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(List<String>.from(json.map((item) => item as String)?.toList())),
    );
  }

  Future<Either<RpcResponse, bool>> isSpamContract({
    required String contractAddress,
  }) async {
    final result = await httpClient.request(
      endpoint: 'isSpamContract',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(json),
    );
  }

  Future<Either<RpcResponse, bool>> isAirdrop({
    required String contractAddress,
    required String tokenId,
  }) async {
    final result = await httpClient.request(
      endpoint: 'isAirdrop',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
        'tokenId': tokenId,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(json),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTCollection>> reportSpam({
    required String address,
  }) async {
    final result = await httpClient.request(
      endpoint: 'reportSpam',
      method: HTTPMethod.get,
      queryParameters: {
        'address': address,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTCollection.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, EnhancedNFTCollectionFloorPrice>> getFloorPrice({
    required String contractAddress,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getFloorPrice',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(EnhancedNFTCollectionFloorPrice.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, NFTSalesResponse>> getNFTSales({
    String fromBlock = '0',
    String toBlock = 'latest',
    OrderBy order = OrderBy.desc,
    String? marketplace,
    required String contractAddress,
    String? tokenId,
    String? buyerAddress,
    String? sellerAddress,
    String? taker,
    int? limit,
    String? pageKey,
  }) async {
    final result = await httpClient.request(
      endpoint: 'getNFTSales',
      method: HTTPMethod.get,
      queryParameters: {
        'fromBlock': fromBlock,
        'toBlock': toBlock,
        'order': order.toParam(),
        'marketplace': marketplace,
        'contractAddress': contractAddress,
        'tokenId': tokenId,
        'buyerAddress': buyerAddress,
        'sellerAddress': sellerAddress,
        'taker': taker,
        'limit': limit,
        'pageKey': pageKey,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(NFTSalesResponse.fromJson(json)),
    );
  }

  Future<Either<RpcResponse, List<NFTRarity>>> computeRarity({
    required String contractAddress,
    required String tokenId,
  }) async {
    final result = await httpClient.request(
      endpoint: 'computeRarity',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
        'tokenId': tokenId,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(List<NFTRarity>.from(json.map((item) => NFTRarity.fromJson(item))?.toList())),
    );
  }

  Future<Either<RpcResponse, NFTAttributeSummary>> summarizeNFTAttributes({
    required String contractAddress,
  }) async {
    final result = await httpClient.request(
      endpoint: 'summarizeNFTAttributes',
      method: HTTPMethod.get,
      queryParameters: {
        'contractAddress': contractAddress,
      },
    );

    return result.fold(
      (error) => Left(error),
      (json) => Right(NFTAttributeSummary.fromJson(json)),
    );
  }
}
