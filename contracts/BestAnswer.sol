// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./QAC.sol";

contract BestAnswerContract is QACContract {
    using Counters for Counters.Counter;
    Counters.Counter internal _bAIdCounter;

    uint256 bAAPercentage = 60;
    uint256 bARPercentage = 100 - bAAPercentage;

    struct BestAnswer {
        uint256 tokenId;
        uint256 aId;
        bool aHasWithdrawn;
        bool rHasWithdrawn;
    }

    mapping(uint256 => BestAnswer) bAIdToBestAnswer;

    function setBestAnswer(uint256 _tokenId, uint256 _aId) public {
        require(msg.sender == tokenIdToQ[_tokenId].sender);
        require(_tokenId == aIdToAnswer[_aId].tokenId);

        uint256 bAId = _bAIdCounter.current();
        _bAIdCounter.increment();

        BestAnswer memory _bestAnswer = BestAnswer(
            _tokenId,
            _aId,
            false,
            false
        );

        bAIdToBestAnswer[bAId] = _bestAnswer;
    }

    function getBestAnswerForBAId(uint256 _bAId)
        public
        view
        returns (BestAnswer memory)
    {
        return bAIdToBestAnswer[_bAId];
    }

    function getBAIdForTId(uint256 _tokenId) public view returns (uint256 i) {
        uint256 totalBACount = _bAIdCounter.current();

        for (i = 0; i < totalBACount; i++) {
            if (bAIdToBestAnswer[i].tokenId == _tokenId) {
                return i;
            }
        }
    }
}
