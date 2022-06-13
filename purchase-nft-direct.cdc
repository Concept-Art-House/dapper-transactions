import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import NFTStorefront from 0x94cc7682f79aa725
import DapperUtilityCoin from 0x94cc7682f79aa725
import UFC_FIGHTER_NFT from 0x94cc7682f79aa725

// This transaction purchases an NFT from a dapp directly (i.e. **not** on a peer-to-peer marketplace).
transaction(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let buyerNFTCollection: &AnyResource{NonFungibleToken.CollectionPublic}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let balanceBeforeTransfer: UFix64
    let mainDUCVault: &DapperUtilityCoin.Vault
    let dappAddress: Address
    let salePrice: UFix64

    prepare(dapp: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
        self.dappAddress = dapp.address

        // Initialize the collection if the buyer does not already have one
        if buyer.borrow<&UFC_FIGHTER_NFT.Collection>(from: UFC_FIGHTER_NFT.CollectionStoragePath) == nil {
            buyer.save(<-UFC_FIGHTER_NFT.createEmptyCollection(), to: UFC_FIGHTER_NFT.CollectionStoragePath
            buyer.link<&UFC_FIGHTER_NFT.Collection{NonFungibleToken.CollectionPublic, UFC_FIGHTER_NFT.UFC_FIGHTER_NFTCollectionPublic}>(
                UFC_FIGHTER_NFT.CollectionPublicPath,
                target: UFC_FIGHTER_NFT.CollectionStoragePath
            )
                ?? panic("Could not link collection Pub Path");
        }

        self.storefront = dapp
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow a reference to the storefront")
        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Listing with that ID in Storefront")

        self.salePrice = self.listing.getDetails().salePrice

        self.mainDUCVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
                    ?? panic("Could not borrow reference to Dapper Utility Coin vault")
        self.balanceBeforeTransfer = self.mainDUCVault.balance
        self.paymentVault <- self.mainDUCVault.withdraw(amount: self.salePrice)

        self.buyerNFTCollection = buyer
            .getCapability<&{NonFungibleToken.CollectionPublic}>(PackNFT.CollectionPublicPath)
            .borrow()
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    pre {
        self.salePrice == expectedPrice: "unexpected price"
        self.dappAddress == 0x94cc7682f79aa725 && self.dappAddress == storefrontAddress: "Requires valid authorizing signature"
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.buyerNFTCollection.deposit(token: <-item)
    }

    post {
        self.mainDUCVault.balance == self.balanceBeforeTransfer: "DUC leakage"
    }
}
