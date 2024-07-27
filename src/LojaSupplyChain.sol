//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LojaSupplyChain {
    enum Status {
        PENDING, // 0
        LOGGED, // 1
        PURCHASED, // 2
        RECEIVED, // 3
        CANCELED // 4
    }

    Status status; //status da compra
    uint256 idadeMin = 18;
    mapping(address => bool) public approved;
    mapping(address => uint256) balance;

    address payable constant appleStore =
        payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4); // constant não permite que o endereço seja alterado

    uint256 minimumValue = 1 ether;
    string[] Product = ["Iphone 15", "MacBook", "AppleWatch"];

    function getStatus() external view returns (Status) {
        return status;
    }

    function login(uint256 _idade) external returns (bool notLegalAge) {
        if (_idade < 18) revert("You're not in the legal age in Brazil!");
        else {
            status = Status.LOGGED;
            approved[msg.sender] = true;
            return notLegalAge;
        }
    }

    function loginTernario(
        uint256 _idade
    ) external view returns (bool notLegalAge) {
        return _idade < idadeMin ? true : false;
    }

    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(a)) ==
            keccak256(abi.encodePacked(b)));
    }

    function executePurchase(
        string memory optionNum
    ) external payable checkProduct(optionNum) {
        if (!approved[msg.sender]) revert("Not approved!");
        if (compareStrings(optionNum, Product[0])) {
            require(msg.value == 1 ether, "Incorrect Iphone value!");
            balance[msg.sender] += msg.value;
            status = Status.PURCHASED;
        }
        if (compareStrings(optionNum, Product[1])) {
            require(msg.value == 2 ether, "Incorrect Macbook value!");
            balance[msg.sender] += msg.value;
            status = Status.PURCHASED;
        }
        if (compareStrings(optionNum, Product[2])) {
            require(msg.value == 0.5 ether, "Incorrect AppleWatch value!");
            balance[msg.sender] += msg.value;
            status = Status.PURCHASED;
        }
    }

    function receivedOrNot(bool _received) external {
        if (!approved[msg.sender]) revert("Not approved!");
        if (_received == true) {
            appleStore.transfer(address(this).balance);
            status = Status.RECEIVED;
        } else payable(msg.sender).transfer(balance[msg.sender]);
    }

    modifier checkProduct(string memory option) {
        require(
            compareStrings(option, Product[0]) ||
                compareStrings(option, Product[1]) ||
                compareStrings(option, Product[2]),
            "This product doesn't exist!"
        );
        _;
    }
}
