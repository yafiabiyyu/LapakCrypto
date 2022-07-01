// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "../interfaces/IWETH.sol";

contract RekberCrypto is VRFConsumerBaseV2, Ownable {
    // State variables used for Chainlink VRF
    VRFCoordinatorV2Interface coordinatorVrf;
    uint256[] private randomWords;
    uint256 private requestId;
    uint64 subscriptionId;
    uint32 callBackGasLimit;
    uint32 numberWords;
    uint16 requestConfirmation;
    bytes32 keyHash;

    constructor(
        address _coordinatorVrf,
        uint64 _subscriptionId,
        uint32 _callBackGasLimit,
        uint32 _numberWords,
        uint16 _requestConfirmation,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_coordinatorVrf){
        coordinatorVrf = VRFCoordinatorV2Interface(_coordinatorVrf);
        subscriptionId = _subscriptionId;
        callBackGasLimit = _callBackGasLimit;
        numberWords = _numberWords;
        requestConfirmation = _requestConfirmation;
        keyHash = _keyHash;
    }

    function requestRandomWords() external onlyOwner {
        requestId = coordinatorVrf.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmation,
            callBackGasLimit,
            numberWords
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory _randomWords) internal override {
        randomWords = _randomWords;
    }
}
