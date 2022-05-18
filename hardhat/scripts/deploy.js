const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env"});
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
    //address of Crypto Devs NFT Contract
    const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;

    /**
     * A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts, so
     * cryptoDevsTokenContract is a factory for instances of our CrpyotDevToken contrac
     */
    const cryptoDevsTokenContract = await ethers.getContractFactory(
        "CryptoDevToken"
    );

    const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(
        cryptoDevsNFTContract
    );

    console.log(
        "Crypto Devs Token Contract Address:",
        deployedCryptoDevsTokenContract.address
    );
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
