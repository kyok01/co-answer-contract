// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BestAnswer.sol";

contract WithdrawalContract is BestAnswerContract {
    using Counters for Counters.Counter;

    function getWithdrawableAmount() public view returns (uint256) {
        uint256 totalBACount = _bAIdCounter.current();
        uint256 amount = 0;

        for (uint256 i = 0; i < totalBACount; i++) {
            if (
                !bAIdToBestAnswer[i].aHasWithdrawn &&
                aIdToAnswer[bAIdToBestAnswer[i].aId].sender == msg.sender
            ) {
                amount +=
                    (tokenIdToQ[bAIdToBestAnswer[i].tokenId].mintPrice *
                        bAAPercentage) /
                    100;
            console.log("Hi");
            } else if (
                !bAIdToBestAnswer[i].rHasWithdrawn &&
                rIdToRef[aIdToAnswer[bAIdToBestAnswer[i].aId].rId].qacSender ==
                msg.sender
            ) {
                amount +=
                    (tokenIdToQ[bAIdToBestAnswer[i].tokenId].mintPrice *
                        bARPercentage) /
                    100;
            console.log("Hi");
            }
        }
        return amount;
    }

    function withdraw() public payable {
        uint256 amount = getWithdrawableAmount();
        require(amount > 0, "Your withdrawableAmount is 0.");
        payable(msg.sender).transfer(amount);
    }
}
