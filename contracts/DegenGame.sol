// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error ADDRESS_ZERO_NOT_ALLOWED();
error YOU_ARE_NOT_REGISTERED();
error ALREADY_REGISTERED();
error OWNER_CANNOT_REGISTER();
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
        _mint(address(this), 1000000);
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
        if (msg.sender == owner()) revert OWNER_CANNOT_REGISTER();

        Player memory _player = Player(msg.sender, _username, true);

        players[msg.sender] = _player;
        allPlayers.push(_player);

        emit Registers(msg.sender, true);
    }

    function distributeTokens() external onlyOwner {
        Player[] memory _players = allPlayers;

        for (uint256 i = 0; i < _players.length; i++) {
            _transfer(address(this), _players[i].player, 1000);
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

    function lockAccount(address player) external onlyOwner {
        Player storage _player = players[player];

        if (_player.player == address(0) || !_player.isRegistered)
            revert PLAYER_DOES_NOT_EXIST();

        _player.isRegistered = false;
    }

    function openAccount(address player) external onlyOwner {
        Player storage _player = players[player];
        if (_player.player == address(0)) revert PLAYER_DOES_NOT_EXIST();
        if (_player.isRegistered) revert PLAYER_NOT_SUSPENDED();

        _player.isRegistered = true;
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
