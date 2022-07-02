from brownie import *
from brownie import ManagerVrf
import brownie


def test_topup_link(dev_account, Link):
    amount = web3.toWei("100", "ether")
    manager = ManagerVrf[-1]
    Link.approve(manager.address, amount, {"from": dev_account[10]})
    manager.topUpLink(amount, {"from": dev_account[10]})
    manager_balance = Link.balanceOf(manager.address)
    assert manager_balance == web3.toWei("500", "ether")


def test_revert_topup_link(dev_account):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.topUpLink(web3.toWei("0", "ether"), {"from": dev_account[10]})
        manager.topUpLink(web3.toWei("100", "ether"), {"from": dev_account[11]})


def test_topup_subscription(dev_account, Link):
    manager = ManagerVrf[-1]
    manager.topUpSubscription(web3.toWei("400", "ether"), {"from": dev_account[10]})
    assert Link.balanceOf(manager.address) == 0


def test_revert_topup_subscription(dev_account):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.topUpSubscription(web3.toWei("0", "ether"), {"from": dev_account[10]})


def test_add_consumer(dev_account, contract):
    manager = ManagerVrf[-1]
    manager.addConsumer(dev_account[0], {"from": dev_account[10]})
    assert manager.subScriptionStatus(dev_account[0]) == True


def test_add_exist_consumer(dev_account, contract):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.addConsumer(contract.address, {"from": dev_account[10]})


def test_add_zero_address_consumer(dev_account):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.addConsumer(
            "0x0000000000000000000000000000000000000000", {"from": dev_account[10]}
        )


def test_remove_consumer(dev_account, contract):
    manager = ManagerVrf[-1]
    manager.removeConsumer(contract.address, {"from": dev_account[10]})
    assert manager.subScriptionStatus(contract.address) == False


def test_remove_consumer_zero_address(dev_account):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.removeConsumer(
            "0x0000000000000000000000000000000000000000", {"from": dev_account[10]}
        )


def test_remove_deactivate_consumer(dev_account, contract):
    manager = ManagerVrf[-1]
    manager.removeConsumer(contract.address, {"from": dev_account[10]})
    with brownie.reverts():
        manager.removeConsumer(contract.address, {"from": dev_account[10]})


def test_cancle_subscription(dev_account, Link):
    manager = ManagerVrf[-1]
    manager.cancelSubscription(manager.address, {"from": dev_account[10]})
    assert Link.balanceOf(manager.address) == web3.toWei("500", "ether")


def test_cancle_subscription_zerro_address(dev_account):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.cancelSubscription("0x0000000000000000000000000000000000000000")


def test_withdraw(dev_account, Link):
    manager = ManagerVrf[-1]
    manager.cancelSubscription(manager.address, {"from": dev_account[10]})
    manager.withdraw(
        web3.toWei("500", "ether"), dev_account[0], {"from": dev_account[10]}
    )
    assert Link.balanceOf(manager.address) == 0
    assert Link.balanceOf(dev_account[0]) == web3.toWei("500", "ether")


def test_withdraw_revert(dev_account):
    manager = ManagerVrf[-1]
    with brownie.reverts():
        manager.withdraw(0, dev_account[0], {"froma": dev_account[10]})
        manager.withdraw(
            web3.toWei("500", "ether"),
            "0x0000000000000000000000000000000000000000",
            {"from": dev_account[10]},
        )
