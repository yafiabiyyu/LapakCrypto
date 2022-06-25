from brownie import accounts, config, network, MyToken


def get_account():
    account = accounts.from_mnemonic(
        mnemonic=config["wallets"]["from_mnemonic"], count=3
    )
    return account


def deploy_mocks(name, symbol, totalSupply):
    print(f"Deploy at network : {network.show_active()}")
    print("Deploy Mocks Token")
    account = get_account()
    token = MyToken.deploy(
        name, symbol, totalSupply, {"from": account[0]}
    )
    return token
