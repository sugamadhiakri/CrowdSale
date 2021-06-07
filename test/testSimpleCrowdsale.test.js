const SimpleCrowdsale = artifacts.require("SimpleCrowdsale");
const time = require("./helpers/time");
contract("SimpleCrowdsale", (accounts) => {
	let crowdsale;
	let expectedAdopter;
	let [admin, p1, p2, p3] = accounts;
	beforeEach(async () => {
		let duration = 5 * 30;
		let weiTokenPrice = 1;
		let investmentObj = 15;
		crowdsale = await SimpleCrowdsale.deployed(
			duration,
			weiTokenPrice,
			investmentObj
		);
	});

	xit("should invest 5 ether from p1", async () => {
		await crowdsale.invest({ value: 5, from: p1 });
		const result = await crowdsale.startTime.call();
		console.log(result.toNumber());
	});

	it("should invest 5 ethers from p1, p2 and p3", async () => {
		await crowdsale.invest({ value: 5, from: p1 });
		await crowdsale.invest({ value: 5, from: p2 });
		await crowdsale.invest({ value: 5, from: p3 });
		const result = await crowdsale.investmentReceived.call();
		assert.equal(result.toNumber(), 15);
	});

	it("Finalizes the transaction.", async () => {
		let minutes = 5 * 60;
		await time.increase(minutes);
		await crowdsale.finalize({ from: admin });
	});
});
