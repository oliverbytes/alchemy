import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:alchemy_web3/src/api/enhanced/nft.dart';
import 'package:test/test.dart';

const String _key = '<your key>';
var _url = 'your_url';

void main() {
  group('NFTs', () {
    RpcHttpClient client = RpcHttpClient();
    client.init(
      url: _url,
      verbose: true,
    );
    EnhancedNFTAPI api = EnhancedNFTAPI();
    api.setClient(client);

    String owner = '0x4da4a81105965EC8cA43d8c9435C3681B59f17DC';
    String address = '0x4da4a81105965EC8cA43d8c9435C3681B59f17DC';
    String token = '0x0000000000000000000000000000000000000000000000000000000000000003';

    test('getNFTs', () async {
      var nfts = await api.getNFTs(
        owner: owner,
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTResponse resp = nfts.right;
      var spamNfts = resp.ownedNfts.where((element) => element.spamInfo != null).where((element) {
        return element.spamInfo!.classifications.isNotEmpty;
      }).toList();

      expect(spamNfts, isNotEmpty);

      expect(resp, isNotNull);
      expect(resp.blockHash, isNotEmpty);
      expect(resp.pageKey, isNotEmpty);
      expect(resp.totalCount, greaterThan(0));
      expect(resp.ownedNfts.length, greaterThan(0));
      expect(resp.ownedNfts.length, 100); // Page size is 100
      expect(resp.ownedNfts.length, lessThanOrEqualTo(resp.totalCount));
      expect(resp.ownedNfts.first.error, null);
      expect(resp.ownedNfts.first.id.tokenId, isNotEmpty);
      expect(resp.ownedNfts.first.contractAddress!, isNotEmpty);
      expect(resp.ownedNfts.first.title, isNotNull);
    });

    test('invalidateContract', () async {
      var result = await api.invalidateContract(
        contractAddress: '0x000386e3f7559d9b6a2f5c46b4ad1a9587d59dc3',
      );
      if (result.isLeft) {
        fail(result.left.error.message!);
      }

      print(result.right);
    });

    test('getNFTsParameters', () async {
      var nfts = await api.getNFTs(
          owner: owner,
          withMetadata: true,
          filters: [NFTSpamFilter.AIRDROPS, NFTSpamFilter.SPAM],
          spamConfidenceLevel: SpamConfidenceLevel.VERY_HIGH,
          orderBy: OrderBy.transferTime,
          contractAddresses: ['0x000386e3f7559d9b6a2f5c46b4ad1a9587d59dc3']);
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }

      EnhancedNFTResponse resp = nfts.right;

      var spamNfts = resp.ownedNfts.where((element) => element.spamInfo != null).where((element) {
        return element.spamInfo!.classifications.isNotEmpty;
      }).toList();

      expect(spamNfts, isEmpty);

      expect(resp, isNotNull);
      expect(resp.blockHash, isNotEmpty);
      expect(resp.pageKey, isNotEmpty);
      expect(resp.totalCount, greaterThan(0));
      expect(resp.ownedNfts.length, greaterThan(0));
      expect(resp.ownedNfts.length, 100); // Page size is 100
      expect(resp.ownedNfts.length, lessThanOrEqualTo(resp.totalCount));
      expect(resp.ownedNfts.first.error, null);
      expect(resp.ownedNfts.first.id.tokenId, isNotEmpty);
      expect(resp.ownedNfts.first.contractAddress, isNotEmpty);
      expect(resp.ownedNfts.first.title, isNotNull);
      for (var nft in resp.ownedNfts) {
        if (nft.spamInfo != null) {
          expect(nft.spamInfo!.isSpam, 'false');
        }
      }
      expect(resp.ownedNfts.first.contractMetadata?.name, isNotNull);
    });

    test('getOwnersForToken', () async {
      var nfts = await api.getOwnersForToken(contractAddress: address, tokenId: token);
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTOwners resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.owners.length, greaterThan(0));
      expect(resp.owners.first, isNotEmpty);
    });

    test('getOwnersForCollection', () async {
      var nfts = await api.getOwnersForCollection(contractAddress: address);
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTOwnerAddresses resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.ownerAddresses.length, greaterThan(0));
      expect(resp.ownerAddresses.first.ownerAddress, isNotEmpty);
      expect(resp.ownerAddresses.first.tokenBalances.length, 0);
    });

    test('getOwnersForCollectionWithTokenBalances', () async {
      var nfts = await api.getOwnersForCollection(contractAddress: address, withTokenBalances: true);
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTOwnerAddresses resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.ownerAddresses.length, greaterThan(0));
      expect(resp.ownerAddresses.first.ownerAddress, isNotEmpty);
      expect(resp.ownerAddresses.first.tokenBalances.length, greaterThan(0));
      expect(resp.ownerAddresses.first.tokenBalances.first.tokenId, isNotEmpty);
      expect(resp.ownerAddresses.first.tokenBalances.first.balance, greaterThan(0));
    });

    test('isHolderOfCollection', () async {
      var nfts = await api.isHolderOfCollection(
        wallet: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      bool resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp, false);
    });

    test('getContractsForOwner', () async {
      var nfts = await api.getContractsForOwner(
        owner: owner,
        filters: [NFTSpamFilter.AIRDROPS, NFTSpamFilter.SPAM],
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTContracts resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.pageKey, isNotEmpty);
      expect(resp.totalCount, greaterThan(0));
      expect(resp.contracts.length, greaterThan(0));
      expect(resp.contracts.length, 100); // Page size is 100
      expect(resp.contracts.length, lessThanOrEqualTo(resp.totalCount));
      expect(resp.contracts.first.tokenType, isNotNull);
      expect(resp.contracts.first.name, isNotNull);
      //expect(resp.contracts.first.openSea?.imageUrl, isNotNull);
      expect(resp.contracts.first.media.length, greaterThan(0));
      expect(resp.contracts.first.media.first.raw, isNotNull);
    });

    test('getNFTMetadata', () async {
      var nfts = await api.getNFTMetadata(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
        tokenId: '44',
        tokenType: NFTTokenType.ERC721,
        refreshCache: false,
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFT resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.title, 'WoW #44');
      expect(resp.imageUrl, 'ipfs://QmUkdJKCsV8ixm2eDLJGosH8Bntwwx942YXxfuF9yXPBzi');
      expect(resp.tokenUri!.raw, 'ipfs://QmTNBQDbggLZdKF1fRgWnXsnRikd52zL5ciNu769g9JoUP/44');
      expect(resp.media!.first.format, 'png');
      expect(resp.metadata!.name, 'WoW #44');
      expect(resp.contractMetadata!.openSea!.safelistRequestStatus, 'verified');
    });

    test('getContractMetadata', () async {
      var nfts = await api.getContractMetadata(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTContractMetadata resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.address, '0xe785e82358879f061bc3dcac6f0444462d4b5330');
      expect(resp.contractMetadata.tokenType, 'ERC721');
      expect(resp.contractMetadata.openSea?.collectionName, 'World of Women');
      expect(resp.contractMetadata.openSea?.safelistRequestStatus, 'verified');
    });

    test('reingestContract', () async {
      var nfts = await api.reingestContract(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTReingestContract resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.contractAddress, '0xe785e82358879f061bc3dcac6f0444462d4b5330');
      expect(resp.reingestionState, isNotNull);
      expect(resp.progress, null);
    });

    test('searchContractMetadata', () async {
      var nfts = await api.searchContractMetadata(
        query: 'sunglasses',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      List resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.length, greaterThan(0));
      expect(resp.first.address, isNotNull);
      expect(resp.first.contractMetadata.tokenType, isNotNull);
      expect(resp.first.contractMetadata.openSea?.collectionName, isNotNull);
      expect(resp.first.contractMetadata.openSea?.safelistRequestStatus, isNotNull);
    });

    test('getNFTsForCollection', () async {
      var nfts = await api.getNFTsForCollection(
        contractAddress: '0x198478f870d97d62d640368d111b979d7ca3c38f',
        withMetadata: false,
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTCollection resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.nextToken, '0x0000000000000000000000000000000000000000000000000000000000000065');
      expect(resp.nfts.length, greaterThan(0));
      expect(resp.nfts.first.id.tokenId, '0x0000000000000000000000000000000000000000000000000000000000000001');
    });

    test('getNFTsForCollectionWithMetadata', () async {
      var nfts = await api.getNFTsForCollection(
        contractAddress: '0x198478f870d97d62d640368d111b979d7ca3c38f',
        withMetadata: true,
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTCollection resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.nextToken, '0x0000000000000000000000000000000000000000000000000000000000000065');
      expect(resp.nfts.length, greaterThan(0));
      expect(resp.nfts.first.contractAddress, '0x198478f870d97d62d640368d111b979d7ca3c38f');
      expect(resp.nfts.first.id.tokenId, '0x0000000000000000000000000000000000000000000000000000000000000001');
      expect(resp.nfts.first.id.tokenMetadata!.tokenType, 'ERC721');
      expect(resp.nfts.first.title, '8SIAN #1');
      expect(resp.nfts.first.description, isNotEmpty);
      expect(resp.nfts.first.tokenUri!.raw, 'https://api.8siannft.com/api/token/1');
      expect(resp.nfts.first.tokenUri!.gateway, 'https://api.8siannft.com/api/token/1');
      expect(resp.nfts.first.media!.first.raw,
          'https://gateway.pinata.cloud/ipfs/QmeRYM57K1h4Hi9aD9R22svjNJpbQF5qqPVoqYgzmCJrzH');
      expect(resp.nfts.first.media!.first.gateway,
          'https://nft-cdn.alchemy.com/eth-mainnet/43d036e9218fb10d6ca1e8186a75e4d9');
      expect(resp.nfts.first.media!.first.thumbnail,
          'https://res.cloudinary.com/alchemyapi/image/upload/thumbnailv2/eth-mainnet/43d036e9218fb10d6ca1e8186a75e4d9');
      expect(resp.nfts.first.media!.first.format, 'png');
      expect(resp.nfts.first.media!.first.bytes, 8671789);
      expect(resp.nfts.first.metadata!.name, '8SIAN #1');
      expect(resp.nfts.first.metadata!.image,
          'https://gateway.pinata.cloud/ipfs/QmeRYM57K1h4Hi9aD9R22svjNJpbQF5qqPVoqYgzmCJrzH');
      expect(resp.nfts.first.metadata!.description, isNotEmpty);
      expect(resp.nfts.first.metadata!.attributes!.length, greaterThan(0));
      expect(resp.nfts.first.metadata!.attributes!.first.value, 'jingju');
      expect(resp.nfts.first.metadata!.attributes!.first.traitType, 'hairstyle');
      expect(resp.nfts.first.timeLastUpdated!.millisecondsSinceEpoch, greaterThan(0));
      expect(resp.nfts.first.contractMetadata!.name, '8SIAN');
      expect(resp.nfts.first.contractMetadata!.symbol, '8SIAN');
      expect(resp.nfts.first.contractMetadata!.totalSupply, '8888');
      expect(resp.nfts.first.contractMetadata!.tokenType, 'ERC721');
      expect(resp.nfts.first.contractMetadata!.contractDeployer, '0xff71692dca098a03e450a24270824ec3207ec932');
      expect(resp.nfts.first.contractMetadata!.deployedBlockNumber, 13875451);
      expect(resp.nfts.first.contractMetadata!.openSea!.floorPrice, 0.039384);
      expect(resp.nfts.first.contractMetadata!.openSea!.collectionName, '8SIAN Main Collection');
      expect(resp.nfts.first.contractMetadata!.openSea!.safelistRequestStatus, 'verified');
      expect(resp.nfts.first.contractMetadata!.openSea!.imageUrl,
          'https://i.seadn.io/gae/eAULPaXEuD9oufUOtA-_c1MbS71hh_s_2LUMWs_xYBQW4DFqXNU1f6IrEQcE6Zv0gnV3kUyYPPt7mIzsLRhQEEDSkraAnPv81eLi?w=500&auto=format');
      expect(resp.nfts.first.contractMetadata!.openSea!.description, isNotEmpty);
      expect(resp.nfts.first.contractMetadata!.openSea!.externalUrl, 'http://8sian.io');
      expect(resp.nfts.first.contractMetadata!.openSea!.twitterUsername, '8sianNFT');
      expect(resp.nfts.first.contractMetadata!.openSea!.discordUrl, 'https://discord.gg/8sian');
      expect(resp.nfts.first.contractMetadata!.openSea!.lastIngestedAt!.millisecondsSinceEpoch, greaterThan(0));
    });

    test('getSpamContracts', () async {
      var nfts = await api.getSpamContracts();
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      List resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.length, greaterThan(0));
      expect(resp.first, isNotNull);
    });

    test('isSpamContract', () async {
      var nfts = await api.isSpamContract(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      bool resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp, false);
    });

    test('isAirdrop', () async {
      var nfts = await api.isAirdrop(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
        tokenId: '44',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      bool resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp, false);
    });

    test('getFloorPrice', () async {
      var nfts = await api.getFloorPrice(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      EnhancedNFTCollectionFloorPrice resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.openSea!.floorPrice, isNonNegative);
      expect(resp.openSea!.priceCurrency, 'ETH');
      expect(resp.openSea!.collectionUrl, 'https://opensea.io/collection/world-of-women-nft');
      expect(resp.looksRare!.floorPrice, isNonNegative);
      expect(resp.looksRare!.priceCurrency, 'ETH');
      expect(resp.looksRare!.collectionUrl,
          'https://looksrare.org/collections/0xe785e82358879f061bc3dcac6f0444462d4b5330');
    });

    test('getNFTSales', () async {
      var nfts = await api.getNFTSales(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
        tokenId: '44',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      NFTSalesResponse resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.pageKey, null);
      expect(resp.nftSales.length, isNonNegative);
      expect(resp.nftSales.first.marketplaceAddress, isNotEmpty);
      expect(resp.nftSales.first.contractAddress, '0xe785e82358879f061bc3dcac6f0444462d4b5330');
    });

    test('computeRarity', () async {
      var nfts = await api.computeRarity(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
        tokenId: '44',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      List<NFTRarity> resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.length, isNonNegative);
      expect(resp.first.value, isNotEmpty);
      expect(resp.first.traitType, isNotEmpty);
      expect(resp.first.prevalence, isNonNegative);
    });

    test('summarizeNFTAttributes', () async {
      var nfts = await api.summarizeNFTAttributes(
        contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      );
      if (nfts.isLeft) {
        fail(nfts.left.error.message!);
      }
      NFTAttributeSummary resp = nfts.right;
      expect(resp, isNotNull);
      expect(resp.contractAddress, '0xe785e82358879f061bc3dcac6f0444462d4b5330');
      expect(resp.totalSupply, 10000);
      expect(resp.summary.length, 11);
      expect(resp.summary['Earrings']!['WoW Coins'], isNonNegative);
    });
  });
}
