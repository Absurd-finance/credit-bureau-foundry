// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.19;

import { ICreditBureau } from "../src/interfaces/ICreditBureau.sol";

library Utils {
    function createReport() public view returns (ICreditBureau.Report memory) {
        ICreditBureau.Credit memory credit = ICreditBureau.Credit({
            collateral: ICreditBureau.Collateral.UNCOLLATERALISED,
            creditType: ICreditBureau.Type.FIXED,
            fromDate: block.timestamp,
            toDate: block.timestamp,
            amount: 1e18,
            token: address(0),
            chain: block.chainid
        });
        ICreditBureau.Report memory report = ICreditBureau.Report({
            creditProvider: "Aave V2",
            reporter: address(0),
            review: ICreditBureau.Review.POSITIVE,
            status: ICreditBureau.Status.OPENED,
            credit: credit,
            timestamp: 0,
            data: "0x0"
        });

        return report;
    }
}
