// SPDX-License-Identiier: MIT
pragma solidity  ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

//Owner of 'Ownable' contract is whoever deployed it
contract CryptoDevToken is ERC20, Ownable {

    uint256 public constant tokenPrice = 0.001 ether;

    //10**18 is used to represent the tokens in wei
    uint256 public constant tokensPerNFT = 10 * 10**18;
    
    //max supply of 100000 Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    //CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;

    //mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD"){
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
    @dev Mints 'amount' number of CD Tokens
    'msg.value' should be equal or greater than the tokenPrice * amount
     */

     function mint(uint256 amount) public payable {
         //value of ether sent should be more than tokenPrice * amount
         uint256 _requiredAmount = tokenPrice * amount;
         require(msg.value >= _requiredAmount, "Not enough ether sent");

         //revert txn if this mint will exceed the total supply
         uint256 amountWithDecimals = amount * 10**18;
         require ((totalSupply() + amountWithDecimals) <= maxTotalSupply,
         "Exceeds the max total supply available");

         //call the internal mint function w/in the ERC20 contract
         _mint(msg.sender, amountWithDecimals);
     }

    /**
    @dev Mints tokens based on number of NFTs held by sender
    balance of Crypto Dev NFT's owned by the sender should be more than 0
    Tokens should also not have been claimed by the sender
     */
     function claim() public {
         address sender = msg.sender;

         //get number of CryptoDev NFTs held by sender
         uint256 balance = CryptoDevsNFT.balanceOf(sender);

         //if balance is 0, revert
         require(balance > 0, "You don't own any CryptoDev NFTs");

         //amount keeps track of unclaimed tokenIDs
         uint256 amount = 0;

         //loop over the balance
         for (uint256 i = 0; i < balance; i++) {
             uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);

             //if tokenId not claimed, increase the amount
             if (!tokenIdsClaimed[tokenId]){
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
             }
         }

         //if all tokenIds claimed, revert
         require(amount > 0, "You have claimed all the tokens. You are allowed a max of 10 per NFT");
         //call the mint function
         _mint(msg.sender, amount * tokensPerNFT);

     }

    //Function to receive Ether, msg.data must be empty
     receive() external payable {}

    //Fallback called when msg.data not empty
     fallback() external payable{}

}