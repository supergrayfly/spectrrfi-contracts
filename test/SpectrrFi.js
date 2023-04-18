const { expect } = require("chai");
const helpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const zeroAddress = '0x0000000000000000000000000000000000000000';

describe("SpectrrFi", () => {
  async function deployTwoTokensAdded() {
    const [deployer, addr] = await hre.ethers.getSigners();

    const spectrrfi = await (
      await hre.ethers.getContractFactory("SpectrrFi")
    ).deploy();

    const usd = await (
      await hre.ethers.getContractFactory("Coin")
    ).deploy("USD Coin", "USD", ethers.utils.parseEther("1000000"));
    const btc = await (
      await hre.ethers.getContractFactory("Coin")
    ).deploy("BTC Coin", "BTC", ethers.utils.parseEther("1000000"));

    const usdDividend = await (
      await hre.ethers.getContractFactory("SpectrrFiDividendToken")
    ).deploy(
      "SpectrrFi Dividend USD",
      "SDUSD",
      ethers.utils.parseEther("100000"),
      usd.address,
      spectrrfi.address
    );

    const btcDividend = await (
      await hre.ethers.getContractFactory("SpectrrFiDividendToken")
    ).deploy(
      "SpectrrFi Dividend BTC",
      "SDBTC",
      ethers.utils.parseEther("100000"),
      btc.address,
      spectrrfi.address
    );

    await btcDividend.transfer(
      addr.address,
      hre.ethers.utils.parseEther("50000")
    );

    const usdOracle = await (
      await hre.ethers.getContractFactory("AggregatorV3")
    ).deploy("1");
    const btcOracle = await (
      await hre.ethers.getContractFactory("AggregatorV3")
    ).deploy("28000");

    await spectrrfi.addToken(
      "usd",
      usd.address,
      usdOracle.address,
      usdDividend.address,
      "18",
      "18"
    );
    await spectrrfi.addToken(
      "btc",
      btc.address,
      btcOracle.address,
      btcDividend.address,
      "18",
      "18"
    );

    return { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend };
  }

	async function deployWithSaleOffer() {
    const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
      await helpers.loadFixture(deployTwoTokensAdded);

    await btc.approve(
      spectrrfi.address,
      hre.ethers.utils.parseEther("1000000")
    );

    const [
      amountSelling,
      amountSellingId,
      exchangeRate,
      amountSellingForId,
      repayInSec,
      ratioCollateralToDebt,
      ratioLiquidationAt,
    ] = [
      hre.ethers.utils.parseEther("1"),
      "2",
      hre.ethers.utils.parseEther("29000"),
      "1",
      "86400",
      hre.ethers.utils.parseEther("2"),
      hre.ethers.utils.parseEther("1.5"),
    ];

    await spectrrfi.createSaleOffer(
      amountSelling,
      amountSellingId,
      exchangeRate,
      amountSellingForId,
      repayInSec,
      ratioCollateralToDebt,
      ratioLiquidationAt
    );
		
		return { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend }
	}

	async function deployWithBuyOffer() {
    const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
      await helpers.loadFixture(deployTwoTokensAdded);

    await usd.approve(
      spectrrfi.address,
      hre.ethers.utils.parseEther("1000000")
    );

    const [
      amountBuying,
      amountBuyingId,
      exchangeRate,
      amountBuyingForId,
			collateralTokenId,
      repayInSec,
      ratioCollateralToDebt,
      ratioLiquidationAt,
    ] = [
      hre.ethers.utils.parseEther("1"),
      "2",
      hre.ethers.utils.parseEther("30000"),
      "1",
			"1",
      "172800",
      hre.ethers.utils.parseEther("1.5"),
      hre.ethers.utils.parseEther("1.1"),
    ];

    await spectrrfi.createBuyOffer(
      amountBuying,
      amountBuyingId,
      exchangeRate,
      amountBuyingForId,
			collateralTokenId,
      repayInSec,
      ratioCollateralToDebt,
      ratioLiquidationAt
    );

		return { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend }
	}

  it("Should deploy", async () => {
    await (await hre.ethers.getContractFactory("SpectrrFi")).deploy();
  });

  it("Should add tokens", async () => {
    const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
      await helpers.loadFixture(deployTwoTokensAdded);
  });

  it("Should correctly create a sale offer", async () => {
    const { spectrrfi, deployer } =
      await helpers.loadFixture(deployWithSaleOffer);

		let offer = await spectrrfi.getSaleOfferFromId('1');

    const [
      amountSelling,
      amountSellingId,
      exchangeRate,
      amountSellingForId,
      repayInSec,
      ratioCollateralToDebt,
      ratioLiquidationAt,
    ] = [
      hre.ethers.utils.parseEther("1"),
      "2",
      hre.ethers.utils.parseEther("29000"),
      "1",
      "86400",
      hre.ethers.utils.parseEther("2"),
      hre.ethers.utils.parseEther("1.5"),
    ];

		expect(offer.offerStatus).to.equal(0);
		expect(offer.offerLockState).to.equal(1);
		expect(offer.selling).to.equal(amountSelling);
		expect(offer.sellingFor).to.equal(exchangeRate);
		expect(offer.collateral).to.equal(0);
		expect(offer.repayInSeconds).to.equal(repayInSec);
		expect(offer.timeAccepted).to.equal(0);
		expect(offer.collateralToDebtRatio).to.equal(ratioCollateralToDebt);
		expect(offer.liquidationRatio).to.equal(ratioLiquidationAt);
		expect(offer.sellingId).to.equal(Number(amountSellingId));
		expect(offer.sellingForId).to.equal(Number(amountSellingForId));
		expect(offer.collateralId).to.equal(0)
		expect(offer.seller).to.equal(deployer.address)
		expect(offer.buyer).to.equal(zeroAddress)
  });

  it("Should correctly create a buy offer", async () => {
    const { spectrrfi, deployer } =
      await helpers.loadFixture(deployWithBuyOffer);

		let offer = await spectrrfi.getBuyOfferFromId('1');

    const [
      amountBuying,
      amountBuyingId,
      exchangeRate,
      amountBuyingForId,
			collateralTokenId,
      repayInSec,
      ratioCollateralToDebt,
      ratioLiquidationAt,
    ] = [
      hre.ethers.utils.parseEther("1"),
      "2",
      hre.ethers.utils.parseEther("30000"),
      "1",
			"1",
      "172800",
      hre.ethers.utils.parseEther("1.5"),
      hre.ethers.utils.parseEther("1.1"),
    ];

		expect(offer.offerStatus).to.equal(0);
		expect(offer.offerLockState).to.equal(1);
		expect(offer.buying).to.equal(amountBuying);
		expect(offer.buyingFor).to.equal(exchangeRate);
		expect(offer.collateral).to.equal(hre.ethers.utils.parseEther(`${1.5*30000}`));
		expect(offer.repayInSeconds).to.equal(repayInSec);
		expect(offer.timeAccepted).to.equal(0);
		expect(offer.collateralToDebtRatio).to.equal(ratioCollateralToDebt);
		expect(offer.liquidationRatio).to.equal(ratioLiquidationAt);
		expect(offer.buyingId).to.equal(Number(amountBuyingId));
		expect(offer.buyingForId).to.equal(Number(amountBuyingForId));
		expect(offer.collateralId).to.equal(1)
		expect(offer.seller).to.equal(zeroAddress)
		expect(offer.buyer).to.equal(deployer.address)
  });

	it("Should distribute the correct fees", async () => {
    const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
      await helpers.loadFixture(deployWithBuyOffer);

		expect(await usd.balanceOf(usdDividend.address)).to.equal(hre.ethers.utils.parseEther('45'))
	})

	it("Should send the correct dividends to one address", async () => {
    const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
      await helpers.loadFixture(deployWithBuyOffer);

		await expect(usdDividend.collectDividends(deployer.address)).to.emit(usdDividend, "DividendsWithdrawn").withArgs(() => true, "44999999999999999999");
	})

	it("Should send the correct dividends to many address", async () => {
    const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
      await helpers.loadFixture(deployWithBuyOffer);

		await usdDividend.connect(deployer).transfer(addr.address, hre.ethers.utils.parseEther("50000"))

		await expect(usdDividend.collectDividends(deployer.address)).to.emit(usdDividend, "DividendsWithdrawn").withArgs(() => true, "22499999999999999999");
		await expect(usdDividend.connect(addr).collectDividends(addr.address)).to.emit(usdDividend, "DividendsWithdrawn").withArgs(() => true, "22499999999999999999");
		await expect(await usd.balanceOf(addr.address)).to.equal("22499999999999999999")

		await expect(await usd.balanceOf(usdDividend.address)).to.lte('100')
	})

	it("Should only allow withdrawing dividends by the correct address", async () => {
	  const { spectrrfi, deployer, addr, usd, btc, usdDividend, btcDividend } =
    	await helpers.loadFixture(deployWithBuyOffer);

		await usdDividend.collectDividends(deployer.address);
		await expect(usdDividend.collectDividends(addr.address)).to.be.reverted;

		expect(await usd.balanceOf(usdDividend.address)).to.lte(1)
	})

	/*
		accept
		cancel
		add collateral
		repay
		repay part
		liquidate
		change address
	*/
});
