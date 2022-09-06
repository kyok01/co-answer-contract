// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BestAnswer.sol";

contract WithdrawalContract is BestAnswerContract {
    using Counters for Counters.Counter;

    function getWithdrawableAmount() public view returns (uint256) {
        // bestAnswer
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
            } else if (
                !bAIdToBestAnswer[i].rHasWithdrawn &&
                refIdToRef[aIdToAnswer[bAIdToBestAnswer[i].aId].refId]
                    .qacSender ==
                msg.sender
            ) {
                amount +=
                    (tokenIdToQ[bAIdToBestAnswer[i].tokenId].mintPrice *
                        bARPercentage) /
                    100;
            }
        }

        // reply
        uint256 totalRepCount = _repIdCounter.current();
        for (uint256 i = 0; i < totalRepCount; i++) {
            if (
                !repIdToReply[i].repHasWithdrawn &&
                aIdToAnswer[commentIdToComment[repIdToReply[i].cId].answerId]
                    .sender ==
                msg.sender
            ) {
                amount += commentIdToComment[repIdToReply[i].cId].price;
            }
        }

        return amount;
    }

    function withdraw() public payable {
        // bestanswer
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
                bAIdToBestAnswer[i].aHasWithdrawn = true;
            } else if (
                !bAIdToBestAnswer[i].rHasWithdrawn &&
                refIdToRef[aIdToAnswer[bAIdToBestAnswer[i].aId].refId]
                    .qacSender ==
                msg.sender
            ) {
                amount +=
                    (tokenIdToQ[bAIdToBestAnswer[i].tokenId].mintPrice *
                        bARPercentage) /
                    100;
                bAIdToBestAnswer[i].rHasWithdrawn = true;
            }
        }

        // reply
        uint256 totalRepCount = _repIdCounter.current();
        for (uint256 i = 0; i < totalRepCount; i++) {
            if (
                !repIdToReply[i].repHasWithdrawn &&
                aIdToAnswer[commentIdToComment[repIdToReply[i].cId].answerId]
                    .sender ==
                msg.sender
            ) {
                amount += commentIdToComment[repIdToReply[i].cId].price;
            }
        }

        require(amount > 0, "Your withdrawableAmount is 0.");
        payable(msg.sender).transfer(amount);
    }

    function getScore(uint256 _tokenId) public view returns (uint) {
        uint qScore = sqrt(tokenIdToQ[_tokenId].mintPrice);
        Comment[] memory comments = getCommentsForTokenId(_tokenId);
        uint256 totalCommentCount = comments.length;
        uint cScore = 0;
        for (uint256 i = 0; i < totalCommentCount; i++) {
            cScore += sqrt(comments[i].price);
        }
        return (qScore + cScore)**2;
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
