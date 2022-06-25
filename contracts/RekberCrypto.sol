// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IWETH.sol";

contract RekberCrypto is Ownable {
    using SafeMath for uint256;
    uint256 private fee;
    address public WETH;

    enum Payment {
        Ether,
        Token
    }

    enum Status {
        Pending,
        Accept,
        Reject,
        Canceled
    }

    struct RekberData {
        uint256 token0;
        uint256 token1;
        address token0Address;
        address token1Address;
        address sellerAddress;
        address buyerAddress;
        Status status;
        Payment payment;
    }

    mapping(address => mapping(address => RekberData)) private sellerToBuyer;
    mapping(address => uint256) private balance;

    event UpdateFee(uint256 oldFee, uint256 newFee);
    event NewRekber(
        uint256 _token0,
        uint256 _token1,
        address _token0Address,
        address _token1Address,
        address _sellerAddress,
        address _buyerAddress,
        Status _status,
        Payment _payment
    );

    modifier checkTokenBalance(address _tokenAddress, uint256 _tokenAmount) {
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenBalance = token.balanceOf(msg.sender);
        require(tokenBalance >= _tokenAmount);
        _;
    }

    constructor(address _WETH, uint256 _fee) {
        WETH = _WETH;
        fee = _fee;
    }

    function updateFee(uint256 _fee) external onlyOwner {
        uint256 oldFee = fee;
        fee = _fee;
        emit UpdateFee(oldFee, _fee);
    }

    function _calculateFee(uint256 _token1Amount)
        private
        view
        returns (uint256 amountReceive, uint256 platformFee)
    {
        platformFee = _token1Amount.div(100).mul(fee);
        amountReceive = _token1Amount.sub(platformFee);
    }

    function createRekber(
        uint256 _token0,
        uint256 _token1,
        address _token0Address,
        address _token1Address,
        address _buyerAddress,
        Payment _payment
    ) external checkTokenBalance(_token0Address, _token0) {
        require(_token0 > 0 && _token1 > 0);
        require(_token0Address != address(0) && _token1Address != address(0));
        IERC20 token = IERC20(_token0Address);
        RekberData memory rekberData;
        if (_payment == Payment.Ether) {
            rekberData.token1Address = WETH;
        } else if (_payment == Payment.Token) {
            rekberData.token1Address = _token1Address;
        }
        rekberData.token0 = _token0;
        rekberData.token1 = _token1;
        rekberData.token0Address;
        rekberData.sellerAddress = msg.sender;
        rekberData.buyerAddress = _buyerAddress;
        rekberData.status = Status.Pending;
        rekberData.payment = _payment;
        token.transferFrom(msg.sender, address(this), _token0);
        emit NewRekber(
            _token0,
            _token1,
            _token0Address,
            _token1Address,
            msg.sender,
            _buyerAddress,
            Status.Pending,
            _payment
        );
    }
}
