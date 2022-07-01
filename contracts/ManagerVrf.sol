// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract ManagerVrf is Ownable {
    VRFCoordinatorV2Interface coordinator;
    LinkTokenInterface linkToken;
    uint64 private subscriptionId;

    constructor(address _coordinator, address _linkToken) {
        coordinator = VRFCoordinatorV2Interface(_coordinator);
        linkToken = LinkTokenInterface(_linkToken);
        _createNewSubscription();
    }

    function _createNewSubscription() private onlyOwner {
        subscriptionId = coordinator.createSubscription();
    }

    function topUpSubscription(uint256 amount) external onlyOwner {
        require(amount > 0);
        linkToken.transferAndCall(
            address(coordinator),
            amount,
            abi.encode(subscriptionId)
        );
    }

    function topUpLink(uint256 _amount) external onlyOwner {
        require(_amount > 0);
        linkToken.transferFrom(msg.sender, address(this), _amount);
    }

    function addConsumer(address consumerAddress) external onlyOwner {
        coordinator.addConsumer(subscriptionId, consumerAddress);
    }

    function removeConsumer(address consumerAddress) external onlyOwner {
        coordinator.removeConsumer(subscriptionId, consumerAddress);
    }

    function cancelSubscription(address receivingWallet) external onlyOwner {
        coordinator.cancelSubscription(subscriptionId, receivingWallet);
        subscriptionId = 0;
    }

    function withdraw(uint256 amount, address to) external onlyOwner {
        linkToken.transfer(to, amount);
    }

    function getSubscriptionId() external view onlyOwner returns(uint64) {
        return subscriptionId;
    }
}
