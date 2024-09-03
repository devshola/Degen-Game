# DegenGame

DegenGame is a Solidity program built with a gaming platform in mind. On the platform, players get rewarded for participating in the game. They get tokens, which can be transferred between players and can redeem items in the game store.

# Description

This program is a simple contract written in Solidity, a programming language for developing smart contracts on the Ethereum blockchain. The smart contract inherited the Openzeppelin ERC-20 and Ownable smart contract by importing them as seen below

```javascript
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
```

The contract is a child contract to the OZ ERC-20 and the Ownable smart contract.

The smart contract has 8 functions which are explained below.

- ```playerRegister```: This allows players to register for the game. Only the registered players get rewarded with tokens.
- ```distributeTokens```: the contract owner use this function to transfer tokens to the registered players as a way to reward them for participating in the game.
- ```transferToken```: players who want to transfer their tokens to other players can do that using this function.
- ```balance```: allows only registered users to check their balance.
- ```redeemItem```: allows players to redeem items in the game store. A player can buy items from the game store with their token.
- ```playerBurnsToken```: players can burn their token using this function.

  
# Getting Started

## Executing program

- To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

- Once you are on the Remix website, create a new file by clicking on the "+" icon in the left-hand sidebar. Save the file with a .sol extension (e.g., DegenGame.sol). Copy and paste the following code into the file:

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error ADDRESS_ZERO_NOT_ALLOWED();
error YOU_ARE_NOT_REGISTERED();
error ALREADY_REGISTERED();
error OWNER_CANNOT_REGISTER(address);
error RECIPIENT_NOT_A_PLAYER();
error TRANSFER_FAILED();
error PLAYER_DOES_NOT_EXIST();
error PLAYER_NOT_SUSPENDED();
error ITEM_DOES_NOT_EXIST();
error INSUFFICIENT_BALANCE();

contract DegenGame is ERC20, Ownable {
    Player[] allPlayers;

    struct Player {
        address player;
        string username;
        bool isRegistered;
    }

    struct GameItem {
        address owner;
        uint256 itemId;
        string name;
        uint256 amount;
    }

    mapping(address => Player) public players;
    mapping(uint256 => GameItem) public gameItems;
    mapping(address => mapping(uint256 => GameItem)) public itemOwners;

    event Registers (address player, bool success);
    event PlayerTransfers (address sender, address recipient, uint256 amount);
    event TokenBurnt (address owner, uint256 _amount);
    event Redeemed (address newOwner, uint256 itemId, string name);

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        addItems();
    }

     modifier isRegistered() {
        if (players[msg.sender].isRegistered == false)
            revert YOU_ARE_NOT_REGISTERED();
        _;
    }

    modifier addressZero() {
        if (msg.sender == address(0)) revert ADDRESS_ZERO_NOT_ALLOWED();
        _;
    }

    function playerRegister(string memory _username) external addressZero {
        if (players[msg.sender].player != address(0))
            revert ALREADY_REGISTERED();
        if (msg.sender == owner()) revert OWNER_CANNOT_REGISTER(msg.sender);

        Player memory _player = Player(msg.sender, _username, true);

        players[msg.sender] = _player;
        allPlayers.push(_player);

        emit Registers(msg.sender, true);
    }

    function distributeTokens() external onlyOwner {
        Player[] memory _players = allPlayers;

        for (uint256 i = 0; i < _players.length; i++) {
            _mint(_players[i].player, 1000);
        }
    }

    function transferToken(address _recipient, uint256 _amount)
        external
        isRegistered
        addressZero
    {
        if (players[_recipient].isRegistered == false)
            revert RECIPIENT_NOT_A_PLAYER();

        if (!transfer(_recipient, _amount)) revert TRANSFER_FAILED();

        emit PlayerTransfers(msg.sender, _recipient, _amount);
    }

    function balance() external view isRegistered returns (uint256) {
        return balanceOf(msg.sender);
    }

    function playerBurnsToken(uint256 _amount)
        external
        addressZero
        isRegistered
    {
        _burn(msg.sender, _amount);

        emit TokenBurnt(msg.sender, _amount);
    }

    function redeemItem(uint256 itemId) external isRegistered addressZero {
        GameItem storage _gameItem = gameItems[itemId];

        if (_gameItem.owner == address(0)) revert ITEM_DOES_NOT_EXIST();

        uint256 itemAmount = _gameItem.amount;

        if (balanceOf(msg.sender) < itemAmount) revert INSUFFICIENT_BALANCE();

        transfer(address(this), itemAmount);

        _gameItem.owner = msg.sender;

        itemOwners[msg.sender][itemId] = _gameItem;

          emit Redeemed (msg.sender, itemId, _gameItem.name);
    }

    function addItems() private {
        gameItems[1] = GameItem(address(this), 1, "Life", 1000);
        itemOwners[address(this)][1] = gameItems[1];

        gameItems[2] = GameItem(address(this), 2, "Grenade", 300);
        itemOwners[address(this)][2] = gameItems[2];

        gameItems[3] = GameItem(address(this), 3, "Armor Tank", 300);
        itemOwners[address(this)][3] = gameItems[3];

        gameItems[4] = GameItem(address(this), 4, "Bazooka", 400);
        itemOwners[address(this)][4] = gameItems[4];

        gameItems[5] = GameItem(address(this), 5, "AK 47", 200);
        itemOwners[address(this)][5] = gameItems[5];
    }
}
```
- To compile the code, click the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler" option is set to "0.8.24" (or another compatible version), and then click on the "Compile DegenGame.sol" button.
 
- Change the Environment from the "Remix VM" to Injected Provider - Metamask to deploy to Avalanche chain. On your metamask, make sure the selected network is Avalanche Fuji.
 
- Once you have sorted your environment, you can deploy the contract by clicking the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "DegenGame" contract from the dropdown menu, then click the "Deploy" button.
 
- Once the contract is deployed, you can interact with it the contract.


# Authors

Samuel Shola

# License

This project is licensed under the MIT License - see the LICENSE.md file for details
