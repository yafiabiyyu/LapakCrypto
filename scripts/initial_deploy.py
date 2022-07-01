from brownie import *
from brownie import RekberCrypto, ManagerVrf
from scripts.help_scripts import get_account

def deployRekber(user, subscriptionId):
    contract = RekberCrypto.deploy(
        "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        subscriptionId,
        100000,
        1,
        3,
        "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        {"from": user[0]}
    )
    contract.tx.wait(5)
    print("Contract Address: {}".format(contract.address))
    return contract

def deployManager(user):
    contract = ManagerVrf.deploy(
        "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        "0x01BE23585060835E02B77ef475b0Cc51aA1e0709",
        {"from": user[0]}
    )
    print("Manager VRF Deploy at : {}".format(contract.address))
    contract.tx.wait(5)
    return contract

def fundLink(user, ManagerAddress, amount):
    linkToken = Contract.from_explorer("0x01BE23585060835E02B77ef475b0Cc51aA1e0709")
    linkToken.approve(ManagerAddress, amount, {"from":user[0]})

def main():
    account = get_account()
    linkAmount = web3.toWei("0.5", "ether")
    manager_contract = deployManager(account)

    # Fund manager & subscription wth LINK Token
    print("Fund Manager & Subscription with LINK Token")
    fundLink(account, manager_contract.address, linkAmount)
    manager_contract.topUpLink(linkAmount, {"from": account[0]})
    manager_contract.topUpSubscription(linkAmount, {"from": account[0]})

    # Deploy RekberCrypto and Register as CRF Consumer
    subscriptionId = manager_contract.getSubscriptionId({"from": account[0]})
    rekber_contract = deployRekber(account, subscriptionId)
    manager_contract.addConsumer(rekber_contract.address, {"from": account[0]})


