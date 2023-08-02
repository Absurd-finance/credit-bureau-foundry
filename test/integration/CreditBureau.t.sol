// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.19;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { ICreditBureau, CreditBureau } from "../../src/CreditBureau.sol";
import { SatelliteCreditBureau } from "../../src/SatelliteCreditBureau.sol";
import { Utils } from "../Utils.sol";

contract CreditBureauIntegrationTest is PRBTest, StdCheats {
    address public constant USER = address(uint160(uint256(keccak256(abi.encodePacked("USER")))));
    address public constant REPORTER = address(uint160(uint256(keccak256(abi.encodePacked("REPORTER")))));

    address public constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address public constant AXELAR_GASRECEIVER = 0x2d5d7d31F671F86C782533cc367F14109a082712;

    uint256 public immutable arbitrum;
    uint256 public immutable optimism;
    CreditBureau public immutable creditBureau;
    SatelliteCreditBureau public immutable satelliteCreditBureau;

    constructor() {
        arbitrum = vm.createFork(vm.envString("FORK_URL_ARBITRUM"), 117_368_184);
        optimism = vm.createFork(vm.envString("FORK_URL_OPTIMISM"), 107_684_492);

        // Deploy main Credit Bureau contract to Arbitrum
        vm.selectFork(arbitrum);
        creditBureau = new CreditBureau(AXELAR_GATEWAY, AXELAR_GASRECEIVER);

        // Deploy Satellite contract to Optimism
        vm.selectFork(optimism);
        satelliteCreditBureau = new SatelliteCreditBureau(AXELAR_GATEWAY, AXELAR_GASRECEIVER);
    }

    function setUp() public {
        vm.selectFork(arbitrum);
        vm.deal(REPORTER, 1 ether);
        creditBureau.toggleWhitelist(REPORTER);

        vm.selectFork(optimism);
        vm.deal(REPORTER, 1 ether);
    }

    function testSameChainReporting() public {
        ICreditBureau.Report memory report = Utils.createReport();

        vm.selectFork(arbitrum);
        vm.prank(REPORTER);
        creditBureau.submitCreditReport(report, USER);
    }

    function testCrossChainReporting() public {
        ICreditBureau.Report memory report = Utils.createReport();

        vm.selectFork(optimism);
        vm.prank(REPORTER);
        satelliteCreditBureau.submitCreditReport{ value: 0.5 ether }(
            "Arbitrum", Strings.toHexString(uint256(uint160(msg.sender)), 20), report, USER
        );

        vm.selectFork(arbitrum);
        (,,,,, uint256 totalNumberOfRecords,) = creditBureau.viewCreditSummary(USER);
        assertEq(totalNumberOfRecords, 1);
    }
}
