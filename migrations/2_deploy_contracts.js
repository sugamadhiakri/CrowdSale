var SimpleCrowdsale = artifacts.require("SimpleCrowdsale");

module.exports = function (deployer) {
	let duration = 5 * 60;
	let weiTokenPrice = 1;
	let investmentObj = 15;
	deployer.deploy(SimpleCrowdsale, duration, weiTokenPrice, investmentObj);
};
