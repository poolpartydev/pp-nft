// We import Chai to use its asserting functions here.
import { BigNumber } from "@ethersproject/bignumber";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { ethers } from "hardhat";
import { LSDBagAttachment } from "../typechain/LSDBagAttachment";
import { TestToken } from "../typechain/TestToken";

chai.use(solidity);
const { expect } = chai;

describe("Minter", function () {

    let LSDBag: LSDBagAttachment;
    let owner: SignerWithAddress;
    let addr1: SignerWithAddress;
    let addr2: SignerWithAddress;
    let addrs: SignerWithAddress[];
    let Token1: TestToken;

    // `beforeEach` will run before each test, re-deploying the contract every
    // time. It receives a callback, which can be async.
    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        const IterableAttachedNFTMap = await (await ethers.getContractFactory("IterableAttachedNFTMap")).deploy();
        const LSDBagFactory = await ethers.getContractFactory("LSDBagAttachment", {
            libraries: {
                IterableAttachedNFTMap: IterableAttachedNFTMap.address
            }
        });
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        // To deploy our contract, we just have to call Token.deploy() and await
        // for it to be deployed(), which happens onces its transaction has been
        // mined.
        LSDBag = (await LSDBagFactory.deploy(addr1.address)) as LSDBagAttachment;

        const ERC20Factory = await ethers.getContractFactory("TestToken");
        Token1 = await (ERC20Factory.deploy()) as TestToken;
    });

    // You can nest describe calls to create subsections.
    describe("Deployment", function () {
        // `it` is another Mocha function. This is the one you use to define your
        // tests. It receives the test name, and a callback function.

        // If the callback function is async, Mocha will `await` it.
        it("Should set the right owner", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.

            // This test expects the owner variable stored in the contract to be equal
            // to our Signer's owner.
            expect(await LSDBag.owner()).to.equal(owner.address);
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await LSDBag.balanceOf(owner.address);
            expect(await LSDBag.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Create LSD Bag", () => {
        it("Should deposit token into LSD Bag and take fee", async () => {
            const KNOTTING_FEE = 5;
            const KNOTTING_PERCENTAGE = KNOTTING_FEE / 100;
            // 1st we have to allow the creation of LSD Bag with the token
            LSDBag.addToken(Token1.address, KNOTTING_FEE, 5, 50, 10000, ethers.constants.AddressZero);
            // then we have to approve the LSD Bag contract
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))
            // then we can knot an LSD Bag
            await LSDBag.knotBag(Token1.address, 20000);
            await LSDBag.knotBag(Token1.address, 10000);


            expect((await LSDBag.getBag(0)).data.balance).to.equal(20000 * (1 - KNOTTING_PERCENTAGE));
            expect((await LSDBag.getBag(1)).data.balance).to.equal(10000 * (1 - KNOTTING_PERCENTAGE));
            expect(await LSDBag.getTokenBalanceOf(Token1.address, owner.address)).to.equal(30000 * (1 - KNOTTING_PERCENTAGE));
            // Token balance of LSD Bag should be 95% of 30k 
            expect(await Token1.balanceOf(LSDBag.address)).to.equal(30000 * (1 - KNOTTING_PERCENTAGE));
            // LSD Fund token balance should be 5% of 30k
            expect(await Token1.balanceOf(await LSDBag.LSDFundAddress())).to.equal(30000 * KNOTTING_PERCENTAGE)
        });

        it("Should set correct owner and owner's balance", async () => {
            LSDBag.addToken(Token1.address, 5, 5, 50, 10000, ethers.constants.AddressZero);
            // then we have to approve the LSD Bag contract
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))
            // then we can knot an LSD Bag
            await LSDBag.knotBag(Token1.address, 20000);

            expect(await LSDBag.ownerOf(0)).to.equal(owner.address);
            expect(await LSDBag.balanceOf(owner.address)).to.equal(1);

            // knot another bag and test
            await LSDBag.knotBag(Token1.address, 20000);
            expect(await LSDBag.ownerOf(1)).to.equal(owner.address);
            expect(await LSDBag.balanceOf(owner.address)).to.equal(2);
        });

        it("Should set correct timestamp", async () => {
            LSDBag.addToken(Token1.address, 5, 5, 50, 10000, ethers.constants.AddressZero);
            // then we have to approve the LSD Bag contract
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))
            // then we can knot an LSD Bag

            await LSDBag.knotBag(Token1.address, 20000);

            const createdAt = (await LSDBag.getBag(0)).data.createdAt
            const now = new Date().getTime() / 1000;

            const OFFSET = 60
            expect(createdAt - OFFSET).to.lt(now);
            expect(createdAt + OFFSET).to.gt(now);
        });

        it("Should set correct token address and dividends details", async () => {
            LSDBag.addToken(Token1.address, 5, 5, 50, 10000, ethers.constants.AddressZero);
            // then we have to approve the LSD Bag contract
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))
            // then we can knot an LSD Bag

            await LSDBag.knotBag(Token1.address, 20000);

            // Test correct setting of the token address
            expect((await LSDBag.getBag(0)).data.tokenAddress).to.equal(Token1.address);
            // Test correct initial dividends to 0 
            expect((await LSDBag.getBag(0)).data.totalDividendsPaid).to.equal(0);
            // After initialization, next payout index should equal global next payout
            expect((await LSDBag.getBag(0)).data.nextPayoutIndex).to.equal((await LSDBag.nextPayoutIndex()));
        });

        it("Should add correct number of shares to `dayToShares` mapping", async () => {
            LSDBag.addToken(Token1.address, 5, 5, 50, 10000, ethers.constants.AddressZero);
            // then we have to approve the LSD Bag contract
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))
            // then we can knot an LSD Bag
            await LSDBag.knotBag(Token1.address, 20000);

            const createdTimestamp = await LSDBag.getDayFromTimestamp((await LSDBag.getBag(0)).data.createdAt);
            expect(await LSDBag.dayToShares(Token1.address, createdTimestamp)).to.be.equal((await LSDBag.getBag(0)).data.balance);
        })

        it("Should fail creating a bag with unallowed token", async () => {
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))

            // The bag shouldn't be created with unallowed token
            await expect(LSDBag.knotBag(Token1.address, 20000)).to.be.reverted;
        });
        it("Should fail creating a bag with lower than the minimal amount", async () => {
            const MIN_AMOUNT = 10000;
            await LSDBag.addToken(Token1.address, 5, 5, 50, 10000, ethers.constants.AddressZero);
            await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)));

            // The bag shouldn't be created with less than 10k tokens
            await expect(LSDBag.knotBag(Token1.address, MIN_AMOUNT - 1)).to.be.reverted;
        });
    })

    describe("Manage LSD Bag tokens", () => {
        it("Token should be disallowed by default", async () => {
            expect((await LSDBag.tokens(Token1.address)).isAllowed).to.be.eq(0);
        });

        it("Should allow token", async () => {
            await LSDBag.addToken(Token1.address, 0, 0, 1, 0, ethers.constants.AddressZero);

            expect((await LSDBag.tokens(Token1.address)).isAllowed).to.be.eq(1);
        });

        it("Should add token to `addedTokens` array", async () => {
            await LSDBag.addToken(Token1.address, 0, 0, 1, 0, ethers.constants.AddressZero);

            expect(await LSDBag.addedTokens(0)).to.be.equal(Token1.address);
        });

        it("Should allow and then disallow token", async () => {
            await LSDBag.addToken(Token1.address, 0, 0, 1, 0, ethers.constants.AddressZero);

            await LSDBag.disallowToken(Token1.address);

            expect((await LSDBag.tokens(Token1.address)).isAllowed).to.be.eq(0);

        });

        it("Should set knotting fee", async () => {
            await LSDBag.setKnottingFee(Token1.address, 15);

            expect((await LSDBag.tokens(Token1.address)).knottingFee).to.be.eq(15);
        });

        it("Should fail setting knotting fee higher than 15", async () => {
            await expect(LSDBag.setKnottingFee(Token1.address, 25)).to.be.reverted;
        });

        it("Should set unknotting fee", async () => {
            await LSDBag.setUnknottingFee(Token1.address, 20);

            expect((await LSDBag.tokens(Token1.address)).unknottingFee).to.be.eq(20);
        });

        it("Should fail setting unknotting fee higher than 20", async () => {
            await expect(LSDBag.setUnknottingFee(Token1.address, 25)).to.be.reverted;
        });

        it("Should set the multiplier", async () => {
            await LSDBag.setTokenMultiplier(Token1.address, 50);

            expect((await LSDBag.tokens(Token1.address)).multiplier).to.be.eq(50);
        });

        it("Should fail setting multiplier <1 or >50", async () => {
            await expect(LSDBag.setTokenMultiplier(Token1.address, 0)).to.be.reverted;
            await expect(LSDBag.setTokenMultiplier(Token1.address, 51)).to.be.reverted;
        });

        it("Should fail when non-owner address tries to manage token data", async () => {
            const nonOwnerLSDBag = LSDBag.connect(addr1);

            await expect(nonOwnerLSDBag.setTokenMultiplier(Token1.address, 5)).to.be.reverted;
            await expect(nonOwnerLSDBag.setDividendTrackerAddress(Token1.address, addr1.address)).to.be.reverted;
            await expect(nonOwnerLSDBag.setKnottingFee(Token1.address, 5)).to.be.reverted;
            await expect(nonOwnerLSDBag.setUnknottingFee(Token1.address, 5)).to.be.reverted
            await expect(nonOwnerLSDBag.disallowToken(Token1.address)).to.be.reverted;
            await LSDBag.addToken(Token1.address, 0, 0, 1, 0, ethers.constants.AddressZero);
            await expect(nonOwnerLSDBag.setDividendTrackerAddress(Token1.address, Token1.address)).to.be.reverted
        });
    });

    const KNOTTING_FEE = 5;
    const UNKNOTTING_FEE = 5;

    const createBag = async () => {
        LSDBag.addToken(Token1.address, KNOTTING_FEE, UNKNOTTING_FEE, 50, 10000, ethers.constants.AddressZero);
        // then we have to approve the LSD Bag contract
        await Token1.approve(LSDBag.address, BigNumber.from(1000000).mul(BigNumber.from(10).pow(18)))
        // then we can knot an LSD Bag

        await LSDBag.knotBag(Token1.address, 20000);
    }

    describe("Burn LSD Bag", () => {

        it("Should burn the bag", async () => {
            await createBag();

            expect(await LSDBag.balanceOf(owner.address)).to.be.eq(1);

            await LSDBag.unknotBag(0);

            expect(await LSDBag.balanceOf(owner.address)).to.be.eq(0);
        });

        it("Should pay out the token balance on unknotting", async () => {
            await createBag();
            const ownerBalanceAfterKnotting = await Token1.balanceOf(owner.address);
            const amountToPayOut = ((await LSDBag.getBag(0)).data.balance).div(100).mul(100 - UNKNOTTING_FEE);
            await LSDBag.unknotBag(0);

            expect(await Token1.balanceOf(owner.address)).to.be.equal(ownerBalanceAfterKnotting.add(amountToPayOut));
        });

        it("Should pay out the unclaimed dividends on unknotting", async () => {
            await createBag();

            expect(addr1.address).to.be.equal(await LSDBag.LSDFundAddress());
            // Create payout from LSD Fund (addr1)
            const tx = await addr1.sendTransaction({
                value: ethers.utils.parseEther("100"),
                to: LSDBag.address,
                gasLimit: 5000000
            });
            await tx.wait();

            expect(await LSDBag.getUnclaimedDividends(0)).to.be.equal(ethers.utils.parseEther("100"));
            const balanceBefore = await owner.getBalance();

            await LSDBag.unknotBag(0);

            expect(ethers.utils.formatEther(await owner.getBalance()).split(".")[0]).to.be.equal(ethers.utils.formatEther(balanceBefore.add(ethers.utils.parseEther("100"))).split(".")[0]);

        });

        it("Should remove the tokens share from `dayToShares` mapping", async () => {
            await createBag();
            await LSDBag.knotBag(Token1.address, 20000);

            const bag0Date = await LSDBag.getDayFromTimestamp((await LSDBag.getBag(0)).data.createdAt);
            const bag1Date = await LSDBag.getDayFromTimestamp((await LSDBag.getBag(1)).data.createdAt);

            const assert0 = bag0Date == bag1Date ? 40000 : 20000;
            const assert1 = bag0Date == bag1Date ? 40000 : 20000;

            expect(await (LSDBag.dayToShares(Token1.address, bag0Date))).to.be.eq(assert0 * (0.95));
            expect(await (LSDBag.dayToShares(Token1.address, bag1Date))).to.be.eq(assert1 * (0.95));

            await LSDBag.unknotBag(0);

            expect(await (LSDBag.dayToShares(Token1.address, bag0Date))).to.be.eq((assert0 - 20000) * (0.95));

            await LSDBag.unknotBag(1);

            expect(await (LSDBag.dayToShares(Token1.address, bag0Date))).to.be.eq(0);

        });

        it("Should fail when non-owner tries to burn the bag", async () => {
            await createBag();
            await expect(LSDBag.connect(addr1).unknotBag(0)).to.be.reverted;
        });
    });

    describe("Transfer ownership of LSD Bag", () => {
        it("Should transfer by by approved operator", async () => {
            await createBag();
            await LSDBag.approve(addr1.address, 0);
            // Operator -- addr1 transfer bag with ID 0 from owner to addr2
            await LSDBag["safeTransferFrom(address,address,uint256)"](owner.address, addr2.address, 0);

            expect(await LSDBag.balanceOf(owner.address)).to.be.eq(0);
            expect(await LSDBag.getTokenBalanceOf(Token1.address, owner.address)).to.be.eq(0);
            expect(await LSDBag.balanceOf(addr2.address)).to.be.eq(1);
            expect(await LSDBag.ownerOf(0)).to.be.eq(addr2.address);
        })

        it("Shouldn't change balance of the bag when transferring", async () => {
            await createBag();
            await LSDBag.approve(addr1.address, 0);

            const balanceBefore = await LSDBag.getTokenBalanceOf(Token1.address, owner.address);

            // Operator -- addr1 transfer bag with ID 0 from owner to addr2
            await LSDBag["safeTransferFrom(address,address,uint256)"](owner.address, addr2.address, 0);
            expect(await LSDBag.getTokenBalanceOf(Token1.address, addr2.address)).to.be.eq(balanceBefore);
        })

        it("Should allow new owner to burn the bag and receive underlying tokens", async () => {
            await createBag();
            await LSDBag.approve(addr1.address, 0);

            // Operator -- addr1 transfer bag with ID 0 from owner to addr2
            await LSDBag.connect(addr1)["safeTransferFrom(address,address,uint256)"](owner.address, addr2.address, 0);
            const bagBalance = await LSDBag.getTokenBalanceOf(Token1.address, addr2.address);
            const addr2BalanceBefore = await Token1.balanceOf(addr2.address);
            await LSDBag.connect(addr2).unknotBag(0);

            expect((await Token1.balanceOf(addr2.address))).to.be.equal(bagBalance.add(addr2BalanceBefore).mul(100 - UNKNOTTING_FEE).div(100));

        })

        it("Should fail when unapproved operator tries to transfer bag", async () => {
            await createBag();
            // Operator -- addr1 transfer bag with ID 0 from owner to addr2
            await expect(LSDBag.connect(addr1)["safeTransferFrom(address,address,uint256)"](owner.address, addr2.address, 0)).to.be.reverted;
        })
    })
});
