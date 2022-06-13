import UFC_FIGHTER_NFT from 0x94cc7682f79aa725
import UFC_NFT from 0x94cc7682f79aa725
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

transaction {
    prepare(collector: AuthAccount) {
        if !collector.getCapability<&{UFC_FIGHTER_NFT.UFC_FIGHTER_NFTCollectionPublic}>(UFC_FIGHTER_NFT.CollectionPublicPath).check() {
            let collection1 <- UFC_FIGHTER_NFT.createEmptyCollection() as! @UFC_FIGHTER_NFT.Collection
            collector.save<@UFC_FIGHTER_NFT.Collection>(<-collection1, to: UFC_FIGHTER_NFT.CollectionStoragePath)
            collector.link<&UFC_FIGHTER_NFT.Collection{UFC_FIGHTER_NFT.UFC_FIGHTER_NFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
                UFC_FIGHTER_NFT.CollectionPublicPath,
                target: UFC_FIGHTER_NFT.CollectionStoragePath,
            )
        }
        if !collector.getCapability<&{UFC_NFT.UFC_NFTCollectionPublic}>(UFC_NFT.CollectionPublicPath).check() {
            let collection2 <- UFC_NFT.createEmptyCollection() as! @UFC_NFT.Collection
            collector.save<@UFC_NFT.Collection>(<-collection2, to: UFC_NFT.CollectionStoragePath)
            collector.link<&UFC_NFT.Collection{UFC_NFT.UFC_NFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(
                UFC_NFT.CollectionPublicPath,
                target: UFC_NFT.CollectionStoragePath,
            )
        }
    }
}
