// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.19;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { ICreditBureau, CreditBureau } from "../../src/CreditBureau.sol";
import { Utils } from "../Utils.sol";

contract CreditBureauUnitTest is PRBTest, StdCheats {
    address public constant USER = address(uint160(uint256(keccak256(abi.encodePacked("USER")))));
    address public constant REPORTER = address(uint160(uint256(keccak256(abi.encodePacked("REPORTER")))));

    CreditBureau public immutable creditBureau;

    constructor() {
        creditBureau = new CreditBureau(address(1), address(2));
    }

    function testInitialStatus() public {
        (
            uint256 lengthOfCreditHistory,
            uint256 earliestReport,
            uint256 latestReport,
            uint256 totalOpenCreditLines,
            uint256 mostRecentCreditLineOpenDate,
            uint256 totalNumberOfRecords,
            uint256 totalNegativeReviews
        ) = creditBureau.viewCreditSummary(USER);

        assertEq(lengthOfCreditHistory, 0);
        assertEq(earliestReport, 0);
        assertEq(latestReport, 0);
        assertEq(totalOpenCreditLines, 0);
        assertEq(mostRecentCreditLineOpenDate, 0);
        assertEq(totalNumberOfRecords, 0);
        assertEq(totalNegativeReviews, 0);
    }

    function testReporting() public {
        creditBureau.toggleWhitelist(REPORTER);

        ICreditBureau.Report memory report = Utils.createReport();

        vm.prank(REPORTER);
        creditBureau.submitCreditReport(report, USER);

        (
            uint256 lengthOfCreditHistory,
            uint256 earliestReport,
            uint256 latestReport,
            uint256 totalOpenCreditLines,
            uint256 mostRecentCreditLineOpenDate,
            uint256 totalNumberOfRecords,
            uint256 totalNegativeReviews
        ) = creditBureau.viewCreditSummary(USER);

        assertEq(lengthOfCreditHistory, 0);
        assertEq(earliestReport, block.timestamp);
        assertEq(latestReport, block.timestamp);
        assertEq(totalOpenCreditLines, 1);
        assertEq(mostRecentCreditLineOpenDate, block.timestamp);
        assertEq(totalNumberOfRecords, 1);
        assertEq(totalNegativeReviews, 0);
    }

    function testWhitelist() public {
        ICreditBureau.Report memory report = Utils.createReport();

        // Test toggle whitelist
        vm.startPrank(REPORTER);

        vm.expectRevert();
        creditBureau.submitCreditReport(report, USER);

        creditBureau.toggleWhitelist(REPORTER);
        creditBureau.submitCreditReport(report, USER);

        creditBureau.toggleWhitelist(REPORTER);
        vm.expectRevert();
        creditBureau.submitCreditReport(report, USER);

        vm.stopPrank();
    }
}
