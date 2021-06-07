// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ReleasableCoin.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./Destructible.sol";

contract SimpleCrowdsale is Ownable, Pausable, Destructible {
    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiTokenPrice;
    uint256 public weiInvestmentObjective;

    mapping(address => uint256) public investmentAmountOf;

    uint256 public investmentReceived;
    uint256 public investmentRefunded;

    bool public isFinalized;
    bool public isRefundingAllowed;

    ReleasableCoin public crowdsaleToken;

    constructor(
        uint256 _duration,
        uint256 _weiTokenPrice,
        uint256 _etherInvestmentObjective
    ) public {
        // require(_startTime >= now);
        // require(_endTime >= _startTime);
        require(_weiTokenPrice != 0);
        require(_etherInvestmentObjective != 0);

        startTime = now;
        endTime = now + _duration;
        weiTokenPrice = _weiTokenPrice;
        weiInvestmentObjective = _etherInvestmentObjective * (10**18);

        crowdsaleToken = new ReleasableCoin(0);

        isFinalized = false;
        isRefundingAllowed = false;
        owner = msg.sender;
    }

    event LogInvestment(address investor, uint256 value);
    event LogTokenAssignment(address indexed investor, uint256 numTokens);

    function invest() public payable whenNotPaused {
        require(isValidInvestment(msg.value));

        address investor = msg.sender;
        uint256 investment = msg.value;

        investmentAmountOf[investor] += investment;
        investmentReceived += investment;

        assignTokens(investor, investment);
        emit LogInvestment(investor, investment);
    }

    function isValidInvestment(uint256 _investment)
        internal
        view
        whenNotPaused
        returns (bool)
    {
        bool nonZeroInvestment = _investment != 0;
        bool withinCrowdsalePeriod = now >= startTime && now <= endTime;

        return nonZeroInvestment && withinCrowdsalePeriod;
    }

    function assignTokens(address _beneficiary, uint256 _investment)
        internal
        whenNotPaused
    {
        uint256 _numberOfTokens = calculateNumberOfTokens(_investment);

        crowdsaleToken.mint(_beneficiary, _numberOfTokens);
    }

    function calculateNumberOfTokens(uint256 _investment)
        internal
        view
        whenNotPaused
        returns (uint256)
    {
        return _investment / weiTokenPrice;
    }

    function finalize() public onlyOwner whenNotPaused {
        require(!isFinalized);
        require(now > endTime);

        bool isCrowdSalecomplete = now > endTime;

        bool investmentObjMet = investmentReceived >= weiInvestmentObjective;

        if (isCrowdSalecomplete) {
            if (investmentObjMet) {
                crowdsaleToken.release();
            } else {
                isRefundingAllowed = true;
            }
            isFinalized = true;
        }
    }

    event Refund(address investor, uint256 value);

    function refund() public whenNotPaused {
        require(isRefundingAllowed);

        address payable investor = msg.sender;
        uint256 investment = investmentAmountOf[investor];
        if (investment == 0) revert();

        investmentAmountOf[investor] = 0;
        investmentRefunded += investment;

        emit Refund(investor, investment);

        investor.transfer(investment); // handles if there was error sending money to the investor
    }
}
